//
//  Identifiers.swift
//  Aria2D
//
//  Created by xjbeta on 2017/6/9.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation
extension NSStoryboardSegue.Identifier {
	static let showBaiduDlinksProgress = NSStoryboardSegue.Identifier(rawValue: "showBaiduDlinksProgress")
	static let showOptionsWindow = NSStoryboardSegue.Identifier(rawValue: "showOptionsWindow")
	static let showStatusWindow = NSStoryboardSegue.Identifier(rawValue: "showStatusWindow")
	static let showNewTaskViewController = NSStoryboardSegue.Identifier(rawValue: "showNewTaskViewController")
	static let showChangeOptionView = NSStoryboardSegue.Identifier(rawValue: "showChangeOptionView")
	static let showSetServersViewController = NSStoryboardSegue.Identifier(rawValue: "showSetServersViewController")
	static let showPCSView = NSStoryboardSegue.Identifier(rawValue: "showPCSView")
	static let showLoginView = NSStoryboardSegue.Identifier(rawValue: "showLoginView")
}


extension NSUserInterfaceItemIdentifier {
	
    static let sidebarTableCellView = NSUserInterfaceItemIdentifier(rawValue: "SidebarTableCellView")
	static let downloadsTableCell = NSUserInterfaceItemIdentifier(rawValue: "downloadsTableCell")
	static let baiduFileListCell = NSUserInterfaceItemIdentifier(rawValue: "baiduFileListCell")
    static let receivedJSONTableCellView =  NSUserInterfaceItemIdentifier(rawValue: "ReceivedJSONTableCellView")
    
}

extension NSStoryboard.SceneIdentifier {
	static let hudViewController = NSStoryboard.SceneIdentifier(rawValue: "HUDViewController")
}
