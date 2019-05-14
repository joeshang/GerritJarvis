//
//  ConfigManager.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/12.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class ConfigManager {

    fileprivate let UserKey = "UserKey"
    fileprivate let PasswordKey = "PasswordKey"
    fileprivate let RefreshFrequencyKey = "RefreshFrequencyKey"
    fileprivate let DefaultRefreshFrequency: TimeInterval = 1 // minutes

    static let shared = ConfigManager()

    private(set) var user: String?
    private(set) var password: String?
    var refreshFrequency: TimeInterval {
        get {
            let frequency = UserDefaults.standard.double(forKey: PasswordKey)
            guard frequency != 0 else {
                return DefaultRefreshFrequency
            }
            return frequency
        }
        set {
            guard newValue > 0 else {
                return
            }
            UserDefaults.standard.set(newValue, forKey: PasswordKey)
        }
    }

    init() {
        self.user = UserDefaults.standard.string(forKey: UserKey)
        self.password = UserDefaults.standard.string(forKey: PasswordKey)
    }

    func hasUser() -> Bool {
        if let user = user, let password = password,
            !user.isEmpty && !password.isEmpty {
            return true
        } else {
            return false
        }
    }

    func update(user: String, password: String) {
        UserDefaults.standard.set(user, forKey: UserKey)
        self.user = user
        UserDefaults.standard.set(password, forKey: PasswordKey)
        self.password = password
    }

}
