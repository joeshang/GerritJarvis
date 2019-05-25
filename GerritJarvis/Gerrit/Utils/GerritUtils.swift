//
//  GerritOpenUrlUtils.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/13.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class GerritUtils {

    static func openGerrit(number: Int) {
        if let url = URL(string: "\(ConfigManager.GerritBaseUrl)/#/c/\(number)") {
            NSWorkspace.shared.open(url)
        }
    }

    // 从 messages 中解析出打分情况，不按照 messages 中的顺序，包含自己的打分
    static func parseReviewScores(_ messages: [Message], originRevision: Int) -> [(Author, ReviewScore)] {
        var scores = [Int: (Author, ReviewScore)]()
        var currentRevision = originRevision
        for message in messages {
            guard let author = message.author,
                let accountId = author.accountId,
                let revisionNumber = message.revisionNumber else {
                    continue
            }
            // 只要 revision 发生变化，说明有新的 Patch，需要重置
            if currentRevision != revisionNumber {
                currentRevision = revisionNumber
                // 需要注意的是，-2 操作不能被新的 Patch 重置，需要 -2 的操作者亲自清掉
                scores = resetScores(scores)
                continue
            }
            guard message.isReviewEvent(),
                let score = message.reviewScore() else {
                continue
            }
            scores[accountId] = (author, score)
        }
        return Array(scores.values)
    }

    // 从 messages 中解析出评论情况，按照 messages 中的顺序，包含自己的评论
    static func parseNewCommentCounts(_ messages: [Message], originRevision: Int) -> [(Author, Int)] {
        var counts = [(Author, Int)]()
        var currentRevision = originRevision
        for message in messages {
            guard let author = message.author,
                let revisionNumber = message.revisionNumber else {
                continue
            }
            if currentRevision != revisionNumber {
                currentRevision = revisionNumber
                counts.removeAll()
                continue
            }
            guard message.isReviewEvent() else {
                continue
            }
            let count = message.commentCounts()
            if count > 0 {
                counts.append((author, count))
            }
        }
        return counts
    }

    // 根据以前的值+最新评论的情况，算出最新值
    // 如果出现了我的评论，说明之前的评论都看过，将 count 重置为 0
    static func calculateNewCommentCount(originCount: Int,
                                         comments: [(Author, Int)],
                                         authorFilter: (Author) -> Bool) -> Int {
        var result = originCount
        for (author, count) in comments {
            if author.isMe() {
                result = 0
                continue
            }
            if authorFilter(author) {
                result += count
            }
        }
        return result
    }

    // 将自己已经看过的评论进行过滤
    // 假设 comments 是顺序的，如果出现了我的评论，说明之前的评论都看过了，需要过滤掉
    static func filterComments(_ comments: [(Author, Int)],
                               authorFilter: (Author) -> Bool) -> [(Author, Int)] {
        var result = [(Author, Int)]()
        for (author, count) in comments {
            if author.isMe() {
                result.removeAll()
                continue
            }
            if authorFilter(author) {
                result.append((author, count))
            }
        }
        return result
    }

    static func combineReviewEvents(scores: [(Author, ReviewScore)], comments: [(Author, Int)]) -> [(Author, ReviewScore, Int)] {
        var reviewEvents = [Int: (Author, ReviewScore, Int)]()
        for (author, score) in scores {
            guard let accountId = author.accountId else {
                continue
            }
            reviewEvents[accountId] = (author, score, 0)
        }
        for (author, comment) in comments {
            guard let accountId = author.accountId, comment > 0 else {
                continue
            }
            if let (_, s, c) = reviewEvents[accountId] {
                reviewEvents[accountId] = (author, s, c + comment)
            } else {
                reviewEvents[accountId] = (author, .Zero, comment)
            }
        }
        return Array(reviewEvents.values)
    }

    static private func resetScores(_ scores: [Int: (Author, ReviewScore)]) -> [Int: (Author, ReviewScore)] {
        var result = [Int: (Author, ReviewScore)]()
        for (id, (author, score)) in scores {
            if score == .MinusTwo  {
                result[id] = (author, score)
            }
        }
        return result
    }

}
