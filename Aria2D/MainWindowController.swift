//
//  MainWindowController.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/21.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {

    @IBOutlet var mainWindow: NSWindow!
    
    convenience init() {
        self.init(windowNibName: "MainWindow")
    }

    @IBAction func openAddNewLink(sender: AnyObject) {
        newTaskWindow = NewTaskWindow()
        newTaskWindow.showWindow(self)
    }
    
    var newTaskWindow: NewTaskWindow!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        mainWindow.delegate = self
        mainWindow.titlebarAppearsTransparent = true
        mainWindow.titleVisibility = .Hidden
        mainWindow.movableByWindowBackground = true
    
    }
 
    
    
    
}
