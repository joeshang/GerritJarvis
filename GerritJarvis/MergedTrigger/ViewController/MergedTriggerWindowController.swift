//
//  MergedTriggerWindowController.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/25.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class MergedTriggerWindowController: NSWindowController {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var reviewLabel: NSTextField!
    @IBOutlet weak var shellSelectButton: NSPopUpButton!
    @IBOutlet var commandTextView: PasteTextView!

    var change: Change!

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        var text = ""
        if let name = change.owner?.name {
            text += name
        }
        if let project = change.project {
            text += "  " + project
        }
        if let branch = change.branch {
            text += "  " + branch
        }
        nameLabel.stringValue = text
        reviewLabel.stringValue = change.subject ?? ""
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
    }

    @IBAction func shellSelectClicked(_ sender: Any) {
    }

}
