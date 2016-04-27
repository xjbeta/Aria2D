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
    

    
    @IBOutlet weak var closeAria2cWhenExitButton: NSButton!

    @IBAction func closeAria2cWhenExit(sender: AnyObject) {
        print(closeAria2cWhenExitButton.state)
    }
    
    
    override var windowNibName:String! {
        
        return "SettingWindow"
        
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.settingWindow.titlebarAppearsTransparent = true
        self.settingWindow.makeKeyAndOrderFront(nil)
        
        
//        closeAria2cWhenExitButton.state
        
    }
    
    
    
    
}
