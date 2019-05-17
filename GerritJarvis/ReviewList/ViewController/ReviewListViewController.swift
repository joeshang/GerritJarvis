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
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var clearButton: NSButton!
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            self.tableView.register(NSNib(nibNamed: "ReviewListCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ReviewListCell"))
        }
    }

    private lazy var emptyView: ReviewListEmptyView = {
        let view = ReviewListEmptyView()
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        renderContentView()
        regiseterNotifications()
        ReviewListAgent.shared.addObserver(self, forKeyPath: "isFetchingList", options: .new, context: nil)
    }

    deinit {
        ReviewListAgent.shared.removeObserver(self, forKeyPath: "isFetchingList")
        unregisterNotifications()
    }

    private func setupUserInterface() {
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }
    }

    private func renderContentView() {
        tableView.reloadData()
        if !ConfigManager.shared.hasUser() {
            emptyView.isHidden = false
            emptyView.titleLabel.stringValue = "请设置 Gerrit 用户"
            emptyView.imageView.image = NSImage.init(named: "EmptyUser")
            emptyView.preferenceButton.isHidden = false
            clearButton.isEnabled = false
            refreshButton.isEnabled = false
        } else if ReviewListAgent.shared.cellViewModels.count == 0 {
            emptyView.isHidden = false
            emptyView.titleLabel.stringValue = "暂无 Review"
            emptyView.imageView.image = NSImage.init(named: "EmptyReview")
            emptyView.preferenceButton.isHidden = true
            clearButton.isEnabled = false
            refreshButton.isEnabled = true
        } else {
            emptyView.isHidden = true
            clearButton.isEnabled = true
            refreshButton.isEnabled = true
        }
    }

    @IBAction func clearButtonClicked(_ sender: Any) {
        ReviewListAgent.shared.clearAllNewEvents()
        tableView.reloadData()
    }

    @IBAction func refressButtonClicked(_ sender: Any) {
        ReviewListAgent.shared.fetchReviewList()
    }

    @IBAction func settingButtonClicked(_ sender: NSButton) {
        var point = sender.frame.origin
        point.x = point.x + sender.frame.size.width
        settingMenu.popUp(positioning: nil, at: point, in: view)
    }

    @IBAction func aboutItemClicked(_ sender: NSMenuItem) {
        NSApplication.shared.orderFrontStandardAboutPanel()
    }

    @IBAction func preferencesItemClicked(_ sender: NSMenuItem) {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.showPreference()
        }
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
        ReviewListAgent.shared.updateAllNewEventsCount()

        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.closePopover(sender: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            let change: Change = ReviewListAgent.shared.changes[table.selectedRow]
            if let number = change.number {
                GerritUtils.openGerrit(number: number)
            }
            table.deselectRow(table.selectedRow)
            self.renderContentView()
        })
    }

    @objc func reviewListDidChange(notification: NSNotification) {
        renderContentView()
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

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "isFetchingList",
            let isRefreshing = change?[.newKey] as? Bool else {
            return
        }
        if isRefreshing {
            indicator.isHidden = false
            indicator.startAnimation(nil)
            refreshButton.isEnabled = false
        } else {
            indicator.isHidden = true
            indicator.stopAnimation(nil)
            refreshButton.isEnabled = true
        }
    }

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
