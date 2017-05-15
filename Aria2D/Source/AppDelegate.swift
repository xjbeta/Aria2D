//
//  AppDelegate.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Aria2Websocket.shared.initSocket()
		Baidu.shared.checkLogin(nil)
		Preferences.shared.checkPlistFile()
    }
	
    func applicationWillTerminate(_ aNotification: Notification) {

    }
	
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
				if window.className == "NSWindow" {
					window.makeKeyAndOrderFront(self)
				}
            }
        }
        return true
    }
	

	func applicationDidBecomeActive(_ notification: Notification) {
		Aria2Websocket.shared.resumeTimer()
		Aria2.shared.initData()
	}
	func applicationDidResignActive(_ notification: Notification) {
		Aria2Websocket.shared.suspendTimer()
	}

	
	
}

