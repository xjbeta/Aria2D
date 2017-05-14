//
//  SetServersViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/2/13.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class SetServersViewController: NSViewController {
	@IBOutlet var tableview: NSTableView!
	dynamic var serverListContent: [Aria2ConnectionSettings] = [] {
		didSet {
			if serverListContent.count == 0 {
				serverListContent = [Aria2ConnectionSettings()]
			}
		}
	}
	
	@IBAction func applyChanges(_ sender: Any) {
		Preferences.shared.aria2Servers.set(serverListContent)
		dismissViewController(self)
		onViewControllerDismiss?(tableview.selectedRow)
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		let index = IndexSet(integer: Preferences.shared.aria2Servers.getSelectedIndex())
		tableview.selectRowIndexes(index, byExtendingSelection: false)
	}
	
	var onViewControllerDismiss: ((_ selectedRow: Int) -> Void)?
}
