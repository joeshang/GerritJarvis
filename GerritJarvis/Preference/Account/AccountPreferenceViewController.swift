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
        let user = userTextField.stringValue
        if user.isEmpty {
            showAlert("用户名为空")
            return
        }
        let password = passwordTextField.stringValue
        if password.isEmpty {
            showAlert("密码为空")
            return
        }

        saveButton.isEnabled = false
        indicator.isHidden = false
        indicator.startAnimation(nil)
        GerritService(user: user, password: password, baseUrl: ConfigManager.GerritBaseUrl).verifyAccount { account, statusCode in
            self.saveButton.isEnabled = true
            self.indicator.isHidden = true
            self.indicator.stopAnimation(nil)
            guard let account = account,
                let accountId = account.accountId,
                let name = account.username else {
                if statusCode == 401 {
                    self.showAlert("无效的用户名或密码，请确保是 HTTP 密码而非 Gerrit 登录密码")
                } else {
                    self.showAlert("网络或服务错误，账户验证失败")
                }
                return
            }
            if user != name {
                self.showAlert("无效的用户名，账户验证失败")
                return
            }
            ConfigManager.shared.update(user: user, password: password, accountId: accountId)

            let alert = NSAlert()
            alert.addButton(withTitle: "确定")
            alert.messageText = "保存成功"
            alert.informativeText = "\(account.name ?? name)，Jarvis 将为你服务"
            alert.alertStyle = .informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
    }

    private func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: "确定")
        alert.messageText = "保存失败"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }

}
