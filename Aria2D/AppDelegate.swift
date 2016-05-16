//
//  AppDelegate.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/21.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let mainWindowController = MainWindowController()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        mainWindowController.showWindow(nil)
        
        
 
    }
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        Aria2Websocket.sharedInstance.setWebSocketNotifications()
        BackgroundTask.sharedInstance.suspend()
        Preferences.sharedInstance.firstLaunchSetting()
        
    }
    
    

    func applicationWillTerminate(aNotification: NSNotification) {
        
        
        
        
    }

    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            mainWindowController.mainWindow.makeKeyAndOrderFront(self)
        }
        return true
        
    }
    
    func applicationWillBecomeActive(notification: NSNotification) {
        
    }
    
    func applicationWillResignActive(notification: NSNotification) {
        
    }
    
    

}

