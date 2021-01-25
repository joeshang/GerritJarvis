//
//  BlackListPreferenceViewController.swift
//  GerritJarvis
//
//  Created by Joe Shang on 2019/8/17.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa
import Preferences

class BlackListPreferenceViewController: NSViewController, PreferencePane, NSTableViewDataSource, NSTableViewDelegate {

    let preferencePaneIdentifier = Preferences.PaneIdentifier.blacklist
    let preferencePaneTitle = "Blacklist"
    let toolbarItemIcon = NSImage(named: NSImage.userName)!

    private enum CellIdentifiers {
        static let TypeCell = "TypeCell"
        static let ValueCell = "ValueCell"
    }

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var typeButton: NSPopUpButton!
    @IBOutlet weak var valueTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        renderButton()
    }

    private func renderButton() {
        deleteButton.isEnabled = ConfigManager.shared.blacklist.count > 0
    }
    
    @IBAction func addValue(_ sender: Any) {
        let value = valueTextField.stringValue.trimmingCharacters(in: .whitespaces)
        guard value.count > 0 else {
            return
        }
        let type = (typeButton.indexOfSelectedItem == 0) ? ConfigManager.BlacklistType.User : ConfigManager.BlacklistType.Project
        var found = false
        for (t, v) in ConfigManager.shared.blacklist {
            if type == t && value == v {
                found = true
                break
            }
        }
        if found {
            return
        }

        ConfigManager.shared.appendBlacklist(type: type, value: value)
        tableView.reloadData()
        valueTextField.stringValue = ""
        renderButton()
    }

    @IBAction func deleteValue(_ sender: Any) {
        let index = tableView.selectedRow
        ConfigManager.shared.removeBlacklist(at: index)
        tableView.reloadData()
        renderButton()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return ConfigManager.shared.blacklist.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let (type, value) = ConfigManager.shared.blacklist[row]
        var text = ""
        var identifier: NSUserInterfaceItemIdentifier? = nil
        if tableColumn == tableView.tableColumns[0] {
            text = type
            identifier = NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.TypeCell)
        } else if tableColumn == tableView.tableColumns[1] {
            text = value
            identifier = NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.ValueCell)
        }
        guard let cellIdentifier = identifier,
            let cell = tableView.makeView(withIdentifier:cellIdentifier, owner: nil) as? NSTableCellView else {
            return nil
        }
        cell.textField?.stringValue = text
        return cell
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }

}
