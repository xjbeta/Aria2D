//
//  DownloadsTableView.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class DownloadsTableView: NSTableView {

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
				NSRectFill(rect)
				drawingRow += 1
				rectOriginY += (h - r)
			}
			while rectOriginY < clipRect.size.height + y {
				((drawingRow % 2) == 0 ? color1 : color2).setFill()
				let rect = NSRect(x: clipRect.origin.x,
								  y: rectOriginY,
								  width: clipRect.size.width,
								  height: h)
				NSRectFill(rect)
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
				NSRectFill(rect)
				drawingRow -= 1
				rectOriginY = rect.origin.y
			}
			
			
			while rectOriginY > y {
				((drawingRow % 2) == 0 ? color1 : color2).setFill()
				let rect = NSRect(x: clipRect.origin.x,
				                  y: rectOriginY - h,
				                  width: clipRect.size.width,
				                  height: h)
				NSRectFill(rect)
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
				NSRectFill(rect)
				drawingRow += 1
				rectOriginY += h
			}
		}
	}
	
	
	func setRealmNotification() {
		switch ViewControllersManager.shared.selectedRow {
		case .downloading, .completed, .removed:
			setNotificationToken(DataManager.shared.data(TaskObject.self, path: nil))
		case .baidu:
			setNotificationToken(DataManager.shared.data(BaiduFileObject.self, path: Baidu.shared.selectedPath))
		default:
			break
		}
	}
	
	func initNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(changeSelectRow), name: .leftSourceListSelection, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadData), name: .refreshDownloadList, object: nil)
	}
	
	func changeSelectRow() {
		DispatchQueue.main.async {
			switch ViewControllersManager.shared.selectedRow {
			case .baidu:
				self.rowHeight = 40
			default:
				self.rowHeight = 50
				
			}
			self.setRealmNotification()
		}
	}
	
	func shouldReloadData() {
		DispatchQueue.main.async {
			self.reloadData()
		}
	}
	
	
	func setSelectedIndexs() {
		let seleectedIndexs: IndexSet = {
			
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
		ViewControllersManager.shared.selectedIndexs = seleectedIndexs
	}
	
	
	
	
	private var oldKeys: [String] = []
	private func newKeys() -> [String] {
		switch ViewControllersManager.shared.selectedRow {
		case .downloading, .completed, .removed:
			return DataManager.shared.data(TaskObject.self, path: nil).map {
				$0.gid
			}
		case .baidu:
			return DataManager.shared.data(BaiduFileObject.self, path: Baidu.shared.selectedPath).map {
				"\($0.fs_id)"
			}
		default:
			return []
		}
	}
	
	struct Move {
		let old: Int
		let new: Int
		init(_ old: Int, to new: Int) {
			self.old = old
			self.new = new
		}
	}
	
	var tableviewUpdating = false {
		didSet {
			if !tableviewUpdating, shouldUpdate {
				shouldUpdate = false
				self.updateRows()
			}
		}
	}
	var shouldUpdate = false
	
	var notificationToken: NotificationToken? = nil
	private func setNotificationToken<T: Object>(_ data: Results<T>) {
		notificationToken?.stop()

		
		notificationToken = data.addNotificationBlock {
			switch $0 {
			case .initial:
				self.reloadData()
				self.oldKeys = self.newKeys()
//			case .update(_, let deletions, let insertions, let modifications):
			case .update(_, let deletions, let insertions, _):
				
				if deletions.count == 0, insertions.count == 0 {
					return
				}
				
				if self.tableviewUpdating {
					self.shouldUpdate = true
				} else {
					self.updateRows()
				}
			case .error:
				break
			}
		}
	}
	
	

	
	func updateTableview(_ block: @escaping ((_ tableview: DownloadsTableView) -> Void)) {
		beginUpdates()
		block(self)
		endUpdates()
		setSelectedIndexs()
	}
	
	
	func updateRows() {
		tableviewUpdating = true
		var old = self.oldKeys
		let new = self.newKeys()
		
		let remove = old.enumerated().filter {
			!new.contains($0.element)
			}.map {
				$0.offset
		}
		old = old.enumerated().filter {
			!remove.contains($0.offset)
			}.map {
				$0.element
		}

		
		var move: [Move] = []
		var inserts: [Int] = []
		
		new.enumerated().forEach {
			if old.contains($0.element), let oldRow = old.index(of: $0.element), oldRow != $0.offset {
				let newRow = $0.offset
				old.remove(at: oldRow)
				old.insert($0.element, at: newRow)
				move.append(Move(oldRow, to: newRow))
			} else if !old.contains($0.element) {
				old.insert($0.element, at: $0.offset)
				inserts.append($0.offset)
			}
		}
		
		NSAnimationContext.runAnimationGroup({
			$0.duration = 0.3
			self.updateTableview { tableview in
				tableview.removeRows(at: IndexSet(remove), withAnimation: [.effectFade])
				move.forEach {
					tableview.moveRow(at: $0.old, to: $0.new)
				}
				tableview.insertRows(at: IndexSet(inserts), withAnimation: [.effectFade])
			}
		}) {
			self.oldKeys = new
			self.tableviewUpdating = false
		}
		
	}

    deinit {
		notificationToken?.stop()
		NotificationCenter.default.removeObserver(self)
    }
}
