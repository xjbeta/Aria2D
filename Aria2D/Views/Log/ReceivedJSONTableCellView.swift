//
//  ReceivedJSONTableCellView.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/31.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class ReceivedJSONTableCellView: NSTableCellView {

    var text = ""
    @IBAction func copyText(_ sender: Any) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([text as NSString])
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
