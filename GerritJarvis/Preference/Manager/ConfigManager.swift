//
//  ConfigManager.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/12.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class ConfigManager {
     // 单位为分钟，值必须在 General Preference 的 frequency 选择列表中
    static let DefaultRefreshFrequency: TimeInterval = 3
    static let GerritBaseUrl: String = "http://gerrit.zhenguanyu.com"
    static let AccountUpdatedNotification = Notification.Name("AccountUpdatedNotification")

    static let UserKey = "UserKey"
    static let PasswordKey = "PasswordKey"
    private let RefreshFrequencyKey = "RefreshFrequencyKey"
    private let StartAfterLoginKey = "StartAfterLoginKey"
    private let ShouldNotifyMergeConflict = "ShouldNotifyMergeConflict"
    private let ShouldNotifyNewIncomingReviewKey = "ShouldNotifyNewIncomingReviewKey"
    private let ShowOurNotReadyReviewKey = "ShowOurNotReadyReviewKey"

    static let shared = ConfigManager()

    private(set) var user: String?
    private(set) var password: String?
    var refreshFrequency: TimeInterval {
        get {
            let frequency = UserDefaults.standard.double(forKey: RefreshFrequencyKey)
            guard frequency != 0 else {
                return ConfigManager.DefaultRefreshFrequency
            }
            return frequency
        }
        set {
            guard newValue > 0 else {
                return
            }
            UserDefaults.standard.set(newValue, forKey: RefreshFrequencyKey)
        }
    }

    var startAfterLogin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: StartAfterLoginKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StartAfterLoginKey)
        }
    }

    var shouldNotifyMergeConflict: Bool {
        get {
            return UserDefaults.standard.bool(forKey: ShouldNotifyMergeConflict)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ShouldNotifyMergeConflict)
        }
    }

    var shouldNotifyNewIncomingReview: Bool {
        get {
            return UserDefaults.standard.bool(forKey: ShouldNotifyNewIncomingReviewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ShouldNotifyNewIncomingReviewKey)
        }
    }

    var showOurNotReadyReview: Bool {
        get {
            return UserDefaults.standard.bool(forKey: ShowOurNotReadyReviewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ShowOurNotReadyReviewKey)
        }
    }

    init() {
        self.user = UserDefaults.standard.string(forKey: ConfigManager.UserKey)
        self.password = UserDefaults.standard.string(forKey: ConfigManager.PasswordKey)

        if UserDefaults.standard.value(forKey: ShouldNotifyMergeConflict) == nil {
            self.shouldNotifyMergeConflict = true
        }
        if UserDefaults.standard.value(forKey: ShouldNotifyNewIncomingReviewKey) == nil {
            self.shouldNotifyNewIncomingReview = true
        }
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
        UserDefaults.standard.set(user, forKey: ConfigManager.UserKey)
        self.user = user
        UserDefaults.standard.set(password, forKey: ConfigManager.PasswordKey)
        self.password = password
        NotificationCenter.default.post(name: ConfigManager.AccountUpdatedNotification,
                                        object: nil,
                                        userInfo: [ConfigManager.UserKey: user, ConfigManager.PasswordKey: password])
    }

}
