//
//  GerritAgent.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/10.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class ReviewListAgent: NSObject {

    static let shared = ReviewListAgent()
    static let ReviewListUpdatedNotification = Notification.Name("ReviewListUpdatedNotification")
    static let ReviewListNewEventsNotification = Notification.Name("ReviewListNewEventsNotification")
    static let ReviewListNewEventsKey = "ReviewListNewEventsKey"
    static let ReviewChangeIdKey = "ReviewChangeIdKey"
    static let ReviewChangeNumberKey = "ReviewChangeNumberKey"

    private(set) var cellViewModels = [ReviewListCellViewModel]()
    private(set) var changes = [Change]()

    private var gerritService: GerritService?
    private var timer: Timer?

    override init() {
        super.init()
        NSUserNotificationCenter.default.delegate = self
    }

    func changeAccount(user: String, password: String) {
        stopTimer()
        gerritService = GerritService(user: user, password: password)
        startTimer()
    }

    func fetchReviewList() {
        gerritService?.fetchReviewList { changes in
            guard let changes = changes else {
                return
            }
            let newChanges = self.reorderChanges(changes)
            self.checkMerged(newChanges)
            self.updateChanges(newChanges)
            self.notifyReviewListUpdated()
            self.notifyNewEventsCount()
        }
    }

    private func startTimer() {
        if timer != nil {
            return
        }
        let interval: TimeInterval = ConfigManager.shared.refreshFrequency * 60
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.fetchReviewList()
        })
        timer?.fire()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

}

// MARK: - Update Changes
extension ReviewListAgent {

    private func updateChanges(_ newChanges: [Change]) {
        var viewModels = [ReviewListCellViewModel]()
        for newChange in newChanges {
            var targetIndex: Int? = nil
            guard let newId = newChange.id else {
                continue
            }
            for (index, old) in changes.enumerated() {
                guard let oldId = old.id else {
                    continue
                }
                if newId == oldId {
                    targetIndex = index
                    break
                }
            }
            var viewModel: ReviewListCellViewModel? = nil
            if let targetIndex = targetIndex {
                // 更新已有的 Change
                let originChange = changes[targetIndex]
                if originChange.isSame(newChange) {
                    // 如果没变化，直接复用之前的 ViewModel
                    viewModel = cellViewModels[targetIndex]
                } else {
                    // 否则从新 Change 中找出新的 Message
                    let vm = ReviewListCellViewModel.viewModel(with: newChange)
                    let (score, comments) = handleMessages(newChange.newMessages(baseOn: originChange), for: newChange)
                    vm.reviewScore = score
                    vm.commentCounts = comments
                    if let mergable = originChange.mergeable,
                        newChange.isOurs() && mergable && vm.isMergeConflict {
                        // 我提的 Review 出现了 Merge Conflict
                        vm.hasNewEvent = true
                        postLocationNotification(title: "Merge Conflict",
                                                 imageName: "Conflict",
                                                 change: newChange)
                    } else {
                        vm.hasNewEvent = newChange.hasNewEvent()
                    }
                    viewModel = vm
                }
            } else {
                // 新的 Change
                let vm = ReviewListCellViewModel.viewModel(with: newChange)
                let (score, comments) = handleMessages(newChange.messages ?? [], for: newChange)
                vm.reviewScore = score
                vm.commentCounts = comments
                vm.hasNewEvent = newChange.hasNewEvent()
                viewModel = vm
            }

            if let viewModel = viewModel {
                viewModels.append(viewModel)
            }
        }
        changes = newChanges
        cellViewModels = viewModels
    }

    private func handleMessages(_ messages: [Message], for change: Change) -> (ReviewScore, Int) {
        var currentRevision: Int = 1
        var currentComments: Int = 0
        var currentScore: ReviewScore = .Zero
        var reviews = [String: (ReviewScore, Int)]()
        for message in messages {
            guard let name = message.author?.name,
                let revisionNumber = message.revisionNumber,
                let content = message.message else {
                    continue
            }

            // 如果不以 Patch Set 开头，则认为是非 Review 操作，根据 Revision 是否变化判断有更新
            if !content.hasPrefix("Patch Set \(revisionNumber):")
                || content.hasSuffix("was rebased.") {
                if currentRevision != revisionNumber {
                    currentRevision = revisionNumber
                    currentComments = 0
                    currentScore = .Zero
                    reviews.removeAll()
                }
                continue
            }

            // 打分和评论的 Message 格式为:
            // Patch Set [revisionNumber]: Code-Review[+/-][1/2]\n\n([commentNumber] comments)
            var score: ReviewScore = .Zero
            var comments: Int = 0
            if let range = content.range(of: #"(?<=Code-Review)[+-][12]"#,
                                         options: .regularExpression) {
                score = ReviewScore(rawValue: String(content[range])) ?? score
            }
            if let range = content.range(of: #"(?<=\()\d+(?=\scomments?\))"#,
                                         options: .regularExpression) {
                comments = Int(String(content[range])) ?? comments
            }
            // 自己的 Comment 不会通知也不显示红点，但是计入 Code Review 打分
            if message.author?.username != ConfigManager.shared.user {
                currentComments += comments
            }
            currentScore = updateScore(score, originalScore: currentScore)

            if message.author?.username != ConfigManager.shared.user {
                if var (s, c) = reviews[name] {
                    s = updateScore(score, originalScore: s)
                    c += comments
                } else {
                    reviews[name] = (score, comments)
                }
            }
        }

        for (key, review) in reviews {
            let (score, comments) = review
            var title = key
            var imageName = "Comment"
            if score == .Zero && comments == 0 {
                continue
            }
            if score != .Zero {
                title += " Code-Review\(score.rawValue)"
                imageName = "Review\(score.rawValue)"
            }
            if comments != 0 {
                title += " (\(comments) "
                if comments == 1 {
                    title += "Comment)"
                } else {
                    title += "Comments)"
                }
            }
            postLocationNotification(title: title, imageName: imageName, change: change)
        }

        return (currentScore, currentComments)
    }

    private func updateScore(_ newScore: ReviewScore, originalScore: ReviewScore) -> ReviewScore {
        // 将 Score 更新为 0 认为是一种无效的设置，维持原值不变
        if newScore == .Zero {
            return originalScore
        }
        return newScore
    }

    private func reorderChanges(_ changes: [Change]) -> [Change] {
        var newChanges = [Change]()
        var insert = 0
        for change in changes {
            if change.isOurs() {
                newChanges.insert(change, at: insert)
                insert += 1
            } else {
                newChanges.append(change)
            }
        }
        return newChanges
    }

}

// MARK: - Local Notification
extension ReviewListAgent : NSUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        if let id = userInfo[ReviewListAgent.ReviewChangeIdKey] as? String {
            var target: Int? = nil
            for (index, change) in changes.enumerated() {
                if change.id == id {
                    target = index
                    break
                }
            }
            if let target = target {
                let vm = cellViewModels[target]
                vm.resetEvent()
                notifyNewEventsCount()
                notifyReviewListUpdated()
            }
        }

        if let number = userInfo[ReviewListAgent.ReviewChangeNumberKey] as? Int {
            GerritOpenUrlUtils.openGerrit(number: number)
        }
    }

    private func postLocationNotification(title: String, imageName: String, change: Change) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = change.subject
        notification.contentImage = NSImage.init(named: NSImage.Name(imageName))
        if let id = change.id, let number = change.number {
            notification.userInfo = [ ReviewListAgent.ReviewChangeIdKey: id, ReviewListAgent.ReviewChangeNumberKey: number ]
        }
        // TODO:
//        NSUserNotificationCenter.default.deliver(notification)
        debugPrint(notification)
    }

}

extension ReviewListAgent {

    func notifyNewEventsCount() {
        var newEvents = 0
        for vm in cellViewModels {
            if vm.hasNewEvent {
                newEvents += 1
            }
        }
        let userInfo = [ ReviewListAgent.ReviewListNewEventsKey: newEvents ]
        NotificationCenter.default.post(name: ReviewListAgent.ReviewListNewEventsNotification,
                                        object: nil,
                                        userInfo: userInfo)

    }

    private func notifyReviewListUpdated() {
        NotificationCenter.default.post(name: ReviewListAgent.ReviewListUpdatedNotification,
                                        object: nil,
                                        userInfo: nil)
    }

}

// MARK: - Merged
extension ReviewListAgent {

    private func checkMerged(_ newChanges: [Change]) {
        var leaveChanges = [Change]()
        for change in changes {
            var found = false
            for new in newChanges {
                if new.id == change.id {
                    found = true
                    break
                }
            }
            if !found {
                leaveChanges.append(change)
            }
        }

        for change in leaveChanges {
            guard change.isOurs(),
                let changeId = change.changeId else {
                continue
            }
            gerritService?.fetchChangeDetail(changeId: changeId, completion: { change in
                guard let change = change, change.isMerged() else {
                    return
                }
                guard let name = change.owner?.name,
                    let mergedName = change.mergedBy(),
                    name != mergedName else {
                    return
                }
                self.postLocationNotification(title: "我的 Review Merged!", imageName: "Merged", change: change)
            })
        }
    }

}
