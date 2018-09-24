//
//  MainListTableView.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class MainListTableView: NSTableView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    override var mouseDownCanMoveWindow: Bool {
        return true
    }
	
	override func drawBackground(inClipRect clipRect: NSRect) {
		let h = rowHeight + intercellSpacing.height
		
		let color1 = NSColor.white
		let color2 = NSColor.customBackgroundColor
		
		switch clipRect.origin.y {
		case let y where y > 0 :
			let r = y.truncatingRemainder(dividingBy: h)
			var drawingRow = Int(y / h)
			var rectOriginY: CGFloat = y
			
			if r != 0 {
				((drawingRow % 2) == 0 ? color1 : color2).setFill()
				let rect = NSRect(x: clipRect.origin.x,
				                  y: rectOriginY,
				                  width: clipRect.size.width,
				                  height: h - r)
				rect.fill()
				drawingRow += 1
				rectOriginY += (h - r)
			}
			while rectOriginY < clipRect.size.height + y {
				((drawingRow % 2) == 0 ? color1 : color2).setFill()
				let rect = NSRect(x: clipRect.origin.x,
								  y: rectOriginY,
								  width: clipRect.size.width,
								  height: h)
				rect.fill()
				drawingRow += 1
				rectOriginY += h
			}
			
			
			
		case let y where y < 0 :
			let r = (y + clipRect.size.height).truncatingRemainder(dividingBy: h)
			var drawingRow = Int((y + clipRect.size.height) / h) - 1
			var rectOriginY: CGFloat = y + clipRect.size.height
			if r != 0 {
				((drawingRow % 2) == 0 ? color1 : color2).setFill()
				let rect = NSRect(x: clipRect.origin.x,
				                  y: rectOriginY - (h + r),
				                  width: clipRect.size.width,
				                  height: h + r)
				rect.fill()
				drawingRow -= 1
				rectOriginY = rect.origin.y
			}
			
			
			while rectOriginY > y {
				((drawingRow % 2) == 0 ? color1 : color2).setFill()
				let rect = NSRect(x: clipRect.origin.x,
				                  y: rectOriginY - h,
				                  width: clipRect.size.width,
				                  height: h)
				rect.fill()
				drawingRow -= 1
				rectOriginY -= h
			}
			
		default:
			let heightOfRows = CGFloat(numberOfRows) * h
			var rectOriginY = heightOfRows
			var drawingRow = numberOfRows
			
			while rectOriginY < clipRect.size.height {
				((drawingRow % 2) == 0 ? color1 : color2).setFill()
				let rect = NSRect(x: 0, y: rectOriginY, width: clipRect.size.width, height: h)
				rect.fill()
				drawingRow += 1
				rectOriginY += h
			}
		}
	}
	
	

	
	
	func setSelectedIndexs() {
		let selectedIndexs: IndexSet = {
			if clickedRow != -1 {
				if selectedRowIndexes.contains(clickedRow) {
					return selectedRowIndexes
				} else {
					return IndexSet(integer: clickedRow)
				}
			} else {
				return selectedRowIndexes
			}
		}()
		
		ViewControllersManager.shared.selectedIndexs = selectedIndexs
	}
	
	

}
