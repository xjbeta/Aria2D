//
//  NewTaskTextField.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/24.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class NewTaskTextField: NSTextField {

    var autoCompleteRequestor: NSControl!
    
    var pop: NSPopover!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func textDidChange(notification: NSNotification) {
        if stringValue == "ma" {
            stringValue = "magnet:?xt=urn:btih:"
        }
        
    }
    

    
    
}
