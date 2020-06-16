//
//  GerritModelHelper.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/4/26.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

extension Change {

    func isOurs() -> Bool {
        guard let owner = owner else {
            return false
        }
        guard let accountId = ConfigManager.shared.accountId else {
            return false
        }
        return owner.isUser(accountId)
    }

    func hasNoReviewers() -> Bool {
        guard let labels = labels,
            let review = labels["Code-Review"] as? [String: Any] else {
            return false
        }
        return review["all"] == nil
    }

    func hasNewEvent() -> Bool {
        guard let last = messages?.last?.author else {
            return false
        }
        guard let accountId = ConfigManager.shared.accountId else {
            return false
        }
        // 只要最新的 Message 不是自己导致，说明有更新或操作，就认为有新事件
        return !last.isUser(accountId)
    }

    func shouldListenReviewEvent() -> Bool {
        if isOurs() {
            return true
        } else {
            // 对于别人提的 Review，只要我曾经触发过 Event，就应该关心
            guard let messages = messages else {
                return false
            }
            for message in messages {
                guard let accountId = message.author?.accountId else {
                    continue
                }
                if accountId == ConfigManager.shared.accountId {
                    return true
                }
            }
            return false
        }
    }

    func shouldListen(author: Author) -> Bool {
        if isOurs() {
            return true
        } else {
            // 对于别人提的 Review，只关心 Owner 的 Event
            guard let userId = owner?.accountId else {
                return false
            }
            return author.isUser(userId)
        }
    }

    func isRaiseMergeConflict(with originChange: Change?) -> Bool {
        guard let mergeable = mergeable else {
            return false
        }
        guard let originChange = originChange, let originMergeable = originChange.mergeable else {
            return !mergeable
        }
        return !mergeable && originMergeable
    }

    func newMessages(baseOn originMessageId: String?) -> [Message] {
        var result = [Message]()
        guard let messages = messages else {
            return result
        }
        guard let originMessageId = originMessageId else {
            return messages
        }
        var found = false
        for message in messages {
            guard let messageId = message.id else {
                continue
            }
            if (messageId == originMessageId) {
                found = true
                continue
            }
            if found {
                result.append(message)
            }
        }
        return result
    }

    func isMerged() -> Bool {
        return status == "MERGED"
    }

    func mergedBy() -> String? {
        let prefix = "Change has been successfully merged by "
        guard let last = messages?.last,
            var message = last.message,
            message.hasPrefix(prefix) else {
            return nil
        }
        message.removeFirst(prefix.count)
        return message
    }

    // 通过 mergeable 和 message 的个数来确定 change 是否有改变
    func newEventKey() -> String {
        let user = ConfigManager.shared.accountId ?? 0
        let id = String(number ?? 0)
        let merge = String(mergeable ?? true)
        let count = String(messages?.count ?? 1)

        return "\(user)-\(id)-\(merge)-\(count)"
    }

    func changeNumberKey() -> String {
        let user = ConfigManager.shared.accountId ?? 0
        let id = String(number ?? 0)

        return "\(user)-\(id)"
    }

    func calculateReviewScore() -> (ReviewScore, Author?) {
        var resultScore: ReviewScore = .Zero
        var resultAuthor: Author? = nil
        guard let messages = messages else {
            return (resultScore, resultAuthor)
        }
        let scores = GerritUtils.parseReviewScores(messages, originRevision: 1)
        for (author, score) in scores {
            if resultScore.priority() <= score.priority() {
                resultScore = score
                // 当出现被自己 -2 的情况，Author 始终为自己
                if score == .MinusTwo && (resultAuthor?.isMe() ?? false) {
                    continue
                }
                resultAuthor = author
            }
        }
        return (resultScore, resultAuthor)
    }

    func isInBlacklist() -> Bool {
        guard let name = owner?.name,
            let username = owner?.username,
            let project = project?.description else {
            return false
        }
        var inBlacklist = false
        for (type, value) in ConfigManager.shared.blacklist {
            if type == ConfigManager.BlacklistType.User
                && (value == name || value == username) {
                inBlacklist = true
                break
            }
            if type == ConfigManager.BlacklistType.Project
                && value == project {
                inBlacklist = true
                break
            }
        }
        return inBlacklist
    }

    // 找到一个 Change 中我没看过的 PatchSet 的范围
    func diffRevisionRange() -> (Int, Int)? {
        // 自己的 Change 不关心
        if isOurs() {
            return nil
        }
        guard let messages = messages else {
            return nil
        }
        var our = 0
        var final = 1
        // 找到我看过的最大的 PatchSet
        for message in messages {
            guard let rev = message.revisionNumber else {
                continue
            }
            final = rev
            if message.isOurEvent() {
                our = rev
            }
        }
        // our == final 说明看过的还没提新的 PatchSet
        // our 为 0 说明 Change 完全没看过
        if our >= final || our == 0 {
            return nil
        }
        return (our, final)
    }

}

extension Author {

    func isMe() -> Bool {
        return accountId == ConfigManager.shared.accountId
    }

    func isUser(_ id: Int) -> Bool {
        guard let accountId = accountId else {
            return false
        }
        return id == accountId
    }

    func avatarImage() -> NSImage? {
        if isMe() {
            return NSImage.init(named: NSImage.Name("AvatarMyself"))
        }
        var index = 0
        if let accountId = accountId {
            index = accountId % 46
        }
        return NSImage.init(named: NSImage.Name("Avatar\(index)"))
    }

}

extension Message {

    func isOurEvent() -> Bool {
        guard let author = author else {
            return false
        }
        return author.isMe()
    }

    // 打分和评论的 Message 特点都是以 Patch Set [revisionNumber] 开头，结尾没有 was rebased.
    func isReviewEvent() -> Bool {
        guard let message = message,
            let revisionNumber = revisionNumber else {
            return false
        }
        return (message.hasPrefix("Patch Set \(revisionNumber):") && !message.hasSuffix("was rebased."))
            || (message.hasPrefix("Removed the following votes"))
    }

    func reviewScore() -> ReviewScore? {
        guard let message = message else {
            return nil
        }
        // 从 Message 中筛选出打分
        var score: ReviewScore? = nil
        if message.contains("-Code-Review") {
            score = .Zero
        } else if message.hasPrefix("Removed the following votes") {
            score = .Zero
        } else if let range = message.range(of: #"(?<=Code-Review)[+-][12]"#,
                                            options: .regularExpression) {
            score = ReviewScore(rawValue: String(message[range]))
        }
        return score
    }

    func commentCounts() -> Int {
        var comments: Int = 0
        guard let message = message else {
            return comments
        }
        if let range = message.range(of: #"(?<=\()\d+(?=\scomments?\))"#,
                                     options: .regularExpression) {
            comments = Int(String(message[range])) ?? comments
        }
        return comments
    }

}
