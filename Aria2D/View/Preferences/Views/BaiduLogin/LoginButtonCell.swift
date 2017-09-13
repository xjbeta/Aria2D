//
//  LoginButtonCell.swift
//  Aria2D
//
//  Created by xjbeta on 16/9/9.
//  Copyright © 2016年 xjbeta. All rights reserved.
import Cocoa

class LoginButtonCell: NSButtonCell {
	
	override func titleRect(forBounds theRect: NSRect) -> NSRect {
		if title == loginButtonTitles.setPCS.rawValue {
			return NSRect(x: 0, y: 15, width: 70, height: 13)
		} else {
			return NSRect(x: 0, y: 42, width: 70, height: 13)
		}
	}
	
	
	override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
		return super.drawTitle(setCustomTitle(title.string), withFrame: frame, in: controlView)
	}
	
	
	func setDefaultImage() {
		let defaultUserImage = NSImage(named: NSImage.Name(rawValue: "DefaultUserImage"))
		
		defaultUserImage?.size = NSSize(width: 70, height: 70)
		image = defaultUserImage
	}
	
	func setCustomTitle(_ title: String) -> NSAttributedString {
		let pstyle = NSMutableParagraphStyle()
		pstyle.alignment = .center
		var font = NSFont()
		font = NSFont.systemFont(ofSize: 13, weight: NSFont.Weight.semibold)
		return NSAttributedString(string: title, attributes:[NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.paragraphStyle: pstyle, NSAttributedStringKey.font: font])
	}
}
