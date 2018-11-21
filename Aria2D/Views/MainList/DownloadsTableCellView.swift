//
//  DownloadsTableCellView.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class DownloadsTableCellView: NSTableCellView {
	
//    override func viewDidEndLiveResize() {
//        progressIndicator.needsDisplay = true
//    }
	
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
    
	
}
