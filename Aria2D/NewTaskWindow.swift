//
//  NewTaskWindow.swift
//  Aria2D
//
//  Created by xjbeta on 16/3/29.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class NewTaskWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet var newTaskWindow: NSWindow!
    
    @IBOutlet weak var textField: NSTextFieldCell!
    
    @IBOutlet weak var view: NSView!

    @IBAction func selectButton(sender: AnyObject) {
        
        let openPanel = NSOpenPanel()
        
        
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["torrent"]
        openPanel.allowsMultipleSelection = false
        
        
        
        openPanel.beginSheetModalForWindow(newTaskWindow) { result in
            if result == NSFileHandlingPanelOKButton {
                if let path = openPanel.URL {
                    if let data = NSData(contentsOfURL: path) {
                        let base64 = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                        Aria2cMethods.sharedInstance.addTorrent(base64)
                    }
                }
            }
        }
        
//        Show openpanel with a new window
//        openPanel.beginWithCompletionHandler { result in
//            if result == NSFileHandlingPanelOKButton {
//                if let path = openPanel.URL {
//                    if let data = NSData(contentsOfURL: path) {
//                        let base64 = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//                        Aria2cMethods.sharedInstance.addTorrent(base64)
//                    }
//                }
//            }
//        }
        
        
        
    }
    @IBAction func actionButton(sender: AnyObject) {
        
        
        print("__\(textField.stringValue)__")
        
        BackgroundTask.sharedInstance.sendAction({
            Aria2cMethods.sharedInstance.addUri(self.textField.stringValue)
        })
        
        
    }
    

    override var windowNibName:String! {
        return "NewTaskWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.newTaskWindow.titlebarAppearsTransparent = true
        self.newTaskWindow.makeKeyAndOrderFront(nil)
        
    }
    
}
