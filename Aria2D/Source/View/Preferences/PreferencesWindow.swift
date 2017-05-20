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
		//Set color
		window?.backgroundColor = .customBackgroundColor
		window?.contentView?.wantsLayer = true
    }
	


}
