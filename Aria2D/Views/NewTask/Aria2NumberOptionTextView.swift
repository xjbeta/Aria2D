//
//  Aria2NumberOptionTextView.swift
//  Aria2D
//
//  Created by xjbeta on 2018/8/18.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

class Aria2NumberOptionTextView: NSTableCellView {
    @IBOutlet weak var numberTextField: NSTextField!
    @IBOutlet weak var numberFormatter: NumberFormatter!
    @IBAction func numberTextField(_ sender: Any) {
        if let option = option {
            delegate?.aria2OptionValueDidChanged(numberTextField.stringValue, for: option)
        }
    }
    var delegate: Aria2OptionValueDelegate?
    var option: Aria2Option?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
