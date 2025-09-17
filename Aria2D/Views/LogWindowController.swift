//
//  LogWindowController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/4/18.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class LogWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let window = window else { return }
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.delegate = self
    }
    
    func windowWillClose(_ notification: Notification) {
        guard let vc = contentViewController as? LogViewController else {
            return
        }
        Task {
            await DataManager.shared.removeObserver(vc)
        }
    }
}
