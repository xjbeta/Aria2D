//
//  NotificationName.swift
//  Aria2D
//
//  Created by xjbeta on 2016/12/17.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation

extension Notification.Name {
	static let nextTag = Notification.Name("com.xjbeta.Aria2D.NextTag")
	static let previousTag = Notification.Name("com.xjbeta.Aria2D.PreviousTag")
	static let sidebarSelectionChanged = Notification.Name("com.xjbeta.Aria2D.SidebarSelectionChanged")
	static let refreshMainList = Notification.Name("com.xjbeta.Aria2D.MainList.Refresh")
	static let newTask = Notification.Name("com.xjbeta.Aria2D.Dwnloadlist.newTask")
	static let showHUD = Notification.Name("com.xjbeta.Aria2D.MainWindow.showHUD")
	static let updateConnectStatus = Notification.Name("com.xjbeta.Aria2D.Aria2Websocket.updateConnectStatus")
	static let updateGlobalOption = Notification.Name("com.xjbeta.Aria2D.Aria2Websocket.updateGlobalOption")
	
    static let showInfoWindow = Notification.Name("com.xjbeta.Aria2D.Dwnloadlist.showInfoWindow")
	static let developerModeChanged = Notification.Name("com.xjbeta.Aria2D.Preferences.developerModeChanged")
	
	static let activateApp = Notification.Name("com.xjbeta.Aria2D.MainMenu.activateApp")

    static let updateGlobalStat = Notification.Name("com.xjbeta.Aria2D.Aria2.updateGlobalStat")
    
    static let updateBtTracker = Notification.Name("com.xjbeta.Aria2D.Aria2Options.updateBtTracker")
}
