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

    private var dataController: ReviewListDataController!
    private var triggerController: MergedTriggerWindowController?
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
        dataController.addObserver(self, forKeyPath: "isFetchingList", options: .new, context: nil)
    }

    deinit {
        dataController.removeObserver(self, forKeyPath: "isFetchingList")
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
            emptyView.titleLabel.stringValue = NSLocalizedString("ConfigGerritUser", comment: "")
            emptyView.imageView.image = NSImage.init(named: "EmptyUser")
            emptyView.preferenceButton.isHidden = false
            clearButton.isEnabled = false
            refreshButton.isEnabled = false
        } else if dataController.cellViewModels.count == 0 {
            emptyView.isHidden = false
            if !dataController.isFetchingList && dataController.changes == nil {
                emptyView.titleLabel.stringValue = NSLocalizedString("FetchListFailed", comment: "")
                emptyView.imageView.image = NSImage.init(named: "EmptyReview")
            } else {
                emptyView.titleLabel.stringValue = NSLocalizedString("NoReview", comment: "")
                emptyView.imageView.image = NSImage.init(named: "EmptyReview")
            }
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
        dataController.clearAllNewEvents()
        tableView.reloadData()
    }

    @IBAction func refressButtonClicked(_ sender: Any) {
        dataController.fetchReviewList()
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
            name: ReviewListDataController.ReviewListUpdatedNotification,
            object: nil)
    }

    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func tableViewSelectionDidChange(notification: NSNotification) {
        let table = notification.object as! NSTableView
        guard table == tableView, table.selectedRow >= 0 else {
            return
        }

        let vm: ReviewListCellViewModel = dataController.cellViewModels[table.selectedRow]
        vm.resetEvent()
        dataController.updateAllNewEventsCount()

        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.closePopover(sender: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            if let number = self.dataController.cellViewModels[table.selectedRow].changeNumber {
                GerritUtils.openGerrit(number: number, revisionRange: self.dataController.revisionRange(of: number))
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
        return dataController.cellViewModels.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ReviewListCell"), owner: self) as! ReviewListCell
        let vm = dataController.cellViewModels[row]
        cell.bindData(with: vm)
        cell.delegate = self
        return cell
    }

}

extension ReviewListViewController: NSTableViewDelegate {
}

extension ReviewListViewController: ReviewListCellDelegate {
    func reviewListCellDidClickTriggerButton(_ cell: ReviewListCell) {
        guard let change = reviewChange(for: cell) else {
            return
        }
        if triggerController != nil {
            triggerController?.close()
        }
        triggerController = MergedTriggerWindowController(windowNibName: "MergedTriggerWindowController")
        triggerController?.change = change
        triggerController?.showWindow(NSApplication.shared.delegate)
    }

    func reviewListCellDidClickAuthor(_ cell: ReviewListCell) {
        guard let change = reviewChange(for: cell) else {
            return
        }
        GerritUtils.openGerrit(email: change.owner?.email)
    }

    func reviewListCellDidClickProject(_ cell: ReviewListCell) {
        guard let change = reviewChange(for: cell) else {
            return
        }
        GerritUtils.openGerrit(project: change.project)
    }

    func reviewListCellDidClickBranch(_ cell: ReviewListCell) {
        guard let change = reviewChange(for: cell) else {
            return
        }
        GerritUtils.openGerrit(project: change.project, branch: change.branch)
    }

    private func reviewChange(for cell: ReviewListCell) -> Change? {
        let row = tableView.row(for: cell)
        // 注意，changes 和 cellViewModels 并不是一一对应的
        guard row >= 0 && row < dataController.cellViewModels.count,
            let changes = dataController.changes,
            let number = dataController.cellViewModels[row].changeNumber else {
            return nil
        }

        for change in changes {
            if change.number == number {
                return change
            }
        }
        return nil
    }
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
    static func freshController(dataController: ReviewListDataController) -> ReviewListViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ReviewListViewController")
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? ReviewListViewController else {
            fatalError("Why cant i find ReviewListViewController? - Check Main.storyboard")
        }
        viewController.dataController = dataController
        return viewController
    }

}
