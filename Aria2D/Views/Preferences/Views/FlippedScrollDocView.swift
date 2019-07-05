//
//  FlippedScrollDocView.swift
//  Aria2D
//
//  Created by xjbeta on 2019/2/8.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class FlippedScrollDocView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        guard let superViewHeight = superview?.frame.size.height else { return }
        let height = frame.size.height
        if superViewHeight > height {
            setFrameOrigin(NSPoint(x: frame.origin.x, y: superViewHeight - height))
        }
    }
}
