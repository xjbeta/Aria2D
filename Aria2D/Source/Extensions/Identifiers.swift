//
//  Identifiers.swift
//  Aria2D
//
//  Created by xjbeta on 2017/6/9.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation
import Cocoa

extension NSStoryboardSegue.Identifier {
    static let showInfoWindow = "showInfoWindow"
	static let showNewTaskViewController = "showNewTaskViewController"
	static let showChangeOptionView = "showChangeOptionView"
	static let showSetServersViewController = "showSetServersViewController"
	static let showPCSView = "showPCSView"
	static let showLoginView = "showLoginView"
    static let showAria2cLog = "showAria2cLog"
}


extension NSUserInterfaceItemIdentifier {
	// Sidebar
    static let sidebarTableCellView = NSUserInterfaceItemIdentifier(rawValue: "SidebarTableCellView")
    //Main List
	static let downloadsTableCellView = NSUserInterfaceItemIdentifier(rawValue: "DownloadsTableCellView")
    //Info View
    static let statusBitfieldTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "StatusBitfieldTableCellView")
    static let statusCollectionViewItem = NSUserInterfaceItemIdentifier(rawValue: "StatusCollectionViewItem")
    static let optionTableViewOption = NSUserInterfaceItemIdentifier(rawValue: "OptionTableViewOption")
    static let optionTableViewValue = NSUserInterfaceItemIdentifier(rawValue: "OptionTableViewValue")
    
    //New Task
    static let aria2OptionCellView  = NSUserInterfaceItemIdentifier(rawValue: "Aria2OptionCellView")
    
}

extension NSStoryboard.SceneIdentifier {
	static let hudViewController = "HUDViewController"
}
