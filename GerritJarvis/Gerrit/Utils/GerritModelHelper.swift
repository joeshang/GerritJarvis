//
//  GerritModelHelper.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/4/26.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Foundation

extension Change {

    func isOurs(_ ldap: String) -> Bool {
        guard  let owner = owner else {
            return false
        }
        return owner.isUser(ldap)
    }

}

extension Author {

    func isUser(_ ldap: String) -> Bool {
        guard let username = username else {
            return false
        }
        return ldap == username
    }

}

extension Message {

}
