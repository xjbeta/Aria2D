//
//  SettingWindow.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/14.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class SettingWindow: NSWindowController {

    @IBOutlet var settingWindow: NSWindow!
    
    override var windowNibName:String! {
        
        return "SettingWindow"
        
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()

        
        self.settingWindow.titlebarAppearsTransparent = true
        self.settingWindow.makeKeyAndOrderFront(nil)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    
    
}
