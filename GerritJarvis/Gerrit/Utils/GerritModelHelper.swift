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
        guard let ldap = ConfigManager.shared.user else {
            return false
        }
        return owner.isUser(ldap)
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
        guard let ldap = ConfigManager.shared.user else {
            return false
        }
        // 只要最新的 Message 不是自己导致，说明有更新或操作，就认为有新事件
        return !last.isUser(ldap)
    }

    func shouldListenReviewEvent() -> Bool {
        return isOurs()
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

    func newMessages(baseOn originChange: Change?) -> [Message] {
        var result = [Message]()
        guard let messages = messages else {
            return result
        }
        guard let origin = originChange?.messages else {
            return messages
        }
        if messages.count == origin.count {
            return result
        }
        for new in messages {
            var found = false
            for old in origin {
                if new.id == old.id {
                    found = true
                    break
                }
            }
            if !found {
                result.append(new)
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
        let user = ConfigManager.shared.user ?? ""
        let id = String(number ?? 0)
        let merge = String(mergeable ?? true)
        let count = String(messages?.count ?? 1)

        return "\(user)-\(id)-\(merge)-\(count)"
    }

    func newCommentKey() -> String {
        let user = ConfigManager.shared.user ?? ""
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

}

extension Author {

    func isMe() -> Bool {
        return username == ConfigManager.shared.user
    }

    func isUser(_ ldap: String) -> Bool {
        guard let username = username else {
            return false
        }
        return ldap == username
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
