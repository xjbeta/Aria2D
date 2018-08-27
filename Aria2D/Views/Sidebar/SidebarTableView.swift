//
//  SidebarTableView.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/24.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class SidebarTableView: NSTableView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
	
	
	override func becomeFirstResponder() -> Bool {
		return false
	}
	
	override var mouseDownCanMoveWindow: Bool {
		return true
	}

}
