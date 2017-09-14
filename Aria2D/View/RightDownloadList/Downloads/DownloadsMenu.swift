//
//  DownloadsMenu.swift
//  Aria2D
//
//  Created by xjbeta on 16/7/13.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class DownloadsMenu: NSMenu {

	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		let selectedRow = ViewControllersManager.shared.selectedRow
		let selectedIndexs = ViewControllersManager.shared.selectedIndexs
		let mainWindowFront = ViewControllersManager.shared.mainWindowFront
		let selectedUrls = ViewControllersManager.shared.selectedUrls().count
		
		if menuItem.action == #selector(startOrPause) {
			menuItem.title = ViewControllersManager.shared.tasksShouldPause ? "pause" : "unpause"
			return selectedRow == .downloading
				&& selectedIndexs.count > 0
				&& mainWindowFront
		}
		
		if menuItem.action == #selector(pauseAll) {
			return selectedRow == .downloading && mainWindowFront
		}
		
		if menuItem.action == #selector(unpauseAll) {
			return selectedRow == .downloading && mainWindowFront
		}
		
		if menuItem.action == #selector(delete) {
			return mainWindowFront
				&& selectedIndexs.count > 0
				&& (selectedRow == .downloading || selectedRow == .completed || selectedRow == .removed)
		}
		
		if menuItem.action == #selector(showOptions) {
			return selectedIndexs.count > 0 && mainWindowFront
		}
		
		if menuItem.action == #selector(showStatus) {
			return selectedIndexs.count > 0 && mainWindowFront
		}
		
		if menuItem.action == #selector(showInFinder) {
			return Preferences.shared.aria2Servers.isLocal
				&& selectedUrls > 0
				&& mainWindowFront
		}
		
		
		return true
	}
	
	
	@IBAction func startOrPause(_ sender: Any) {
		ViewControllersManager.shared.pauseOrUnpause()
	}
	
	@IBAction func delete(_ sender: Any) {
		ViewControllersManager.shared.deleteTask()
	}
	
	@IBAction func pauseAll(_ sender: Any) {
		Aria2.shared.pauseAll()
	}

	@IBAction func unpauseAll(_ sender: Any) {
		Aria2.shared.unPauseAll()
	}
	
	@IBAction func showOptions(_ sender: Any) {
		ViewControllersManager.shared.showOptions()
	}
	
	@IBAction func showStatus(_ sender: Any) {
		ViewControllersManager.shared.showStatus()
	}

	@IBAction func showInFinder(_ sender: Any) {
		ViewControllersManager.shared.showSelectedInFinder()
	}
}
