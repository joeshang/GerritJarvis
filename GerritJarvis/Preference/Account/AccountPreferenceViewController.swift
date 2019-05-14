//
//  AccountPreferenceViewController.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/14.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa
import Preferences

class AccountPreferenceViewController: NSViewController, PreferencePane {

    let preferencePaneIdentifier = PreferencePane.Identifier.account
    let preferencePaneTitle = "Account"
    let toolbarItemIcon = NSImage(named: NSImage.advancedName)!

    @IBOutlet weak var userTextField: NSTextField!
    @IBOutlet weak var passwordTextField: PasteTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = ConfigManager.shared.user {
            userTextField.stringValue = user
        }
        if let password = ConfigManager.shared.password {
            passwordTextField.stringValue = password
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let user = userTextField.stringValue
        if user.isEmpty {
            showAlert("gerrit user is empty")
            return
        }
        let password = passwordTextField.stringValue
        if password.isEmpty {
            showAlert("http password is empty")
            return
        }
        ConfigManager.shared.update(user: user, password: password)
        ReviewListAgent.shared.changeAccount(user: user, password: password)
    }

    private func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = "Save Failed"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }

}
