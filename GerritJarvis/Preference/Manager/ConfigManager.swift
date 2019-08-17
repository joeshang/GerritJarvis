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
    static let AccountUpdatedNotification = Notification.Name("AccountUpdatedNotification")
    static let RefreshFrequencyUpdatedNotification = Notification.Name("RefreshFrequencyUpdatedNotification")

    static let BaseUrlKey = "BaseUrlKey"
    static let UserKey = "UserKey"
    static let PasswordKey = "PasswordKey"
    static let AccountIdKey = "AccountIdKey"
    static let RefreshFrequencyKey = "RefreshFrequencyKey"
    static let BlacklistKey = "BlacklistKey"
    private let LaunchAtLoginKey = "LaunchAtLoginKey"
    private let ShouldNotifyMergeConflict = "ShouldNotifyMergeConflict"
    private let ShouldNotifyNewIncomingReviewKey = "ShouldNotifyNewIncomingReviewKey"
    private let ShowOurNotReadyReviewKey = "ShowOurNotReadyReviewKey"

    enum BlacklistType {
        static let User = "User"
        static let Project = "Project"
    }

    static let shared = ConfigManager()

    private(set) var baseUrl: String?
    private(set) var user: String?
    private(set) var password: String?
    private(set) var accountId: Int?
    private(set) var blacklist = [(String, String)]()

    var refreshFrequency: TimeInterval {
        get {
            let frequency = UserDefaults.standard.double(forKey: ConfigManager.RefreshFrequencyKey)
            guard frequency != 0 else {
                return ConfigManager.DefaultRefreshFrequency
            }
            return frequency
        }
        set {
            guard newValue > 0 else {
                return
            }
            UserDefaults.standard.set(newValue, forKey: ConfigManager.RefreshFrequencyKey)
            NotificationCenter.default.post(name: ConfigManager.RefreshFrequencyUpdatedNotification,
                                            object: nil,
                                            userInfo: [ConfigManager.RefreshFrequencyKey:  newValue])
        }
    }

    var launchAtLogin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: LaunchAtLoginKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LaunchAtLoginKey)
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
        self.baseUrl = UserDefaults.standard.string(forKey: ConfigManager.BaseUrlKey)
        self.user = UserDefaults.standard.string(forKey: ConfigManager.UserKey)
        self.password = UserDefaults.standard.string(forKey: ConfigManager.PasswordKey)
        self.accountId = UserDefaults.standard.integer(forKey: ConfigManager.AccountIdKey)
        fetchBlacklist()

        if UserDefaults.standard.value(forKey: ShouldNotifyMergeConflict) == nil {
            self.shouldNotifyMergeConflict = true
        }
        if UserDefaults.standard.value(forKey: ShouldNotifyNewIncomingReviewKey) == nil {
            self.shouldNotifyNewIncomingReview = true
        }
    }

    func hasUser() -> Bool {
        if let url = baseUrl, let user = user, let password = password, let accountId = accountId,
            accountId != 0 && !url.isEmpty && !user.isEmpty && !password.isEmpty {
            return true
        } else {
            return false
        }
    }

    func update(baseUrl: String, user: String, password: String, accountId: Int) {
        UserDefaults.standard.set(baseUrl, forKey: ConfigManager.BaseUrlKey)
        self.baseUrl = baseUrl
        UserDefaults.standard.set(user, forKey: ConfigManager.UserKey)
        self.user = user
        UserDefaults.standard.set(password, forKey: ConfigManager.PasswordKey)
        self.password = password
        UserDefaults.standard.set(accountId, forKey: ConfigManager.AccountIdKey)
        self.accountId = accountId
        NotificationCenter.default.post(name: ConfigManager.AccountUpdatedNotification,
                                        object: nil,
                                        userInfo: [ConfigManager.UserKey: user,
                                                   ConfigManager.PasswordKey: password,
                                                   ConfigManager.BaseUrlKey: baseUrl])
    }

    func appendBlacklist(type: String, value: String) {
        blacklist.append((type, value))
        saveBlacklist()
    }

    func removeBlacklist(at index: Int) {
        guard index > 0 && index < blacklist.count else {
            return
        }
        blacklist.remove(at: index)
        saveBlacklist()
    }

    private func fetchBlacklist() {
        guard let list = UserDefaults.standard.array(forKey: ConfigManager.BlacklistKey) as? [String] else {
            return
        }

        blacklist = list.compactMap { string in
            let array = string.split(separator: ",")
            if array.count != 2 {
                return nil
            }
            let type = array[0]
            let value = array[1]
            return (String(type), String(value))
        }
    }

    private func saveBlacklist() {
        let list = blacklist.map { (t, v) in
            return t + "," + v
        }
        UserDefaults.standard.set(list, forKey: ConfigManager.BlacklistKey)
    }

}
