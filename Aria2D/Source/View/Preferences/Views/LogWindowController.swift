//
//  LogWindowController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/4/18.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class LogWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
		if let window = window {
			window.titlebarAppearsTransparent = true
			window.titleVisibility = .hidden
			window.isMovableByWindowBackground = true
		}
    }

}
