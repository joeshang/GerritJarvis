//
//  ReviewListCellViewModel.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/10.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class ReviewListCellViewModel: NSObject {
    var project: String = ""
    var branch: String = ""
    var name: String = ""
    var avatar: NSImage?
    var commitMessage: String = ""
    var commentCounts: Int = 0
    var reviewScore: ReviewScore = .Zero
    var hasNewEvent: Bool = false
    var isMergeConflict: Bool = false

    class func viewModel(with change: Change) -> ReviewListCellViewModel {
        let vm = ReviewListCellViewModel()
        vm.project = change.project ?? ""
        vm.branch = change.branch ?? ""
        vm.name = change.owner?.name ?? ""
        vm.avatar = ReviewUtils.avatar(for: vm.name)
        vm.commitMessage = change.subject ?? ""
        vm.isMergeConflict = change.mergeable ?? false
        return vm
    }
}
