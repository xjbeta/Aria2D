//
//  Aria2BoolOptionCellView.swift
//  Aria2D
//
//  Created by xjbeta on 2018/8/18.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

protocol Aria2OptionValueDelegate {
    func aria2OptionValueDidChanged(_ value: String, for option: Aria2Option)
    func resizeTableView(_ height: CGFloat, for option: Aria2Option)
}

class Aria2BoolOptionCellView: NSTableCellView {
    @IBOutlet weak var checkButton: NSButton!
    @IBAction func checkButton(_ sender: Any) {
        if let option = option {
            delegate?.aria2OptionValueDidChanged("\(checkButton.state == .on)", for: option)
        }
    }
    
    var delegate: Aria2OptionValueDelegate?
    var option: Aria2Option?
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    
}
