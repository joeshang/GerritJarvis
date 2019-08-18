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

    @IBOutlet weak var baseUrlTextField: NSTextField!
    @IBOutlet weak var userTextField: NSTextField!
    @IBOutlet weak var passwordTextField: PasteTextField!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var indicator: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if let user = ConfigManager.shared.user {
            userTextField.stringValue = user
        }
        if let password = ConfigManager.shared.password {
            passwordTextField.stringValue = password
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let baseUrl = baseUrlTextField.stringValue
        if baseUrl.isEmpty {
            showAlert(NSLocalizedString("EmptyUrl", comment: ""))
            return
        }
        let user = userTextField.stringValue
        if user.isEmpty {
            showAlert(NSLocalizedString("EmptyUser", comment: ""))
            return
        }
        let password = passwordTextField.stringValue
        if password.isEmpty {
            showAlert(NSLocalizedString("EmptyPassword", comment: ""))
            return
        }

        saveButton.isEnabled = false
        indicator.isHidden = false
        indicator.startAnimation(nil)
        GerritService(user: user, password: password, baseUrl: baseUrl).verifyAccount { account, statusCode in
            self.saveButton.isEnabled = true
            self.indicator.isHidden = true
            self.indicator.stopAnimation(nil)
            guard let account = account,
                let accountId = account.accountId,
                let name = account.username else {
                if statusCode == 401 {
                    self.showAlert(NSLocalizedString("Unauthorized", comment: ""))
                } else {
                    self.showAlert(NSLocalizedString("NetworkError", comment: ""))
                }
                return
            }
            if user != name {
                self.showAlert(NSLocalizedString("InvalidUser", comment: ""))
                return
            }

            ConfigManager.shared.update(baseUrl: baseUrl, user: user, password: password, accountId: accountId)

            let alert = NSAlert()
            alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
            alert.messageText = NSLocalizedString("SaveSuccess", comment: "")
            alert.informativeText = "\(account.name ?? name)，" + NSLocalizedString("JarvisService", comment: "")
            alert.alertStyle = .informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
    }

    private func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.messageText = NSLocalizedString("SaveFailed", comment: "")
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }

}
