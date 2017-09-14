//
//  ViewForImage.swift
//  Aria2D
//
//  Created by xjbeta on 16/9/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class ViewForImage: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		setImage()
    }
	
	
	func setImage() {
		switch ViewControllersManager.shared.selectedRow {
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
	
	
	// 48 x 48
	
	
	func setImageForDownloading() {
		
		
		//// Color Declarations
		let color = NSColor.white
		
		//// Bezier Drawing
		let bezierPath = NSBezierPath()

		bezierPath.move(to: NSMakePoint(38, 30))
		bezierPath.line(to: NSMakePoint(30, 30))
		bezierPath.line(to: NSMakePoint(30, 42))
		bezierPath.line(to: NSMakePoint(18, 42))
		bezierPath.line(to: NSMakePoint(18, 30))
		bezierPath.line(to: NSMakePoint(10, 30))
		bezierPath.line(to: NSMakePoint(24, 16))
		bezierPath.line(to: NSMakePoint(38, 30))
		bezierPath.close()
		bezierPath.move(to: NSMakePoint(10, 12))
		bezierPath.line(to: NSMakePoint(10, 8))
		bezierPath.line(to: NSMakePoint(38, 8))
		bezierPath.line(to: NSMakePoint(38, 12))
		bezierPath.line(to: NSMakePoint(10, 12))
		bezierPath.close()
		bezierPath.miterLimit = 4
		color.setFill()
		bezierPath.fill()
	}
	
	func setImageForCompleted() {
		
		//// Color Declarations
		let fillColor = NSColor.white
		
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSMakePoint(36, 34))
		bezierPath.line(to: NSMakePoint(33.18, 36.82))
		bezierPath.line(to: NSMakePoint(20.5, 24.14))
		bezierPath.line(to: NSMakePoint(23.32, 21.32))
		bezierPath.line(to: NSMakePoint(36, 34))
		bezierPath.close()
		bezierPath.move(to: NSMakePoint(44.48, 36.82))
		bezierPath.line(to: NSMakePoint(23.32, 15.66))
		bezierPath.line(to: NSMakePoint(14.96, 24))
		bezierPath.line(to: NSMakePoint(12.14, 21.18))
		bezierPath.line(to: NSMakePoint(23.32, 10))
		bezierPath.line(to: NSMakePoint(47.32, 34))
		bezierPath.line(to: NSMakePoint(44.48, 36.82))
		bezierPath.close()
		bezierPath.move(to: NSMakePoint(0.82, 21.18))
		bezierPath.line(to: NSMakePoint(12, 10))
		bezierPath.line(to: NSMakePoint(14.82, 12.82))
		bezierPath.line(to: NSMakePoint(3.66, 24))
		bezierPath.line(to: NSMakePoint(0.82, 21.18))
		bezierPath.close()
		bezierPath.miterLimit = 4
		fillColor.setFill()
		bezierPath.fill()

	}
	
	
	func setImageForRemoved() {
		
		
		//// Color Declarations
//		let fillColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
		let fillColor = NSColor.white
		
		//// Group 2
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSMakePoint(30, 16))
		bezierPath.line(to: NSMakePoint(38, 16))
		bezierPath.line(to: NSMakePoint(38, 12))
		bezierPath.line(to: NSMakePoint(30, 12))
		bezierPath.line(to: NSMakePoint(30, 16))
		bezierPath.close()
		bezierPath.move(to: NSMakePoint(30, 32))
		bezierPath.line(to: NSMakePoint(44, 32))
		bezierPath.line(to: NSMakePoint(44, 28))
		bezierPath.line(to: NSMakePoint(30, 28))
		bezierPath.line(to: NSMakePoint(30, 32))
		bezierPath.close()
		bezierPath.move(to: NSMakePoint(30, 24))
		bezierPath.line(to: NSMakePoint(42, 24))
		bezierPath.line(to: NSMakePoint(42, 20))
		bezierPath.line(to: NSMakePoint(30, 20))
		bezierPath.line(to: NSMakePoint(30, 24))
		bezierPath.close()
		bezierPath.move(to: NSMakePoint(6, 12))
		bezierPath.curve(to: NSMakePoint(10, 8), controlPoint1: NSMakePoint(6, 9.8), controlPoint2: NSMakePoint(7.8, 8))
		bezierPath.line(to: NSMakePoint(22, 8))
		bezierPath.curve(to: NSMakePoint(26, 12), controlPoint1: NSMakePoint(24.2, 8), controlPoint2: NSMakePoint(26, 9.8))
		bezierPath.line(to: NSMakePoint(26, 32))
		bezierPath.line(to: NSMakePoint(6, 32))
		bezierPath.line(to: NSMakePoint(6, 12))
		bezierPath.close()
		bezierPath.move(to: NSMakePoint(28, 38))
		bezierPath.line(to: NSMakePoint(22, 38))
		bezierPath.line(to: NSMakePoint(20, 40))
		bezierPath.line(to: NSMakePoint(12, 40))
		bezierPath.line(to: NSMakePoint(10, 38))
		bezierPath.line(to: NSMakePoint(4, 38))
		bezierPath.line(to: NSMakePoint(4, 34))
		bezierPath.line(to: NSMakePoint(28, 34))
		bezierPath.line(to: NSMakePoint(28, 38))
		bezierPath.close()
		bezierPath.miterLimit = 4
		fillColor.setFill()
		bezierPath.fill()
	}
	
	
	func setImageForBaidu() {
		
		
		//// Color Declarations
		let fillColor = NSColor.white
		
		//// Oval Drawing
		let ovalPath = NSBezierPath(ovalIn: NSMakeRect(4, 24, 10, 10))
		fillColor.setFill()
		ovalPath.fill()
		
		
		//// Oval 2 Drawing
		let oval2Path = NSBezierPath(ovalIn: NSMakeRect(13, 32, 10, 10))
		fillColor.setFill()
		oval2Path.fill()
		
		
		//// Oval 3 Drawing
		let oval3Path = NSBezierPath(ovalIn: NSMakeRect(25, 32, 10, 10))
		fillColor.setFill()
		oval3Path.fill()
		
		
		//// Oval 4 Drawing
		let oval4Path = NSBezierPath(ovalIn: NSMakeRect(34, 24, 10, 10))
		fillColor.setFill()
		oval4Path.fill()
		
		
		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSMakePoint(34.68, 18.28))
		bezierPath.curve(to: NSMakePoint(29.72, 24.1), controlPoint1: NSMakePoint(32.94, 20.32), controlPoint2: NSMakePoint(31.48, 22.06))
		bezierPath.curve(to: NSMakePoint(26.22, 26.74), controlPoint1: NSMakePoint(28.8, 25.18), controlPoint2: NSMakePoint(27.62, 26.26))
		bezierPath.curve(to: NSMakePoint(25.56, 26.92), controlPoint1: NSMakePoint(26, 26.82), controlPoint2: NSMakePoint(25.78, 26.88))
		bezierPath.curve(to: NSMakePoint(24, 27), controlPoint1: NSMakePoint(25.06, 27), controlPoint2: NSMakePoint(24.52, 27))
		bezierPath.curve(to: NSMakePoint(22.42, 26.9), controlPoint1: NSMakePoint(23.48, 27), controlPoint2: NSMakePoint(22.94, 27))
		bezierPath.curve(to: NSMakePoint(21.76, 26.72), controlPoint1: NSMakePoint(22.2, 26.86), controlPoint2: NSMakePoint(21.98, 26.8))
		bezierPath.curve(to: NSMakePoint(18.26, 24.08), controlPoint1: NSMakePoint(20.36, 26.24), controlPoint2: NSMakePoint(19.2, 25.16))
		bezierPath.curve(to: NSMakePoint(13.29, 18.26), controlPoint1: NSMakePoint(16.52, 22.04), controlPoint2: NSMakePoint(15.06, 20.3))
		bezierPath.curve(to: NSMakePoint(8.05, 8.69), controlPoint1: NSMakePoint(10.67, 15.64), controlPoint2: NSMakePoint(7.45, 12.75))
		bezierPath.curve(to: NSMakePoint(12.71, 4.05), controlPoint1: NSMakePoint(8.63, 6.65), controlPoint2: NSMakePoint(10.09, 4.63))
		bezierPath.curve(to: NSMakePoint(23.8, 4.93), controlPoint1: NSMakePoint(14.17, 3.75), controlPoint2: NSMakePoint(18.84, 4.93))
		bezierPath.line(to: NSMakePoint(24.16, 4.93))
		bezierPath.curve(to: NSMakePoint(35.24, 4.05), controlPoint1: NSMakePoint(29.12, 4.93), controlPoint2: NSMakePoint(33.78, 3.77))
		bezierPath.curve(to: NSMakePoint(39.9, 8.69), controlPoint1: NSMakePoint(37.86, 4.63), controlPoint2: NSMakePoint(39.32, 6.67))
		bezierPath.curve(to: NSMakePoint(34.68, 18.28), controlPoint1: NSMakePoint(40.52, 12.77), controlPoint2: NSMakePoint(37.3, 15.66))
		bezierPath.close()
		bezierPath.miterLimit = 4
		fillColor.setFill()
		bezierPath.fill()

	}
	
	
    
}
