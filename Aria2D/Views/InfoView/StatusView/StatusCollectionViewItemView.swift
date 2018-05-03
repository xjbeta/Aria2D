//
//  StatusCollectionViewItemView.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/15.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class StatusCollectionViewItemView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		if value != "" {
			drawItem()
		}
    }
	
	var value = "" {
		didSet {
			wantsLayer = true
		}
	}
	
	private func drawItem() {
		let width = frame.size.width
		let centPoint = NSPoint(x: width / 2, y: width / 2)

		let ovalPath = NSBezierPath()
		let startAngle: CGFloat = CGFloat(strtoul(value, nil, 16) * (450 - 90) / 15 + 90)
		ovalPath.appendArc(withCenter: centPoint, radius: width * sqrt(2) / 2, startAngle: startAngle, endAngle: 90, clockwise: true)
		ovalPath.line(to: centPoint)
		ovalPath.close()
		
		NSColor.purple.setFill()
		ovalPath.fill()
	}
    
    override func prepareForReuse() {
        value = "0"
//        super.prepareForReuse()
    }
    
}
