//
//  StatusDicTableCellView.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/11.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class StatusDicTableCellView: NSTableCellView {
	
	@IBOutlet var keyTextField: NSTextField!
	@IBOutlet var valueTextField: NSTextField!
	
	override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
