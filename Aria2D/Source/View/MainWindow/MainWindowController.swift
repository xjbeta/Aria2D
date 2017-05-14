//
//  MainWindow.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	
	let hud = HUD()
	
    override func windowDidLoad() {
        super.windowDidLoad()
		if let window = window {
			window.titlebarAppearsTransparent = true
			window.titleVisibility = .hidden
			window.isMovableByWindowBackground = true
			initNotification()
			hud.delegate = self
		}
		
    }
	
	func initNotification() {
		NotificationCenter.default.addObserver(forName: .showHUD, object: nil, queue: .main) {
			if let userInfo = $0.userInfo as? [String: Any] {
				self.showHUD(message: userInfo["message"] as? hudMessage ?? .error)
			}
		}
	}
	
	
	func showHUD(message: hudMessage) {
		hud.showHUD(message)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

extension MainWindowController: HUDDelegate {
	func windowOfView() -> NSWindow? {
		return self.window
	}
}
