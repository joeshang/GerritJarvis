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

    static func parseReviewScores(_ messages: [Message]) -> [(Author, ReviewScore)] {
        var scores = [Int: (Author, ReviewScore)]()
        var currentRevision = 1
        for message in messages {
            guard let author = message.author,
                let accountId = author.accountId,
                let revisionNumber = message.revisionNumber else {
                    continue
            }
            if currentRevision != revisionNumber {
                currentRevision = revisionNumber
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

    static func parseCommentCounts(_ messages: [Message]) -> [(Author, Int)] {
        var counts = [Int: (Author, Int)]()
        var currentRevision = 1
        for message in messages {
            guard let author = message.author,
                let accountId = author.accountId,
                let revisionNumber = message.revisionNumber else {
                continue
            }
            if currentRevision != revisionNumber {
                currentRevision = revisionNumber
                for (accountId, (author, _)) in counts {
                    counts[accountId] = (author, 0)
                }
                continue
            }
            guard message.isReviewEvent() else {
                continue
            }
            counts[accountId] = (author, message.commentCounts())
        }
        return Array(counts.values)
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
            if let (_, s, _) = reviewEvents[accountId] {
                reviewEvents[accountId] = (author, s, comment)
            } else {
                reviewEvents[accountId] = (author, .Zero, comment)
            }
        }
        return Array(reviewEvents.values)
    }

    static private func resetScores(_ scores: [Int: (Author, ReviewScore)]) -> [Int: (Author, ReviewScore)] {
        var scores = [Int: (Author, ReviewScore)]()
        for (id, (author, score)) in scores {
            if score == .MinusTwo  {
                scores[id] = (author, score)
            }
        }
        return scores
    }

}
