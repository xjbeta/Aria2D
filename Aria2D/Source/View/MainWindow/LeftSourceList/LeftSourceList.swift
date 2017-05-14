//
//  LeftSourceList.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class LeftSourceList: NSViewController {
	
	@IBOutlet var visualEffect: NSVisualEffectView!
	
	@IBOutlet var leftSourceList: LeftSourceListView!
	
	@IBOutlet var viewForImage: ViewForImage!
	@IBOutlet var progressIndicator: NSProgressIndicator!
	
	
	let showNewTaskViewController = "showNewTaskViewController"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		visualEffect.material = .ultraDark
		initIndicator()
		leftSourceList.setDefaultData()
		leftSourceList.initNotification()
		
		NotificationCenter.default.addObserver(self, selector: #selector(showNewTask), name: .newTask, object: nil)
	}
	
	
	func initIndicator() {
		progressIndicator.isHidden = !ViewControllersManager.shared.waiting
		progressIndicator.startAnimation(self)
		ViewControllersManager.shared.updateIndicator = {
			DispatchQueue.main.async {
				self.progressIndicator.isHidden = !ViewControllersManager.shared.waiting
			}
		}
	}
	
	
	
	func showNewTask() {
		if Aria2Websocket.shared.isConnected {
			performSegue(withIdentifier: showNewTaskViewController, sender: self)
		}
	}
	
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		viewForImage.needsDisplay = true
		visualEffect.needsDisplay = true
		switch leftSourceList.selectedRow {
		case 0:
			ViewControllersManager.shared.selectedRow = .downloading
		case 1:
			ViewControllersManager.shared.selectedRow = .completed
		case 2:
			ViewControllersManager.shared.selectedRow = .removed
		case 3:
			ViewControllersManager.shared.selectedRow = .baidu
		default:
			ViewControllersManager.shared.selectedRow = .none
		}
		NotificationCenter.default.post(name: .leftSourceListSelection, object: nil)
	}
	
	
	
}

// MARK: - NSOutlineViewDelegate
extension LeftSourceList: NSOutlineViewDelegate {
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if let item = item as? LeftSourceListBaseObject,
			let view = outlineView.make(withIdentifier: item.cellID, owner: self) as? NSTableCellView{
			
			view.textField?.stringValue = item.name
			view.imageView?.image = item.icon
			return view
		}
		return nil
	}
	
	
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		return item is LeftSourceListNode
	}
	
	
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		return !self.outlineView(outlineView, isGroupItem: item)
	}
	
	func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		return item is LeftSourceListNode ? 17 : 40
	}
	
	
	func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
		return false
	}
	
	
	
}

// MARK: - NSOutlineViewDataSource
extension LeftSourceList: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return leftSourceList.nodes[index]
		} else if let node = item as? LeftSourceListNode {
			return node.children[index]
		} else {
			return ""
		}
	}
	
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		guard let node = item as? LeftSourceListNode else {
			return false
		}
		return node.children.count > 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return leftSourceList.nodes.count
		} else if let node = item as? LeftSourceListNode {
			return node.children.count
		} else {
			return 0
		}
		
	}
}


