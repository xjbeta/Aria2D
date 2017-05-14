//
//  MainMenu.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainMenu: NSObject {
	
	var enableLogItem: Bool {
		return Preferences.shared.developerMode
	}
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        let selectedRow = ViewControllersManager.shared.selectedRow
		let selectedIndexs = ViewControllersManager.shared.selectedIndexs
		let mainWindowFront = ViewControllersManager.shared.mainWindowFront

		if menuItem.action == #selector(addTask) {
			return Aria2Websocket.shared.isConnected
		}
		
		if menuItem.action == #selector(nextTag) {
			return selectedRow != .baidu && mainWindowFront
		}
		
		if menuItem.action == #selector(previousTag) {
			return selectedRow != .downloading && mainWindowFront
		}
		
		if menuItem.action == #selector(startOrPause) {
			menuItem.title = ViewControllersManager.shared.tasksShouldPause ? "pause" : "unpause"
			return selectedRow == .downloading
				&& selectedIndexs.count > 0
				&& mainWindowFront
		}
		
		if menuItem.action == #selector(pauseAll) {
			return selectedRow == .downloading && mainWindowFront
		}
		
		if menuItem.action == #selector(unPauseAll) {
			return selectedRow == .downloading && mainWindowFront
		}
		
		if menuItem.action == #selector(delete) {
			return mainWindowFront
				&& selectedIndexs.count > 0
				&& (selectedRow == .downloading || selectedRow == .completed || selectedRow == .removed)
		}
		
		if menuItem.action == #selector(showOptions) {
			return selectedIndexs.count > 0
				&& mainWindowFront
				&& selectedRow != .baidu
				&& selectedRow != .none
		}
		
		if menuItem.action == #selector(showStatus) {
			return selectedIndexs.count > 0
				&& mainWindowFront
				&& selectedRow != .baidu
				&& selectedRow != .none
		}
		
		if menuItem.action == #selector(refresh) {
			return mainWindowFront
		}
		
//		if menuItem.title == "Log" {
//			return Preferences.shared.developerMode
//		}
		
        return true
    }

    
    @IBAction func addTask(_ sender: Any) {
        NotificationCenter.default.post(name: .newTask, object: self)
    }
    
    @IBAction func nextTag(_ sender: Any) {
        NotificationCenter.default.post(name: .nextTag, object: self)
    }
    
    @IBAction func previousTag(_ sender: Any) {
        NotificationCenter.default.post(name: .previousTag, object: self)
    }
    @IBAction func refresh(_ sender: Any) {
		ViewControllersManager.shared.refresh()
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
	
    @IBAction func unPauseAll(_ sender: Any) {
        Aria2.shared.unPauseAll()
    }
	
	@IBAction func showOptions(_ sender: Any) {
		ViewControllersManager.shared.showOptions()
	}
	
	@IBAction func showStatus(_ sender: Any) {
		ViewControllersManager.shared.showStatus()
	}
	@IBAction func showConfigFolder(_ sender: Any) {
		NSWorkspace.shared().activateFileViewerSelecting([URL(fileURLWithPath: NSHomeDirectory())])
	}
}

