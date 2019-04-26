//
//  GerritResponseUtils.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/4/26.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Foundation

class GerritResponseUtils {
    static func filterResponse(_ data: Data?) -> String? {
        guard let data = data, var string = String(data: data, encoding: .utf8) else {
            return nil
        }
        // gerrit rest api 返回的数据中，会在头部多出一行很奇怪的 )]}'，导致直接解码失败，需要将其移除
        let weirdPrefix = ")]}'"
        string.removeFirst(weirdPrefix.count + 1)
        return string
    }
}
