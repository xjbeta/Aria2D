//
//  DownloadsMenu.swift
//  Aria2D
//
//  Created by xjbeta on 16/7/13.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class DownloadsMenu: NSMenu, NSMenuItemValidation {

	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		let selectedRow = ViewControllersManager.shared.selectedRow
		let selectedObjects = ViewControllersManager.shared.selectedObjects
		let mainWindowFront = ViewControllersManager.shared.mainWindowFront
		let selectedUrls = ViewControllersManager.shared.selectedUrls().count
		
		if menuItem.action == #selector(startOrPause) {
			menuItem.title = ViewControllersManager.shared.tasksShouldPause ? NSLocalizedString("mainMenu.pauseOrUnpausItem.pause", comment: "") : NSLocalizedString("mainMenu.pauseOrUnpausItem.unpause", comment: "")
			return selectedRow == .downloading
				&& selectedObjects.count > 0
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
				&& selectedObjects.count > 0
				&& (selectedRow == .downloading || selectedRow == .completed || selectedRow == .removed)
		}
		
        if menuItem.action == #selector(showInfo) {
			return selectedObjects.count > 0 && mainWindowFront
		}
		
		if menuItem.action == #selector(showInFinder) {
			return Preferences.shared.aria2Servers.isLocal
				&& selectedUrls > 0
				&& mainWindowFront
		}
		
		
		return true
	}
	
	
	@IBAction func startOrPause(_ sender: Any) {
        Task {
            await ViewControllersManager.shared.pauseOrUnpause()
        }
	}
	
	@IBAction func delete(_ sender: Any) {
        Task {
            await ViewControllersManager.shared.deleteTask()
        }
	}
	
	@IBAction func pauseAll(_ sender: Any) {
        Task {
            try? await Aria2.shared.pauseAll()
        }
	}

	@IBAction func unpauseAll(_ sender: Any) {
        Task {
            try? await Aria2.shared.unPauseAll()
        }
	}
	
    @IBAction func showInfo(_ sender: Any) {
        ViewControllersManager.shared.showInfo()
    }

	@IBAction func showInFinder(_ sender: Any) {
		ViewControllersManager.shared.showSelectedInFinder()
	}
}
