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
    
    @IBOutlet var settingMenu: NSMenu!
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            self.tableView.register(NSNib(nibNamed: "ReviewListCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ReviewListCell"))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        regiseterNotifications()
        renderTableView()
    }

    deinit {
        unregisterNotifications()
    }

    private func renderTableView() {
        tableView.reloadData()
    }

    @IBAction func refressButtonPressed(_ sender: Any) {
        ReviewListAgent.shared.fetchReviewList()
    }

    @IBAction func settingButtonPressed(_ sender: NSButton) {
        var point = sender.frame.origin
        point.x = point.x + sender.frame.size.width
        settingMenu.popUp(positioning: nil, at: point, in: view)
    }

    @IBAction func aboutItemClicked(_ sender: NSMenuItem) {
    }

    @IBAction func settingItemClicked(_ sender: NSMenuItem) {
    }

    @IBAction func quitItemClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

}

extension ReviewListViewController {

    private func regiseterNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tableViewSelectionDidChange(notification:)),
            name: NSTableView.selectionDidChangeNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reviewListDidChange(notification:)),
            name: ReviewListAgent.ReviewListUpdatedNotification,
            object: nil)
    }

    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func tableViewSelectionDidChange(notification: NSNotification) {
        let table = notification.object as! NSTableView
        guard table.selectedRow >= 0 else {
            return
        }

        let vm: ReviewListCellViewModel = ReviewListAgent.shared.cellViewModels[table.selectedRow]
        vm.resetEvent()
        ReviewListAgent.shared.notifyNewEventsCount()

        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.closePopover(sender: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            let change: Change = ReviewListAgent.shared.changes[table.selectedRow]
            if let number = change.number {
                GerritOpenUrlUtils.openGerrit(number: number)
            }
            table.deselectRow(table.selectedRow)
            self.renderTableView()
        })
    }

    @objc func reviewListDidChange(notification: NSNotification) {
        renderTableView()
    }

}

extension ReviewListViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return ReviewListAgent.shared.cellViewModels.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ReviewListCell"), owner: self) as! ReviewListCell
        let vm = ReviewListAgent.shared.cellViewModels[row]
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
