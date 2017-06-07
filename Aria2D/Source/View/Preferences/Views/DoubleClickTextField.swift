//
//  DoubleClickTextField.swift
//  Aria2D
//
//  Created by xjbeta on 2017/4/8.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class DoubleClickTextField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
	
	override func mouseUp(with event: NSEvent) {
		if event.clickCount == 2 {
			let pasteboard = NSPasteboard.general
			pasteboard.clearContents()
			pasteboard.writeObjects([stringValue as NSString])
		} else {
			super.mouseUp(with: event)
		}
	}
	
}
