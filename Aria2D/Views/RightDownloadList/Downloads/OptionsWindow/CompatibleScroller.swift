//
//  CompatibleScroller.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/17.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class CompatibleScroller: NSScroller {

    override func draw(_ dirtyRect: NSRect) {
		self.drawKnob()
    }
	
	func isCompatibleWithOverlayScrollers() -> Bool {
		return false
	}
	
}
