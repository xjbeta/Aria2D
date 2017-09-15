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
		setImage(item)
    }
	
	var isSelected = false {
		didSet {

			needsDisplay = true
		}
	}
	
	var isMouseInside = false {
		didSet {
			needsDisplay = true
		}
	}
	
	var item: SidebarItem = .none {
		didSet {
			needsDisplay = true
		}
	}
	
	func setImage(_ item: SidebarItem) {
		switch item {
		case .downloading:
			setImageForDownloading()
		case .completed:
			setImageForCompleted()
		case .removed:
			setImageForRemoved()
		case .baidu:
			setImageForBaidu()
		default:
			break
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
	
	
	var fillColor: NSColor {
		get {
			return isSelected || isMouseInside ? NSColor.highlightColor : NSColor.lightGray
		}
	}
	
	
	// 36 x 36
	func setImageForDownloading() {
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSPoint(x: 30, y: 21.86))
		bezierPath.line(to: NSPoint(x: 23.14, y: 21.86))
		bezierPath.line(to: NSPoint(x: 23.14, y: 32.15))
		bezierPath.line(to: NSPoint(x: 12.86, y: 32.15))
		bezierPath.line(to: NSPoint(x: 12.86, y: 21.86))
		bezierPath.line(to: NSPoint(x: 6, y: 21.86))
		bezierPath.line(to: NSPoint(x: 18, y: 9.86))
		bezierPath.line(to: NSPoint(x: 30, y: 21.86))
		bezierPath.close()
		bezierPath.move(to: NSPoint(x: 6, y: 6.43))
		bezierPath.line(to: NSPoint(x: 6, y: 3))
		bezierPath.line(to: NSPoint(x: 30, y: 3))
		bezierPath.line(to: NSPoint(x: 30, y: 6.43))
		bezierPath.line(to: NSPoint(x: 6, y: 6.43))
		bezierPath.close()
		fillColor.setFill()
		bezierPath.fill()


	}
	
	func setImageForCompleted() {
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSPoint(x: 27, y: 25.5))
		bezierPath.line(to: NSPoint(x: 24.88, y: 27.62))
		bezierPath.line(to: NSPoint(x: 15.37, y: 18.11))
		bezierPath.line(to: NSPoint(x: 17.49, y: 15.99))
		bezierPath.line(to: NSPoint(x: 27, y: 25.5))
		bezierPath.close()
		bezierPath.move(to: NSPoint(x: 33.36, y: 27.62))
		bezierPath.line(to: NSPoint(x: 17.49, y: 11.75))
		bezierPath.line(to: NSPoint(x: 11.22, y: 18))
		bezierPath.line(to: NSPoint(x: 9.1, y: 15.89))
		bezierPath.line(to: NSPoint(x: 17.49, y: 7.5))
		bezierPath.line(to: NSPoint(x: 35.49, y: 25.5))
		bezierPath.line(to: NSPoint(x: 33.36, y: 27.62))
		bezierPath.close()
		bezierPath.move(to: NSPoint(x: 0.61, y: 15.89))
		bezierPath.line(to: NSPoint(x: 9, y: 7.5))
		bezierPath.line(to: NSPoint(x: 11.11, y: 9.62))
		bezierPath.line(to: NSPoint(x: 2.74, y: 18))
		bezierPath.line(to: NSPoint(x: 0.61, y: 15.89))
		bezierPath.close()
		fillColor.setFill()
		bezierPath.fill()



	}
	
	
	func setImageForRemoved() {
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSPoint(x: 7.71, y: 6.43))
		bezierPath.curve(to: NSPoint(x: 11.14, y: 3), controlPoint1: NSPoint(x: 7.71, y: 4.54), controlPoint2: NSPoint(x: 9.26, y: 3))
		bezierPath.line(to: NSPoint(x: 24.86, y: 3))
		bezierPath.curve(to: NSPoint(x: 28.29, y: 6.43), controlPoint1: NSPoint(x: 26.74, y: 3), controlPoint2: NSPoint(x: 28.29, y: 4.54))
		bezierPath.line(to: NSPoint(x: 28.29, y: 27))
		bezierPath.line(to: NSPoint(x: 7.71, y: 27))
		bezierPath.line(to: NSPoint(x: 7.71, y: 6.43))
		bezierPath.close()
		bezierPath.move(to: NSPoint(x: 11.93, y: 18.63))
		bezierPath.line(to: NSPoint(x: 14.35, y: 21.05))
		bezierPath.line(to: NSPoint(x: 18, y: 17.42))
		bezierPath.line(to: NSPoint(x: 21.63, y: 21.05))
		bezierPath.line(to: NSPoint(x: 24.05, y: 18.63))
		bezierPath.line(to: NSPoint(x: 20.42, y: 15))
		bezierPath.line(to: NSPoint(x: 24.05, y: 11.37))
		bezierPath.line(to: NSPoint(x: 21.63, y: 8.95))
		bezierPath.line(to: NSPoint(x: 18, y: 12.58))
		bezierPath.line(to: NSPoint(x: 14.37, y: 8.95))
		bezierPath.line(to: NSPoint(x: 11.95, y: 11.37))
		bezierPath.line(to: NSPoint(x: 15.58, y: 15))
		bezierPath.line(to: NSPoint(x: 11.93, y: 18.63))
		bezierPath.close()
		bezierPath.move(to: NSPoint(x: 24, y: 32.14))
		bezierPath.line(to: NSPoint(x: 22.29, y: 33.86))
		bezierPath.line(to: NSPoint(x: 13.71, y: 33.86))
		bezierPath.line(to: NSPoint(x: 12, y: 32.14))
		bezierPath.line(to: NSPoint(x: 6, y: 32.14))
		bezierPath.line(to: NSPoint(x: 6, y: 28.71))
		bezierPath.line(to: NSPoint(x: 30, y: 28.71))
		bezierPath.line(to: NSPoint(x: 30, y: 32.14))
		bezierPath.line(to: NSPoint(x: 24, y: 32.14))
		bezierPath.close()
		fillColor.setFill()
		bezierPath.fill()


	}
	
	
	func setImageForBaidu() {
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSPoint(x: 10.5, y: 21.75))
		bezierPath.curve(to: NSPoint(x: 6.75, y: 18), controlPoint1: NSPoint(x: 10.5, y: 19.25), controlPoint2: NSPoint(x: 9.25, y: 18))
		bezierPath.curve(to: NSPoint(x: 3, y: 21.75), controlPoint1: NSPoint(x: 4.25, y: 18), controlPoint2: NSPoint(x: 3, y: 19.25))
		bezierPath.curve(to: NSPoint(x: 6.75, y: 25.5), controlPoint1: NSPoint(x: 3, y: 24.25), controlPoint2: NSPoint(x: 4.25, y: 25.5))
		bezierPath.curve(to: NSPoint(x: 10.5, y: 21.75), controlPoint1: NSPoint(x: 9.25, y: 25.5), controlPoint2: NSPoint(x: 10.5, y: 24.25))
		bezierPath.close()
		fillColor.setFill()
		bezierPath.fill()
		
		
		//// Bezier 2 Drawing
		let bezier2Path = NSBezierPath()
		bezier2Path.move(to: NSPoint(x: 17.25, y: 27.75))
		bezier2Path.curve(to: NSPoint(x: 13.5, y: 24), controlPoint1: NSPoint(x: 17.25, y: 25.25), controlPoint2: NSPoint(x: 16, y: 24))
		bezier2Path.curve(to: NSPoint(x: 9.75, y: 27.75), controlPoint1: NSPoint(x: 11, y: 24), controlPoint2: NSPoint(x: 9.75, y: 25.25))
		bezier2Path.curve(to: NSPoint(x: 13.5, y: 31.5), controlPoint1: NSPoint(x: 9.75, y: 30.25), controlPoint2: NSPoint(x: 11, y: 31.5))
		bezier2Path.curve(to: NSPoint(x: 17.25, y: 27.75), controlPoint1: NSPoint(x: 16, y: 31.5), controlPoint2: NSPoint(x: 17.25, y: 30.25))
		bezier2Path.close()
		fillColor.setFill()
		bezier2Path.fill()
		
		
		//// Bezier 3 Drawing
		let bezier3Path = NSBezierPath()
		bezier3Path.move(to: NSPoint(x: 26.25, y: 27.75))
		bezier3Path.curve(to: NSPoint(x: 22.5, y: 24), controlPoint1: NSPoint(x: 26.25, y: 25.25), controlPoint2: NSPoint(x: 25, y: 24))
		bezier3Path.curve(to: NSPoint(x: 18.75, y: 27.75), controlPoint1: NSPoint(x: 20, y: 24), controlPoint2: NSPoint(x: 18.75, y: 25.25))
		bezier3Path.curve(to: NSPoint(x: 22.5, y: 31.5), controlPoint1: NSPoint(x: 18.75, y: 30.25), controlPoint2: NSPoint(x: 20, y: 31.5))
		bezier3Path.curve(to: NSPoint(x: 26.25, y: 27.75), controlPoint1: NSPoint(x: 25, y: 31.5), controlPoint2: NSPoint(x: 26.25, y: 30.25))
		bezier3Path.close()
		fillColor.setFill()
		bezier3Path.fill()
		
		
		//// Bezier 4 Drawing
		let bezier4Path = NSBezierPath()
		bezier4Path.move(to: NSPoint(x: 33, y: 21.75))
		bezier4Path.curve(to: NSPoint(x: 29.25, y: 18), controlPoint1: NSPoint(x: 33, y: 19.25), controlPoint2: NSPoint(x: 31.75, y: 18))
		bezier4Path.curve(to: NSPoint(x: 25.5, y: 21.75), controlPoint1: NSPoint(x: 26.75, y: 18), controlPoint2: NSPoint(x: 25.5, y: 19.25))
		bezier4Path.curve(to: NSPoint(x: 29.25, y: 25.5), controlPoint1: NSPoint(x: 25.5, y: 24.25), controlPoint2: NSPoint(x: 26.75, y: 25.5))
		bezier4Path.curve(to: NSPoint(x: 33, y: 21.75), controlPoint1: NSPoint(x: 31.75, y: 25.5), controlPoint2: NSPoint(x: 33, y: 24.25))
		bezier4Path.close()
		fillColor.setFill()
		bezier4Path.fill()
		
		
		//// Bezier 5 Drawing
		let bezier5Path = NSBezierPath()
		bezier5Path.move(to: NSPoint(x: 26.01, y: 13.71))
		bezier5Path.curve(to: NSPoint(x: 22.29, y: 18.08), controlPoint1: NSPoint(x: 24.7, y: 15.24), controlPoint2: NSPoint(x: 23.61, y: 16.55))
		bezier5Path.curve(to: NSPoint(x: 19.66, y: 20.06), controlPoint1: NSPoint(x: 21.6, y: 18.89), controlPoint2: NSPoint(x: 20.71, y: 19.7))
		bezier5Path.curve(to: NSPoint(x: 19.17, y: 20.19), controlPoint1: NSPoint(x: 19.5, y: 20.12), controlPoint2: NSPoint(x: 19.33, y: 20.16))
		bezier5Path.curve(to: NSPoint(x: 18, y: 20.25), controlPoint1: NSPoint(x: 18.79, y: 20.25), controlPoint2: NSPoint(x: 18.39, y: 20.25))
		bezier5Path.curve(to: NSPoint(x: 16.82, y: 20.18), controlPoint1: NSPoint(x: 17.61, y: 20.25), controlPoint2: NSPoint(x: 17.21, y: 20.25))
		bezier5Path.curve(to: NSPoint(x: 16.32, y: 20.04), controlPoint1: NSPoint(x: 16.65, y: 20.15), controlPoint2: NSPoint(x: 16.49, y: 20.1))
		bezier5Path.curve(to: NSPoint(x: 13.7, y: 18.06), controlPoint1: NSPoint(x: 15.27, y: 19.68), controlPoint2: NSPoint(x: 14.4, y: 18.87))
		bezier5Path.curve(to: NSPoint(x: 9.98, y: 13.7), controlPoint1: NSPoint(x: 12.39, y: 16.53), controlPoint2: NSPoint(x: 11.3, y: 15.23))
		bezier5Path.curve(to: NSPoint(x: 6.05, y: 6.51), controlPoint1: NSPoint(x: 8.01, y: 11.73), controlPoint2: NSPoint(x: 5.6, y: 9.56))
		bezier5Path.curve(to: NSPoint(x: 9.54, y: 3.03), controlPoint1: NSPoint(x: 6.48, y: 4.98), controlPoint2: NSPoint(x: 7.58, y: 3.47))
		bezier5Path.curve(to: NSPoint(x: 17.85, y: 3.69), controlPoint1: NSPoint(x: 10.64, y: 2.81), controlPoint2: NSPoint(x: 14.13, y: 3.69))
		bezier5Path.line(to: NSPoint(x: 18.12, y: 3.69))
		bezier5Path.curve(to: NSPoint(x: 26.43, y: 3.03), controlPoint1: NSPoint(x: 21.84, y: 3.69), controlPoint2: NSPoint(x: 25.34, y: 2.82))
		bezier5Path.curve(to: NSPoint(x: 29.93, y: 6.51), controlPoint1: NSPoint(x: 28.4, y: 3.47), controlPoint2: NSPoint(x: 29.49, y: 5))
		bezier5Path.curve(to: NSPoint(x: 26.01, y: 13.71), controlPoint1: NSPoint(x: 30.39, y: 9.57), controlPoint2: NSPoint(x: 27.98, y: 11.75))
		bezier5Path.line(to: NSPoint(x: 26.01, y: 13.71))
		bezier5Path.close()
		fillColor.setFill()
		bezier5Path.fill()


	}
    
}
