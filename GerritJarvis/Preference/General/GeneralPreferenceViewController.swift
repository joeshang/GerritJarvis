//
//  GeneralPreferenceViewController.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/14.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa
import Preferences

class GeneralPreferenceViewController: NSViewController, PreferencePane {

    let preferencePaneIdentifier = PreferencePane.Identifier.general
    let preferencePaneTitle = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
