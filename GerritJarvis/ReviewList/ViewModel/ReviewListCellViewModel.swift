//
//  ReviewListCellViewModel.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/10.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class ReviewListCellViewModel: NSObject {
    let changeNumber: Int?
    let newEventKey: String
    let newCommentKey: String
    let project: String
    let branch: String
    let name: String
    let commitMessage: String
    let avatar: NSImage?
    var newComments: Int = 0
    var reviewScore: ReviewScore = .Zero
    var hasNewEvent: Bool = false
    var isMergeConflict: Bool = false
    var isOurNotReady: Bool = false

    init(change: Change) {
        changeNumber = change.number
        newEventKey = change.newEventKey()
        newCommentKey = change.newCommentKey()
        project = change.project ?? ""
        branch = change.branch ?? ""
        name = change.owner?.name ?? ""
        commitMessage = change.subject ?? ""
        avatar = change.owner?.avatarImage()
        hasNewEvent = change.hasNewEvent()
        isMergeConflict = !(change.mergeable ?? true)
        let (score, author) = change.calculateReviewScore()
        reviewScore = score
        if change.isOurs() {
            // 自己提的 Review 被自己 -2，说明还没准备好
            if let author = author,
                score == .MinusTwo && author.isMe() {
                isOurNotReady = true
            }
        }

        super.init()
    }

    func resetEvent() {
        hasNewEvent = false
        newComments = 0
    }
}
