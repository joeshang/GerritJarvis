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

    static func parseReviewScores(_ messages: [Message]) -> [Author: ReviewScore] {
        var scores = [Author: ReviewScore]()
        var currentRevision = 1
        for message in messages {
            guard let author = message.author,
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
            scores[author] = score
        }
        return scores
    }

    static func parseCommentCounts(_ messages: [Message]) -> [Author: Int] {
        var counts = [Author: Int]()

        var currentRevision = 1
        for message in messages {
            guard let author = message.author,
                let revisionNumber = message.revisionNumber else {
                    continue
            }
            if currentRevision != revisionNumber {
                currentRevision = revisionNumber
                for (author, _) in counts {
                    counts[author] = 0
                }
                continue
            }
            guard message.isReviewEvent() else {
                continue
            }
            counts[author] = message.commentCounts()
        }

        return counts
    }

    static func combineReviewEvents(scores: [Author: ReviewScore], comments: [Author: Int]) -> [Author: (ReviewScore, Int)] {
        var reviewEvents = [Author: (ReviewScore, Int)]()
        for (author, score) in scores {
            reviewEvents[author] = (score, 0)
        }
        for (author, comment) in comments {
            guard comment > 0 else {
                continue
            }
            if var (_, c) = reviewEvents[author] {
                c += comment
            } else {
                reviewEvents[author] = (.Zero, comment)
            }
        }
        return reviewEvents
    }

    static private func resetScores(_ scores: [Author: ReviewScore]) -> [Author: ReviewScore] {
        var scores = [Author: ReviewScore]()
        for (author, score) in scores {
            if score == .MinusTwo  {
                scores[author] = score
            }
        }
        return scores
    }

}
