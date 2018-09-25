//
//  Identifiers.swift
//  Aria2D
//
//  Created by xjbeta on 2017/6/9.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation
extension NSStoryboardSegue.Identifier {
	static let showBaiduDlinksProgress = "showBaiduDlinksProgress"
    static let showInfoWindow = "showInfoWindow"
	static let showNewTaskViewController = "showNewTaskViewController"
	static let showChangeOptionView = "showChangeOptionView"
	static let showSetServersViewController = "showSetServersViewController"
	static let showPCSView = "showPCSView"
	static let showLoginView = "showLoginView"
}


extension NSUserInterfaceItemIdentifier {
	// Sidebar
    static let sidebarTableCellView = NSUserInterfaceItemIdentifier(rawValue: "SidebarTableCellView")
    //Main List
	static let downloadsTableCellView = NSUserInterfaceItemIdentifier(rawValue: "DownloadsTableCellView")
	static let baiduFileTableCellView = NSUserInterfaceItemIdentifier(rawValue: "BaiduFileTableCellView")
    //Log
    static let receivedJSONTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "ReceivedJSONTableCellView")
    //Info View
    static let statusDicTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "StatusDicTableCellView")
    static let statusSpaceTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "StatusSpaceTableCellView")
    static let statusBitfieldTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "StatusBitfieldTableCellView")
    static let statusCollectionViewItem = NSUserInterfaceItemIdentifier(rawValue: "StatusCollectionViewItem")
    //Baidu Login
    static let stepTableCellView = NSUserInterfaceItemIdentifier(rawValue: "StepTableCellView")
    //New Task
    static let aria2OptionCellView  = NSUserInterfaceItemIdentifier(rawValue: "Aria2OptionCellView")
    
}

extension NSStoryboard.SceneIdentifier {
	static let hudViewController = "HUDViewController"
}
