//
//  MainMenu.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainMenu: NSObject, NSMenuItemValidation {
    
	@objc var enableLogItem: Bool {
		return Preferences.shared.developerMode
	}
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        let selectedRow = ViewControllersManager.shared.selectedRow
		let selectedObjects = ViewControllersManager.shared.selectedObjects
		let mainWindowFront = ViewControllersManager.shared.mainWindowFront

		if menuItem.action == #selector(addTask) {
			return Aria2Websocket.shared.isConnected
		}
		
		if menuItem.action == #selector(nextTag) {
			return mainWindowFront
		}
		
		if menuItem.action == #selector(previousTag) {
			return selectedRow != .downloading && mainWindowFront
		}
		
		if menuItem.action == #selector(startOrPause) {
			menuItem.title = ViewControllersManager.shared.tasksShouldPause ? NSLocalizedString("mainMenu.pauseOrUnpausItem.pause", comment: "") : NSLocalizedString("mainMenu.pauseOrUnpausItem.unpause", comment: "")
			return selectedRow == .downloading
				&& selectedObjects.count > 0
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
				&& selectedObjects.count > 0
				&& (selectedRow == .downloading || selectedRow == .completed || selectedRow == .removed)
		}
		
		if menuItem.action == #selector(showInfo) {
			return selectedObjects.count > 0
				&& mainWindowFront
				&& selectedRow != .none
		}
		
		if menuItem.action == #selector(refresh) {
			return mainWindowFront
		}
		
		if menuItem.action == #selector(activateApp) {
			if !string_check(nil).boolValue {
				menuItem.title = NSLocalizedString("mainMenu.activateAppItem.activate", comment: "")
			} else {
				menuItem.title = NSLocalizedString("mainMenu.activateAppItem.activated", comment: "")
			}
		}
		

        return true
    }

    
    @IBAction func addTask(_ sender: Any) {
        NotificationCenter.default.post(name: .newTask, object: nil)
    }
    
    @IBAction func nextTag(_ sender: Any) {
        NotificationCenter.default.post(name: .nextTag, object: nil)
    }
    
    @IBAction func previousTag(_ sender: Any) {
        NotificationCenter.default.post(name: .previousTag, object: nil)
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
	
	@IBAction func showInfo(_ sender: Any) {
		ViewControllersManager.shared.showInfo()
	}

	@IBAction func feedback(_ sender: Any) {
		DevMateKit.showFeedbackDialog(nil, in: .sheetMode)
	}
	
	@IBAction func activateApp(_ sender: Any) {
		NotificationCenter.default.post(name: .activateApp, object: nil)
	}
    
    @IBAction func installWithHomebrew(_ sender: Any) {
        NSAppleScript(source: """
tell application "Terminal" to do script "brew install aria2"
""")?.executeAndReturnError(nil)
        NSWorkspace.shared.launchApplication("Terminal")
    }
    
    @IBAction func installWithDMG(_ sender: Any) {
        if let url = URL(string: "https://dl.devmate.com/com.aria2.aria2c/aria2c.dmg") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func help(_ sender: Any) {
        if let url = URL(string: "https://github.com/xjbeta/Aria2D") {
            NSWorkspace.shared.open(url)
        }
    }
    
}

