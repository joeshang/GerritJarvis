//
//  ReviewScore.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/10.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Foundation

enum ReviewScore: String {
    case PlusTwo = "+2"
    case PlusOne = "+1"
    case Zero = "0"
    case MinusOne = "-1"
    case MinusTwo = "-2"

    static private let priorities: [ReviewScore] = [
        .Zero,
        .PlusOne,
        .MinusOne,
        .PlusTwo,
        .MinusTwo
    ]

    func priority() -> Int {
        var result = 0
        for (index, score) in ReviewScore.priorities.enumerated() {
            if self == score {
                result = index
                break
            }
        }
        return result
    }
}
