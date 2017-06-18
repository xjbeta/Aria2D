//
//  MainWindow.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	
	var hud: HUD?
	
    override func windowDidLoad() {
        super.windowDidLoad()
		if let window = window {
			window.titlebarAppearsTransparent = true
			window.titleVisibility = .hidden
			window.isMovableByWindowBackground = true
			if let view = window.contentView {
				hud = HUD(view)
			}
			initNotification()
		}
	}

	
	func initNotification() {
		NotificationCenter.default.addObserver(forName: .showHUD, object: nil, queue: .main) {
			if let userInfo = $0.userInfo as? [String: Any] {
				self.showHUD(message: userInfo["message"] as? hudMessage ?? .error)
			}
		}
		
		NotificationCenter.default.addObserver(forName: .showAria2CheckAlert, object: nil, queue: .main) {
			if let userInfo = $0.userInfo as? [String: String], let args = userInfo["args"] {
				self.showAria2CheckAlert(args)
			}
		}
	}
	
	
	func showHUD(message: hudMessage) {
		hud?.showHUD(message)
	}
	
	// check aria2c
	func showAria2CheckAlert(_ args: String) {
		
		if let window = window {
			let alert = NSAlert()
			alert.messageText = "Aria2c didn't started."
			alert.informativeText = "Check the configs in Terminal."
			alert.addButton(withTitle: "Check")
			alert.addButton(withTitle: "Cancel")
			
			alert.beginSheetModal(for: window) {
				if $0 == .alertFirstButtonReturn {
					NSAppleScript(source: "tell application \"Terminal\" \n activate \n do script \"\(args)\" \n end tell")?.executeAndReturnError(nil)
				}
			}
		}
	}
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	

	
}
