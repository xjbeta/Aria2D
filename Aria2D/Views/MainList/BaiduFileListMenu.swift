//
//  BaiduFileListMenu.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/26.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class BaiduFileListMenu: NSMenu, NSMenuItemValidation {
	
	@IBOutlet var nameItem: NSMenuItem!
	@IBOutlet var sizeItem: NSMenuItem!
	@IBOutlet var dateItem: NSMenuItem!
	
	@IBOutlet var ascendingItem: NSMenuItem!
	@IBOutlet var descendingItem: NSMenuItem!
	
	@IBOutlet var downloadItem: NSMenuItem!
	@IBOutlet var deleteItem: NSMenuItem!
	
	@IBAction func sortItem(_ sender: NSMenuItem) {
		switch sender {
		case nameItem:
			Preferences.shared.sortValue = "path"
		case sizeItem:
			Preferences.shared.sortValue = "size"
		case dateItem:
			Preferences.shared.sortValue = "serverMtime"
		default:
			break
		}
		refreshMainList()
	}
	
	@IBAction func ascendingItem(_ sender: NSMenuItem) {
		switch sender {
		case ascendingItem:
			Preferences.shared.ascending = true
		case descendingItem:
			Preferences.shared.ascending = false
		default:
			break
		}
		refreshMainList()
	}
	
	@IBAction func download(_ sender: Any) {
        NotificationCenter.default.post(name: .getDlinks, object: nil, userInfo: ["unsafely": false])
	}
    @IBAction func downloadUnsafely(_ sender: Any) {
        NotificationCenter.default.post(name: .getDlinks, object: nil, userInfo: ["unsafely": true])
    }
    
	@IBAction func delete(_ sender: Any) {
		NotificationCenter.default.post(name: .deleteFile, object: nil)
	}
	
	func refreshMainList() {
		NotificationCenter.default.post(name: .refreshMainList, object: nil)
	}
	
	func initItemState() {
		nameItem.state = .off
		sizeItem.state = .off
		dateItem.state = .off
		
		ascendingItem.state = .off
		descendingItem.state = .off
		
		downloadItem.state = .off
		deleteItem.state = .off
		
		if Preferences.shared.ascending {
			ascendingItem.state = .on
		} else {
			descendingItem.state = .on
		}
		
		switch Preferences.shared.sortValue {
		case "path":
			nameItem.state = .on
		case "size":
			sizeItem.state = .on
		case "serverMtime":
			dateItem.state = .on
		default:
			break
		}
	}
	
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		let selectedIndexs = ViewControllersManager.shared.selectedIndexs
		if menuItem.action == #selector(download) || menuItem.action == #selector(downloadUnsafely) {
			return Aria2Websocket.shared.isConnected
				&& Baidu.shared.isLogin
				&& selectedIndexs.count > 0
		}
		if menuItem.action == #selector(delete) {
			return Baidu.shared.isLogin
				&& selectedIndexs.count > 0
		}
		
		return true
	}
}
