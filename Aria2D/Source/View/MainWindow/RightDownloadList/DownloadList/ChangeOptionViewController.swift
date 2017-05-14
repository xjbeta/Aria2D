//
//  ChangeOptionViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/23.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class ChangeOptionViewController: NSViewController, NSComboBoxDelegate {
	@IBOutlet var optionKey: NSTextField!
	@IBOutlet var optionValueTextField: NSTextField!
	
	@IBOutlet var numberValueTextField: NSTextField!
	@IBOutlet var numberValueFormatter: NumberFormatter!
	@IBOutlet var optionValueComboBox: NSComboBox!
	@IBOutlet var changeButton: NSButton!
	@IBOutlet var textField: NSTextField!
	@IBAction func change(_ sender: Any) {
		if gid != "", changeValue != "" {
			Aria2.shared.changeOption(gid,
			                          key: option.rawValue,
			                          value: changeValue) {
										switch $0 {
										case .success(let json):
											if json["result"].stringValue == "OK" {
												DispatchQueue.main.async {
													self.changeComplete?()
													self.dismiss(self)
												}
											}
										default:
											return
										}
			}
		}
	}
	@IBOutlet var helpButton: NSButton!
	@IBAction func help(_ sender: Any) {
		let baseURL = "https://aria2.github.io/manual/en/html/aria2c.html#cmdoption--"
		if let url = URL(string: baseURL + option.rawValue) {
			NSWorkspace.shared().open(url)
		}
	}
	
	var gid = ""
	var optionValue = ""
	var changeComplete: (() -> Void)?
	
	private var changeValue = ""
	let shoudRestartKeys: [Aria2Option] = [.btMaxPeers,
	                                       .btRequestPeerSpeedLimit,
	                                       .btRemoveUnselectedFile,
	                                       .forceSave,
	                                       .maxDownloadLimit,
	                                       .maxUploadLimit]
	
	
	var option = Aria2Option(rawValue: "") {
		didSet {
			switch option.valueType {
			case .bool(let bool):
				show(.p) {
					let objs = bool.map { $0.rawValue }
					self.optionValueComboBox.addItems(withObjectValues: objs)
					self.optionValueComboBox.selectItem(withObjectValue: self.optionValue)
					self.textField.stringValue = objs.joined(separator: "| ")
				}
			case .parameter(let p):
				show(.p) {
					let objs = p.map { $0.rawValue }
					self.optionValueComboBox.addItems(withObjectValues: objs)
					self.optionValueComboBox.selectItem(withObjectValue: self.optionValue)
					self.textField.stringValue = objs.joined(separator: "| ")
				}
			case .number(let min, let max):
				show(.number) {
					if let i = Int(self.optionValue) {
						self.numberValueTextField.integerValue =  i
					}
					if max != -1 {
						self.textField.stringValue = "\(min) - \(max)"
						self.numberValueFormatter.minimum = min as NSNumber
						self.numberValueFormatter.maximum = max as NSNumber
					} else {
						self.textField.stringValue = "min: \(min)"
						self.numberValueFormatter.minimum = min as NSNumber
						self.numberValueFormatter.maximum = INT_MAX as NSNumber
					}
				}
			case .unitNumber(let min, let max):
				let str = "      1| 1K| 1M"
				show(.string) {
					self.optionValueTextField.stringValue = UnitNumber(self.optionValue).stringValue
					if max.rawValue != 0 {
						self.textField.stringValue = "\(min.stringValue) - \(max.stringValue)\(str)"
					} else {
						self.textField.stringValue = "min: \(min.stringValue)\(str)"
					}
				}
			case .localFilePath:
				show(.string) {
					self.optionValueTextField.stringValue = self.optionValue
					self.textField.stringValue = "Local file path"
				}
			case .hostPort:
				show(.string) {
					self.optionValueTextField.stringValue = self.optionValue
					self.textField.stringValue = "Host port"
				}
			case .httpProxy:
				show(.string) {
					self.optionValueTextField.stringValue = self.optionValue
					self.textField.stringValue = "Proxy"
				}
			case .optimizeConcurrentDownloads:
				show(.string) {
					self.optionValueTextField.stringValue = self.optionValue
					self.textField.stringValue = "true| false| A:B"
				}
			case .integerRange(let min, let max):
				show(.string) {
					self.optionValueTextField.stringValue = self.optionValue
					self.textField.stringValue = "6881-6999, min: \(min), max: \(max)"
					if self.option == .selectFile {
						self.textField.stringValue = "1-5,8,9, min: \(min), max: \(max)"
					}
				}
			case .string(let str):
				show(.string) {
					self.optionValueTextField.stringValue = self.optionValue
					self.textField.stringValue = str
				}
				
			default:
				show(.string) {
					self.optionValueTextField.stringValue = self.optionValue
					self.textField.stringValue = "Click help for more info."
				}
			}
			if shoudRestartKeys.contains(self.option) {
				self.textField.stringValue = self.textField.stringValue + "Should restart to enable"
			}
		}
	}
	@IBOutlet var visualEffectView: NSVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        visualEffectView.material = .popover
		changeButton.isEnabled = false
		show(.string) {}
    }
	
	
	override func controlTextDidChange(_ obj: Notification) {
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
	
	func show(_ type: showType, then: @escaping (() -> Void)) {
		DispatchQueue.main.async {
			self.textField.stringValue = ""
			self.optionValueTextField.isHidden = true
			self.numberValueTextField.isHidden = true
			self.optionValueComboBox.isHidden = true
			self.optionValueComboBox.removeAllItems()
			switch type {
			case .string:
				self.optionValueTextField.isHidden = false
			case .number:
				self.numberValueTextField.isHidden = false
			case .p:
				self.optionValueComboBox.isHidden = false
			}
			then()
		}
	}
    
}
