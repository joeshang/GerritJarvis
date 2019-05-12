//
//  GerritAgent.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/10.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class ReviewListAgent {

    static let shared = ReviewListAgent()
    static let ReviewListUpdatedNotification = Notification.Name("ReviewListUpdatedNotification")
    static let ReviewListNewEventsNotification = Notification.Name("ReviewListNewEventsNotification")
    static let ReviewListNewEventsKey = "ReviewListNewEventsKey"

    private(set) var cellViewModels = [ReviewListCellViewModel]()

    private var gerritService: GerritService?
    private var changes = [Change]()
    private var timer: Timer?

    func changeAccount(user: String, password: String) {
        stopTimer()
        gerritService = GerritService(user: user, password: password)
        fetchReviewList()
        startTimer()
    }

    func fetchReviewList() {
        gerritService?.fetchReviewList { changes in
            guard let newChanges = changes else {
                return
            }
            self.updateChanges(newChanges)
            self.notifyReviewListUpdated()
            self.notifyNewEventsCount()
        }
    }

    private func startTimer() {
        if timer != nil {
            return
        }
        let interval: TimeInterval = 5 * 60
        timer = Timer(timeInterval: interval, repeats: true, block: { _ in
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
        for new in newChanges {
            var targetIndex: Int? = nil
            guard let newId = new.id else {
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
            var newMessages: [Message]? = nil
            if let targetIndex = targetIndex {
                // 更新已有的 Change
                let target = changes[targetIndex]
                if target.isSame(new) {
                    // 如果没变化，直接复用之前的 ViewModel
                    viewModels.append(cellViewModels[targetIndex])
                } else {
                    // 否则从新 Change 中找出新的 Message
                    newMessages = new.newMessages(from: target)
                }
            } else {
                // 新的 Change
                newMessages = new.messages ?? []
            }

            if let newMessages = newMessages {
                let vm = ReviewListCellViewModel.viewModel(with: new)
                let (score, comments) = handleMessages(newMessages, for: new)
                vm.reviewScore = score
                vm.commentCounts = comments
                vm.hasNewEvent = new.hasNewEvent()
                viewModels.append(vm)
            }
        }
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
            if !content.hasPrefix("Patch Set \(revisionNumber):") {
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
            if let range = content.range(of: #"(?<=\()\d+\s(?=comments?\))"#,
                                         options: .regularExpression) {
                comments = Int(String(content[range])) ?? comments
            }
            if var (s, c) = reviews[name] {
                s = updateScore(score, originalScore: s)
                if message.author?.name != ConfigManager.shared.user {
                    c += comments
                }
            } else {
                reviews[name] = (score, comments)
            }

            // 自己的 Comment 不会通知也不显示红点，但是计入 Code Review 打分
            if message.author?.name != ConfigManager.shared.user {
                currentComments += comments
            }
            currentScore = updateScore(score, originalScore: currentScore)
        }
        return (currentScore, currentComments)
    }

    private func updateScore(_ newScore: ReviewScore, originalScore: ReviewScore) -> ReviewScore {
        if newScore == .Zero
            || (newScore == .MinusOne && originalScore == .MinusTwo)
            || (newScore == .PlusOne && originalScore == .PlusTwo) {
            return originalScore
        }
        return newScore
    }

}

// MARK: - Notification
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

    private func notifyReview(info: [String: (ReviewScore, Int)], change: Change) {
        // TODO:
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
            guard let changeId = change.id else {
                continue
            }
            gerritService?.fetchChangeDetail(changeId: changeId, completion: { change in
                guard let change = change else {
                    return
                }
                if change.isMerged() {
                    // TODO:
                }
            })
        }
    }

}
