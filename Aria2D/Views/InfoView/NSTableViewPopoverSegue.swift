//
//  NSTableViewPopoverSegue.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/23.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

@MainActor
class NSTableViewPopoverSegue: NSStoryboardSegue {
	@IBOutlet weak var anchorTableView: NSTableView!
	var preferredEdge: NSRectEdge!
	var popoverBehavior: NSPopover.Behavior!

    @MainActor
    override func perform() {
        let selectedRow = anchorTableView.selectedRow
        guard selectedRow >= 0 else { return }
        (sourceController as AnyObject)
            .present(destinationController as! NSViewController,
                     asPopoverRelativeTo: anchorTableView.rect(ofRow: selectedRow),
                     of: anchorTableView,
                     preferredEdge: preferredEdge,
                     behavior: popoverBehavior)
    }
	
}
