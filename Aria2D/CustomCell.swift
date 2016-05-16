//
//  CustomCell.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/14.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class CustomCell: NSTableCellView {

    @IBOutlet weak var downloadTaskName: NSTextField!
    
    @IBOutlet weak var totalLength: NSTextField!

    @IBOutlet weak var fileIcon: NSImageView!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var time: NSTextField!
    
    @IBOutlet weak var percentage: NSTextField!
    
    @IBOutlet weak var status: NSTextField!
    
    
    
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        
    }
    
//    
//    override var backgroundStyle:NSBackgroundStyle{
//        didSet{
//            if backgroundStyle == .Dark{
//                self.layer?.backgroundColor = NSColor(red: 0.35, green: 0.75, blue: 0.91, alpha: 1).CGColor
//            } else {
//                self.layer?.backgroundColor = NSColor.clearColor().CGColor
//            }
//        }
//    }
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
    
    
}
