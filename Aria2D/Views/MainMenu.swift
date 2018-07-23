//
//  MainMenu.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainMenu: NSObject {
	
	@objc var enableLogItem: Bool {
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
		
		if menuItem.action == #selector(showInfo) {
			return selectedIndexs.count > 0
				&& mainWindowFront
				&& selectedRow != .baidu
				&& selectedRow != .none
		}
		
		if menuItem.action == #selector(refresh) {
			return mainWindowFront
		}
		
		if menuItem.action == #selector(activateApp) {
			if !string_check(nil).boolValue {
				menuItem.title = "Activate Aria2D"
			} else {
				menuItem.title = "Activated"
			}
			
//			return !_my_secret_activation_check(nil).boolValue
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
	
	@IBAction func checkForUpdate(_ sender: Any) {
		DM_SUUpdater.shared().checkForUpdates(sender)
	}
    
    @IBAction func installWithHomebrew(_ sender: Any) {
            NSAppleScript(source: """
tell application "Terminal"
    do script ""
    activate
    tell application "System Events"
        keystroke "brew install aria2"
    end tell
end tell
""")?.executeAndReturnError(nil)
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

