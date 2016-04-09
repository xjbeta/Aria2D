//
//  LeftSourceListView.swift
//  Aria2D
//
//  Created by xjbeta on 16/3/20.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class LeftSourceListView: NSOutlineView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override var acceptsFirstResponder: Bool {
        return false
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
    
}
