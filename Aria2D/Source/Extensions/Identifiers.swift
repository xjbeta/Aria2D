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
	
    static let sidebarTableCellView = NSUserInterfaceItemIdentifier(rawValue: "SidebarTableCellView")
	static let downloadsTableCell = NSUserInterfaceItemIdentifier(rawValue: "downloadsTableCell")
	static let baiduFileListCell = NSUserInterfaceItemIdentifier(rawValue: "baiduFileListCell")
    static let receivedJSONTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "ReceivedJSONTableCellView")
    static let statusDicTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "StatusDicTableCellView")
    static let statusSpaceTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "StatusSpaceTableCellView")
    static let statusBitfieldTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "StatusBitfieldTableCellView")
    static let statusCollectionViewItem = NSUserInterfaceItemIdentifier(rawValue: "StatusCollectionViewItem")
    static let stepTableCellView = NSUserInterfaceItemIdentifier(rawValue: "StepTableCellView")
}

extension NSStoryboard.SceneIdentifier {
	static let hudViewController = "HUDViewController"
}
