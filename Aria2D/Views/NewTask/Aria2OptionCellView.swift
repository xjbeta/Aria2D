//
//  Aria2OptionCellView.swift
//  Aria2D
//
//  Created by xjbeta on 2018/8/18.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

protocol Aria2OptionValueDelegate {
    func aria2OptionValueDidChanged(_ value: String, for option: Aria2Option)
    func resizeTableView(for option: Aria2Option)
}

class Aria2OptionCellView: NSTableCellView {
    @IBOutlet weak var checkButton: NSButton!
    
    @IBOutlet weak var comboBox: NSComboBox!
    @IBOutlet weak var valueTextField: NSTextField!
    
    @IBOutlet weak var numberValueTextField: NSTextField!
    @IBOutlet weak var numberFormatter: NumberFormatter!
    
    var unitNumberValue = UnitNumber(0)
    var minUnitNumberValue = UnitNumber(0)
    var maxUnitNumberValue = UnitNumber(0)
    
    @IBAction func applyChange(_ sender: NSControl) {
        var value = ""
        switch sender {
        case checkButton:
            value = checkButton.state == .on ? "true" : "false"
        case comboBox:
            value = comboBox.stringValue
        case numberValueTextField:
            value = comboBox.stringValue
        default:
            value = valueTextField.stringValue
        }
        
        if let option = option {
            delegate?.aria2OptionValueDidChanged(value, for: option)
        }
    }
    
    var delegate: Aria2OptionValueDelegate?
    var option: Aria2Option?
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func initValue(option: Aria2Option, value: String) {
        self.option = option
        textField?.stringValue = option.rawValue
//        textField?.toolTip
        
        setValueType(option.valueType)
        switch option.valueType {
        case .bool:
            checkButton.state = value == "true" ? .on : .off
        case .parameter(p: let p):
            comboBox.removeAllItems()
            comboBox.addItems(withObjectValues: p.map({ $0.rawValue }))
            comboBox.selectItem(withObjectValue: value)
        case .number(min: let min, max: let max):
            numberFormatter.maximumFractionDigits = 0
            numberFormatter.minimum = min as NSNumber
            numberFormatter.maximum = max as NSNumber
            numberValueTextField.integerValue = Int(value) ?? min
        case .floatNumber(min: let min, max: let max):
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.minimum = min as NSNumber
            numberFormatter.maximum = max as NSNumber
            numberValueTextField.floatValue = Float(value) ?? min
        case .unitNumber(min: let min, max: let max):
            unitNumberValue = UnitNumber(value)
            minUnitNumberValue = min
            maxUnitNumberValue = max
            valueTextField.stringValue = unitNumberValue.stringValue
        default:
            valueTextField.stringValue = value
        }
        
    }
    
    func setValueType(_ type: Aria2Option.ValueType) {
        checkButton.isHidden = true
        comboBox.isHidden = true
        valueTextField.isHidden = true
        numberValueTextField.isHidden = true
        switch type {
        case .bool:
            checkButton.isHidden = false
        case .parameter:
            comboBox.isHidden = false
        case .number, .floatNumber:
            numberValueTextField.isHidden = false
        default:
            valueTextField.isHidden = false
        }
    }
    
}

extension Aria2OptionCellView: NSControlTextEditingDelegate {
    
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
                    delegate?.aria2OptionValueDidChanged(valueTextField.stringValue, for: option)
                    delegate?.resizeTableView(for: option)
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
            let height = valueTextField.cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: valueTextField.bounds.size.width, height: 400)).height
            
            if height != valueTextField.frame.height - 2 {
                delegate?.resizeTableView(for: option)
            }
        }
    }
    
}
