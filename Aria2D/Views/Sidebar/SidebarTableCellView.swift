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
        var image = NSImage(named: item.rawValue)
        if #available(OSX 10.14, *) {
            imageView?.image = image
            imageView?.contentTintColor = isSelected || isMouseInside ? .systemBlue : .tertiaryLabelColor
        } else {
            image = image?.tint(color: isSelected || isMouseInside ? .systemBlue : .tertiaryLabelColor)
            imageView?.image = image
        }
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
}


extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}
