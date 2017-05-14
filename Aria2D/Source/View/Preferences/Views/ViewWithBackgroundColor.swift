//
//  ViewWithBackgroundColor.swift
//  Aria2D
//
//  Created by xjbeta on 16/9/10.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class ViewWithBackgroundColor: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		NSColor.white.setFill()
		NSRectFill(dirtyRect)
    }
}
