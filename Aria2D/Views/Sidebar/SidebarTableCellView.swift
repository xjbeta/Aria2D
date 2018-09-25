//
//  SidebarTableCellView.swift
//  Aria2D
//
//  Created by xjbeta on 16/9/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class SidebarTableCellView: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    var isSelected = false {
        didSet {
            setImage(item)
        }
    }
    
    var isMouseInside = false {
        didSet {
            setImage(item)
        }
    }
    
    var item: SidebarItem = .none {
        didSet {
            setImage(item)
        }
    }
    
    func setImage(_ item: SidebarItem) {
        imageView?.image = nil
        guard let image = NSImage(named: item.rawValue)?.copy() as? NSImage else {
            return
        }
        image.size = NSSize(width: 36, height: 36)
        image.isTemplate = false
        image.lockFocus()
        let rect = NSRect(origin: .zero, size: image.size)
        fillColor.set()
        rect.fill(using: .sourceAtop)
        image.unlockFocus()
        imageView?.image = image
    }
	
	override func mouseEntered(with event: NSEvent) {
		isMouseInside = true
	}
	
	override func mouseExited(with event: NSEvent) {
		isMouseInside = false
	}
	
	override func updateTrackingAreas() {
		trackingAreas.forEach {
			removeTrackingArea($0)
		}
		addTrackingArea(NSTrackingArea(rect: bounds,
		                               options: [.mouseEnteredAndExited, .activeInActiveApp, .mouseMoved],
		                               owner: self,
		                               userInfo: nil))
	}
	
    var fillColor: NSColor {
        get {
            return isSelected || isMouseInside ? NSColor.labelColor : NSColor.secondaryLabelColor
        }
    }
}
