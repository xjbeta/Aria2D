//
//  Aria2ParameterOptionCellView.swift
//  Aria2D
//
//  Created by xjbeta on 2018/8/18.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

class Aria2ParameterOptionCellView: NSTableCellView {
    @IBOutlet weak var comboBox: NSComboBox!
    @IBAction func comboBox(_ sender: Any) {
        if let option = option {
            delegate?.aria2OptionValueDidChanged(comboBox.stringValue, for: option)
        }
    }
    
    var delegate: Aria2OptionValueDelegate?
    var option: Aria2Option?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
