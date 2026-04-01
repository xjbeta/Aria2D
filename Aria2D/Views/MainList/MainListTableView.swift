//
//  MainListTableView.swift
//  Aria2D
//
//  Created by xjbeta on 2018/9/26.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

class MainListTableView: NSTableView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        if row(at: point) == -1, !selectedRowIndexes.isEmpty {
            deselectAll(self)
        }

        super.mouseDown(with: event)
    }
    
}

extension NSTableView {
    func selectedIndexs() -> IndexSet {
        selectedRowIndexes
    }

    func clickedOrSelectedIndexes() -> IndexSet {
        if clickedRow != -1 {
            if selectedRowIndexes.contains(clickedRow) {
                return selectedRowIndexes
            } else {
                return IndexSet(integer: clickedRow)
            }
        } else {
            return selectedRowIndexes
        }
    }
}
