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
	static let leftSourceListSelection = Notification.Name("com.xjbeta.Aria2D.LeftSourceListSelection")
	static let refreshDownloadList = Notification.Name("com.xjbeta.Aria2D.Dwnloadlist.Refresh")
	static let getDlinks = Notification.Name("com.xjbeta.Aria2D.Dwnloadlist.getDlinks")
	static let newTask = Notification.Name("com.xjbeta.Aria2D.Dwnloadlist.newTask")
	static let showHUD = Notification.Name("com.xjbeta.Aria2D.MainWindow.showHUD")
	static let updateVersionInfo = Notification.Name("com.xjbeta.Aria2D.Aria2Websocket.updateVersionInfo")
	static let updateConnectStatus = Notification.Name("com.xjbeta.Aria2D.Aria2Websocket.updateConnectStatus")
	static let updateGlobalOption = Notification.Name("com.xjbeta.Aria2D.Aria2Websocket.updateGlobalOption")
	
	static let deleteFile = Notification.Name("com.xjbeta.Aria2D.BaiduFileListMenu.deleteFile")
    static let showInfoWindow = Notification.Name("com.xjbeta.Aria2D.Dwnloadlist.showInfoWindow")
	static let resetLeftOutlineView = Notification.Name("com.xjbeta.Aria2D.LeftSourceListView.resetLeftOutlineView")
	static let developerModeChanged = Notification.Name("com.xjbeta.Aria2D.Preferences.developerModeChanged")
	
	static let updateToken = Notification.Name("com.xjbeta.Aria2D.SetPCSViewController.updateToken")
	static let updateUserInfo = Notification.Name("com.xjbeta.Aria2D.BaiduSettingView.updateUserInfo")
	
	static let activateApp = Notification.Name("com.xjbeta.Aria2D.MainMenu.activateApp")

}
