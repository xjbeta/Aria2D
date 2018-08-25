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
    //Download List
	static let downloadsTableCell = NSUserInterfaceItemIdentifier(rawValue: "downloadsTableCell")
	static let baiduFileListCell = NSUserInterfaceItemIdentifier(rawValue: "baiduFileListCell")
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
    static let aria2BoolOptionCellView  = NSUserInterfaceItemIdentifier(rawValue: "Aria2BoolOptionCellView")
    static let aria2ParameterOptionCellView  = NSUserInterfaceItemIdentifier(rawValue: "Aria2ParameterOptionCellView")
    static let aria2TextOptionCellView  = NSUserInterfaceItemIdentifier(rawValue: "Aria2TextOptionCellView")
    static let aria2NumberOptionTextView  = NSUserInterfaceItemIdentifier(rawValue: "Aria2NumberOptionTextView")
    
    
}

extension NSStoryboard.SceneIdentifier {
	static let hudViewController = "HUDViewController"
}
