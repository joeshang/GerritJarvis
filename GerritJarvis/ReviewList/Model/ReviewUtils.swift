//
//  ReviewUtils.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/10.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class ReviewUtils {
    class func avatar(for name: String) -> NSImage? {
        if name.isEmpty {
            return nil
        }
        var imageName = ""
        return NSImage.init(named: imageName)
    }
}
