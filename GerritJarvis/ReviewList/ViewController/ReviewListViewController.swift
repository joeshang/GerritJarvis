//
//  ReviewListViewController.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/4/26.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa
import SnapKit

class ReviewListViewController: NSViewController {
    
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            self.tableView.register(NSNib(nibNamed: "ReviewListCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ReviewListCell"))
        }
    }
    fileprivate var cellViewModels = [ReviewListCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        regiseterNotifications()
        renderTableView()
    }

    deinit {
        unregisterNotifications()
    }

    private func regiseterNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tableViewSelectionDidChange(notification:)),
            name: NSTableView.selectionDidChangeNotification,
            object: nil)
    }

    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func renderTableView() {
        cellViewModels = buildCellViewModels()
        tableView.reloadData()
    }

    @objc func tableViewSelectionDidChange(notification: NSNotification) {
        let table = notification.object as! NSTableView
        print(table.selectedRow);
        table.deselectRow(table.selectedRow)
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.closePopover(sender: nil)
    }

    fileprivate func buildCellViewModels() -> [ReviewListCellViewModel] {
        var cellViewModels = [ReviewListCellViewModel]()
        let scores = [ReviewScore.PlusTwo, ReviewScore.PlusOne, ReviewScore.Zero, ReviewScore.MinusOne, ReviewScore.MinusTwo]
        for i in 0...10 {
            let vm = ReviewListCellViewModel()
            vm.branch = "branch-\(i)"
            vm.project = "project-\(i)"
            vm.name = "猿辅导"
            if i % 2 == 0  {
                vm.isNewReview = true
            }
            vm.commentCounts = i
            if i % 3 == 0 {
                vm.isMergeConflict = true
            }
            vm.commitMessage = "测试"
            vm.reviewScore = scores[i % 5]
            cellViewModels.append(vm)
        }
        return cellViewModels
    }

    @IBAction func refressButtonPressed(_ sender: Any) {
    }

    @IBAction func settingButtonPressed(_ sender: Any) {
    }
}

extension ReviewListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cellViewModels.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ReviewListCell"), owner: self) as! ReviewListCell
        let vm = cellViewModels[row]
        cell.bindData(with: vm)
        return cell
    }
}

extension ReviewListViewController: NSTableViewDelegate {
}

extension ReviewListViewController {

    // MARK: Storyboard instantiation
    static func freshController() -> ReviewListViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ReviewListViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ReviewListViewController else {
            fatalError("Why cant i find ReviewListViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
