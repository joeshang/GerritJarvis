//
//  ReviewListEmptyView.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/15.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa
import SnapKit

class ReviewListEmptyView: NSView {

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var preferenceButton: NSButton!

    @IBAction func preferenceButtonClicked(_ sender: Any) {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.showPreference()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    override var allowsVibrancy: Bool {
        return true
    }

    private func setup() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        nib.instantiate(withOwner: self, topLevelObjects: nil)

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
