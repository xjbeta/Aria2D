//
//  Aria2TextOptionCellView.swift
//  Aria2D
//
//  Created by xjbeta on 2018/8/18.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

class Aria2TextOptionCellView: NSTableCellView, NSControlTextEditingDelegate {
    @IBOutlet weak var valueTextField: NSTextField!
    @IBAction func valueTextField(_ sender: Any) {
        if let option = option {
            delegate?.aria2OptionValueDidChanged(valueTextField.stringValue, for: option)
        }
    }
    var delegate: Aria2OptionValueDelegate?
    var option: Aria2Option?
    
    var unitNumberValue = UnitNumber(0)
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let option = option {
            switch option.valueType {
            case .unitNumber(min: let min, max: let max):
                if UnitNumber(valueTextField.stringValue).rawValue == 0,
                    Int(valueTextField.stringValue) != 0 {
                    return false
                } else {
                    var new = UnitNumber(valueTextField.stringValue)
                    if new.rawValue < min.rawValue {
                        new = min
                    }
                    if max.rawValue != 0, new.rawValue > max.rawValue {
                        new = max
                    }
                    unitNumberValue = new
                    valueTextField.stringValue = unitNumberValue.stringValue
                    return true
                }
            default:
                break
            }
        }
        return true
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let option = option {
            switch option.valueType {
            case .unitNumber(min: _, max: _):
                valueTextField.stringValue = unitNumberValue.stringValue
            default:
                break
            }
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if let option = option {
            delegate?.aria2OptionValueDidChanged(valueTextField.stringValue, for: option)
        }
        if let option = option {
            delegate?.resizeTableView(0, for: option)
        }
    }

    func autoResize() {
        let size = valueTextField.frame.size
        let height = valueTextField.cell?.cellSize(forBounds: NSMakeRect(0, 0, size.width, 200)).height ?? 22
        setFrameSize(NSSize(width: bounds.width, height: height + 6))
    }
    
}
