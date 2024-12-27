//
//  ChangeOptionViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/23.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class ChangeOptionViewController: NSViewController {
	@IBOutlet var optionKey: NSTextField!
	@IBOutlet var optionValueTextField: NSTextField!
	
	@IBOutlet var numberValueTextField: NSTextField!
	@IBOutlet var numberValueFormatter: NumberFormatter!
	@IBOutlet var optionValueComboBox: NSComboBox!
	@IBOutlet var changeButton: NSButton!
	@IBOutlet var textField: NSTextField!
	@IBAction func change(_ sender: Any) {
		guard gid != "", changeValue != "" else { return }
        Task {
            let success = try await Aria2.shared.changeOption(gid,
                                      key: option.rawValue,
                                      value: changeValue)
            if success {
                changeComplete?()
                dismiss(self)
            }
        }
        
	}
	@IBOutlet var helpButton: NSButton!
	@IBAction func help(_ sender: Any) {
		let baseURL = "https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-"
		if let url = URL(string: baseURL + option.rawValue) {
			NSWorkspace.shared.open(url)
		}
	}
    
    private var changeValue = ""
    let shoudRestartKeys: [Aria2Option] = [.btMaxPeers,
                                           .btRequestPeerSpeedLimit,
                                           .btRemoveUnselectedFile,
                                           .forceSave,
                                           .maxDownloadLimit,
                                           .maxUploadLimit]
    
    
	
	var gid = ""
	var optionValue = ""
	var changeComplete: (() -> Void)?
    var option = Aria2Option(rawValue: "") {
        didSet {
            guard viewDidLoaded else { return }
            showOption()
        }
    }
    
    private var viewDidLoaded = false
    
	@IBOutlet var visualEffectView: NSVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        visualEffectView.material = .popover
		changeButton.isEnabled = false
        
        viewDidLoaded = true
        showOption()
        optionKey.stringValue = option.rawValue
    }
	
	func updateChangeButton(_ str: String) {
		let bool = (str != optionValue && str != "")
		if bool {
			changeValue = str
		}
		changeButton.isEnabled = bool
	}
	
	enum showType {
		case string, number, p
	}
	    
    func showOption() {
        switch option.valueType {
        case .bool(let bool):
            show(.p)
            let objs = bool.map { $0.rawValue }
            optionValueComboBox.addItems(withObjectValues: objs)
            optionValueComboBox.selectItem(withObjectValue: optionValue)
            textField.stringValue = objs.joined(separator: "| ")
        case .parameter(let p):
            show(.p)
            let objs = p.map { $0.rawValue }
            optionValueComboBox.addItems(withObjectValues: objs)
            optionValueComboBox.selectItem(withObjectValue: optionValue)
            textField.stringValue = objs.joined(separator: "| ")
        case .number(let min, let max):
            show(.number)
            if let i = Int(optionValue) {
                numberValueTextField.integerValue =  i
            }
            if max != -1 {
                textField.stringValue = "\(min) - \(max)"
                numberValueFormatter.minimum = min as NSNumber
                numberValueFormatter.maximum = max as NSNumber
            } else {
                textField.stringValue = "min: \(min)"
                numberValueFormatter.minimum = min as NSNumber
                numberValueFormatter.maximum = INT_MAX as NSNumber
            }
        case .unitNumber(let min, let max):
            let str = "      1| 1K| 1M"
            show(.string)
            optionValueTextField.stringValue = UnitNumber(optionValue).stringValue
            if max.rawValue != 0 {
                textField.stringValue = "\(min.stringValue) - \(max.stringValue)\(str)"
            } else {
                textField.stringValue = "min: \(min.stringValue)\(str)"
            }
        case .localFilePath:
            show(.string)
            optionValueTextField.stringValue = optionValue
            textField.stringValue = "Local file path"
        case .hostPort:
            show(.string)
            optionValueTextField.stringValue = optionValue
            textField.stringValue = "Host port"
        case .httpProxy:
            show(.string)
            optionValueTextField.stringValue = optionValue
            textField.stringValue = "Proxy"
        case .optimizeConcurrentDownloads:
            show(.string)
            optionValueTextField.stringValue = optionValue
            textField.stringValue = "true| false| A:B"
        case .integerRange(let min, let max):
            show(.string)
            optionValueTextField.stringValue = optionValue
            textField.stringValue = "6881-6999, min: \(min), max: \(max)"
            if option == .selectFile {
                textField.stringValue = "1-5,8,9, min: \(min), max: \(max)"
            }
        case .string(let str):
            show(.string)
            optionValueTextField.stringValue = optionValue
            textField.stringValue = str
            
        default:
            show(.string)
            optionValueTextField.stringValue = optionValue
            textField.stringValue = "Click help for more info."
        }
        if shoudRestartKeys.contains(option), let textField = textField {
            textField.stringValue = textField.stringValue + "Should restart to enable"
        }
    }
    
    func show(_ type: showType) {
        textField.stringValue = ""
        optionValueTextField.isHidden = true
        numberValueTextField.isHidden = true
        optionValueComboBox.isHidden = true
        optionValueComboBox.removeAllItems()
        switch type {
        case .string:
            optionValueTextField.isHidden = false
        case .number:
            numberValueTextField.isHidden = false
        case .p:
            optionValueComboBox.isHidden = false
        }
    }
}

extension ChangeOptionViewController: NSComboBoxDelegate, NSControlTextEditingDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        if let obj = obj.object as? NSObject {
            switch obj {
            case optionValueComboBox:
                updateChangeButton(optionValueComboBox.stringValue)
            case optionValueTextField:
                updateChangeButton(optionValueTextField.stringValue)
            case numberValueTextField:
                updateChangeButton(numberValueTextField.stringValue)
            default:
                break
            }
        }
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let value = optionValueComboBox.objectValueOfSelectedItem as? String {
            updateChangeButton(value)
        }
    }

}
