//
//  PreferencesWindow.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/29.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
        window?.titleVisibility = .hidden
        if let preferencesTabVC = contentViewController as? PreferencesTabViewController {
            preferencesTabVC.autoResizeWindow(preferencesTabVC.tabView.selectedTabViewItem, animate: false)
            preferencesTabVC.tabViewItems.filter {
                $0.label == "Aria2Options"
            }.first?.image = NSWorkspace.shared.icon(forFile: "/usr/bin/cd")
        }
    }
}
