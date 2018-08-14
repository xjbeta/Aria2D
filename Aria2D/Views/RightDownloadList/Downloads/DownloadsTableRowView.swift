//
//  DownloadsTableRowView.swift
//  Aria2D
//
//  Created by xjbeta on 2016/9/25.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class DownloadsTableRowView: NSTableRowView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
	
	override var isOpaque: Bool {
		return true
	}
	
	override func drawSelection(in dirtyRect: NSRect) {
		if selectionHighlightStyle != .none {
			let selectionRect = NSInsetRect(self.bounds, 0.5, 0.5)
			
//			NSColor(calibratedWhite: 0.65, alpha: 1.0).setStroke()
//			NSColor(calibratedRed: 0.72, green: 0.79, blue: 0.94, alpha: 1).setFill()
			NSColor.customHightlightColor.setFill()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
			selectionPath.fill()
//			selectionPath.stroke()
		}
		
	}
	
	let defaultRowColor = NSColor(catalogName: "System", colorName: "controlAlternatingRowColor")
	
	override var backgroundColor: NSColor {
		didSet {
			if backgroundColor == defaultRowColor {
				backgroundColor = NSColor.customBackgroundColor
			}
		}
	}
	
	override func drawBackground(in dirtyRect: NSRect) {
		if backgroundColor == defaultRowColor {
			backgroundColor = NSColor.customBackgroundColor
		}
		super.drawBackground(in: dirtyRect)
	}
	
	
}
