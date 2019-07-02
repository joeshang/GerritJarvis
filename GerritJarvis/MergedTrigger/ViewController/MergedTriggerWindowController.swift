//
//  MergedTriggerWindowController.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/25.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class MergedTriggerWindowController: NSWindowController {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var reviewLabel: NSTextField!
    @IBOutlet weak var pathInputField: NSTextField!
    @IBOutlet var commandTextView: PasteTextView!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!

    var change: Change!

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        var text = ""
        if let name = change.owner?.name {
            text += name
        }
        if let branch = change.branch {
            text += "  " + branch
        }
        if let project = change.project {
            text += "@" + project
        }
        nameLabel.stringValue = text
        reviewLabel.stringValue = change.subject ?? ""
        pathInputField.stringValue = MergedTriggerManager.shared.path ?? MergedTriggerManager.DefaultPath
        commandTextView.string = MergedTriggerManager.shared.fetchTrigger(change: change) ?? ""
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimation(nil)
        MergedTriggerManager.shared.path = pathInputField.stringValue
        MergedTriggerManager.shared.saveTrigger(content: commandTextView.string, change: change, completion: { result in
            loadingIndicator.stopAnimation(nil)
            loadingIndicator.isHidden = true
            guard result else {
                self.showAlertPanel(message: "保存失败", style: .warning, close: false)
                return
            }
            self.showAlertPanel(message: "保存成功", style: .informational, close: true)
        })
    }

    @IBAction func pathChanged(_ sender: Any) {
        MergedTriggerManager.shared.path = pathInputField.stringValue
    }

    private func showAlertPanel(message: String, style: NSAlert.Style, close: Bool) {
        let alert = NSAlert()
        alert.addButton(withTitle: "确定")
        alert.messageText = message
        alert.alertStyle = style
        alert.beginSheetModal(for: window!, completionHandler: { response in
            if close {
                self.close()
            }
        })
    }
}
