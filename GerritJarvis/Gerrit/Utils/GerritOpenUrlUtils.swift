//
//  GerritOpenUrlUtils.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/13.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class GerritOpenUrlUtils {

    static func openGerrit(number: Int) {
        if let url = URL(string: "http://gerrit.zhenguanyu.com/#/c/\(number)") {
            NSWorkspace.shared.open(url)
        }
    }

}
