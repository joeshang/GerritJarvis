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
    }

    @IBAction func settingButtonPressed(_ sender: Any) {
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
        print(table.selectedRow);
        table.deselectRow(table.selectedRow)
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.closePopover(sender: nil)
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
