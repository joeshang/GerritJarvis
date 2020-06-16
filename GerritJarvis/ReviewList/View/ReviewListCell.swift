//
//  ReviewListCell.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/4/26.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

protocol ReviewListCellDelegate: NSObjectProtocol {
    func reviewListCellDidClickTriggerButton(_ cell: ReviewListCell)
    func reviewListCellDidClickAuthor(_ cell: ReviewListCell)
    func reviewListCellDidClickProject(_ cell: ReviewListCell)
    func reviewListCellDidClickBranch(_ cell: ReviewListCell)
}

class ReviewListCell: NSTableCellView {

    weak var delegate: ReviewListCellDelegate?

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
        delegate?.reviewListCellDidClickTriggerButton(self)
    }

    @IBAction func authorPressAction(_ sender: Any) {
        delegate?.reviewListCellDidClickAuthor(self)
    }

    @IBAction func projectPressAction(_ sender: Any) {
        delegate?.reviewListCellDidClickProject(self)
    }

    @IBAction func branchPressAction(_ sender: Any) {
        delegate?.reviewListCellDidClickBranch(self)
    }

    func bindData(with viewModel: ReviewListCellViewModel) {
        projectLabel.stringValue = viewModel.project
        branchLabel.stringValue = viewModel.branch
        commitLabel.stringValue = viewModel.commitMessage
        nameLabel.stringValue = viewModel.name
        avatarImageView.image = viewModel.avatar

        newReviewImageView.isHidden = !viewModel.hasNewEvent
        conflictImageView.isHidden = !viewModel.isMergeConflict

        commentLabel.stringValue = "\(viewModel.newComments)"
        commentLabel.isHidden = (viewModel.newComments == 0)
        commentImageView.isHidden = (viewModel.newComments == 0)

        reviewImageView.image = NSImage.init(named: "Review\(viewModel.reviewScore.rawValue)")
    }

    private func hasChinese(in string: String) -> Bool {
        for (_, value) in string.enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        return false
    }
}
