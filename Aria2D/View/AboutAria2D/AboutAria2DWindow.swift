//
//  AboutAria2DWindow.swift
//  Aria2D
//
//  Created by xjbeta on 2016/10/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class AboutAria2DWindow: NSWindowController {
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		window?.titlebarAppearsTransparent = true
		window?.titleVisibility = .hidden
		window?.isMovableByWindowBackground = true
		//Set color
		window?.backgroundColor = NSColor.white
		window?.contentView?.wantsLayer = true
	}
	
}
