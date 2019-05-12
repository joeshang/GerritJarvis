//
//  ReviewListCell.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/4/26.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class ReviewListCell: NSTableCellView {

    @IBOutlet weak var projectLabel: NSTextField!
    @IBOutlet weak var branchLabel: NSTextField!
    @IBOutlet weak var commitLabel: NSTextField!

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var avatarImageView: NSImageView!

    @IBOutlet weak var newReviewImageView: NSImageView!
    @IBOutlet weak var commentLabel: NSTextField!
    @IBOutlet weak var commentImageView: NSImageView!
    @IBOutlet weak var reviewImageView: NSImageView!
    @IBOutlet weak var conflictImageView: NSImageView!

    @IBAction func buttonAction(_ sender: Any) {
        print("Button Pressed")
    }

    func bindData(with viewModel: ReviewListCellViewModel) {
        projectLabel.stringValue = viewModel.project
        branchLabel.stringValue = viewModel.branch
        commitLabel.stringValue = viewModel.commitMessage
        nameLabel.stringValue = viewModel.name

        newReviewImageView.isHidden = !viewModel.hasNewEvent
        conflictImageView.isHidden = !viewModel.isMergeConflict

        commentLabel.stringValue = "\(viewModel.commentCounts)"
        commentLabel.isHidden = (viewModel.commentCounts == 0)
        commentImageView.isHidden = (viewModel.commentCounts == 0)

        reviewImageView.image = NSImage.init(named: "Review\(viewModel.reviewScore.rawValue)")
    }
}
