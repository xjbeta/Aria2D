//
//  FeaturesTextField.swift
//  Aria2D
//
//  Created by xjbeta on 2017/6/15.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class FeaturesTextField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
	
	override func mouseDown(with event: NSEvent) {
		if event.clickCount == 2 {
			if alphaValue == 0 {
				animator().alphaValue = 1
			} else {
				animator().alphaValue = 0
			}
		} else {
			super.mouseUp(with: event)
		}
	}
	
	
}
