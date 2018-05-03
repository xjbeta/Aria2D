//
//  InfoView.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/8.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class InfoView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		NSColor.customBackgroundColor.setFill()
        dirtyRect.fill()
    }
    
}
