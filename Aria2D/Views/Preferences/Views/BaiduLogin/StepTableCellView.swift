//
//  StepTableCellView.swift
//  Aria2D
//
//  Created by xjbeta on 2018/6/3.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

class StepTableCellView: NSTableCellView {

    @IBOutlet weak var stepCheck: NSButton!
    @IBOutlet weak var stepName: NSTextField!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
