//
//  MainSplitView.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/30.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainSplitView: NSSplitView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
}
