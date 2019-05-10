//
//  VerticallyCenteredTextFieldCell.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/10.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        var newRect:NSRect = super.drawingRect(forBounds: theRect)
        let textSize:NSSize = self.cellSize(forBounds: theRect)
        let heightDelta:CGFloat = newRect.size.height - textSize.height
        if heightDelta > 0 {
            newRect.size.height = textSize.height
            newRect.origin.y += heightDelta / 2
        }
        return newRect
    }
}
