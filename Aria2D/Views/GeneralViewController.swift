//
//  Generalview.swift
//  Aria2D
//
//  Created by xjbeta on 16/5/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class GeneralViewController: NSViewController {
    
    @IBOutlet var downloadDirPopUpButton: NSPopUpButton!

	@IBOutlet var downloadDirTextField: NSTextField!
    @IBOutlet var downloadDir: NSMenuItem!
    
    @IBOutlet var otherPath: NSMenuItem!
    @IBAction func otherPath(_ sender: Any) {
		
		
        // OK Button Title
        openPanel.prompt = "Select"
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
		if let window = view.window {
			openPanel.beginSheetModal(for: window) { result in
				if result == .OK {
					if let url = self.openPanel.url {
						Preferences.shared.aria2Servers.set(url.path)
						self.setPopbutton()
					}
				}
			}
		}
        downloadDirPopUpButton.selectItem(at: 0)
    }
	
	@IBOutlet var selectMenu: NSMenu!
	@IBOutlet var menuPopupButton: NSPopUpButton!
	@IBAction func setServers(_ sender: Any) {
		performSegue(withIdentifier: .showSetServersViewController, sender: self)
		menuPopupButton.selectItem(at: selectServerIndex)
	}
	
	@objc var selectServerIndex: Int {
		get {
			return Preferences.shared.aria2Servers.getSelectedIndex()
		}
		set {
			if newValue < (menuPopupButton.itemArray.count - 2) {
				Preferences.shared.aria2Servers.select(at: newValue)
			}
		}
	}
	
	lazy var openPanel = NSOpenPanel()

	struct Options {
		var maxConcurrentDownloads: Int {
			get {
				return Int(Aria2Websocket.shared.aria2GlobalOption[.maxConcurrentDownloads] ?? "0") ?? 0
			}
		}
		var maxOverallUploadLimit: Int {
			get {
				return (Int(Aria2Websocket.shared.aria2GlobalOption[.maxOverallUploadLimit] ?? "0") ?? 0) / 1000
			}
		}
		var maxOverallDownloadLimit: Int {
			get {
				return (Int(Aria2Websocket.shared.aria2GlobalOption[.maxOverallDownloadLimit] ?? "0") ?? 0) / 1000
			}
		}
		var optimizeConcurrentDownloads: Bool {
			get {
				return Aria2Websocket.shared.aria2GlobalOption[.optimizeConcurrentDownloads] == "true"
			}
		}
		var dir: String {
			get {
                let customPath = Preferences.shared.aria2Servers.getServer().customPath
                if customPath == "" || customPath == nil {
                    return Aria2Websocket.shared.aria2GlobalOption[.dir] ?? ""
                } else if let customPath = customPath {
                    return customPath
                }
                return ""
			}
		}
		
		func update(_ key: Aria2Option, value: Any, completion: @escaping (_ success: Bool) -> Void) {
			Aria2.shared.changeGlobalOption(key, value: "\(value)") {
				completion($0)
			}	
		}

	}
	
	@IBOutlet var maxConcurrentDownloadsComboBox: NSComboBox!
	@IBOutlet var optimizeConcurrentDownloadsButton: NSButton!
	@IBAction func optimizeConcurrentDownloads(_ sender: NSButton) {
		let oldState = options.optimizeConcurrentDownloads
		options.update(.optimizeConcurrentDownloads, value: !oldState) { success in
			DispatchQueue.main.async {
				if !success {
					self.optimizeConcurrentDownloadsButton.state = oldState ? .on : .off
				} else {
					self.optimizeConcurrentDownloadsButton.state = self.options.optimizeConcurrentDownloads ? .on : .off
				}
			}
		}
	}
	@IBOutlet var maxOverallDownloadLimitTextField: NSTextField!
	@IBOutlet var maxOverallUploadLimitTextField: NSTextField!

	var options = Options()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		initSelectMenu()
		setControlsStatus()
		updateOption()
		NotificationCenter.default.addObserver(self, selector: #selector(setControlsStatus), name: .updateConnectStatus, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateOption), name: .updateGlobalOption, object: nil)
    }
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		
		controlTextDidEndEditing(Notification(name: NSControl.textDidEndEditingNotification, object: maxOverallDownloadLimitTextField, userInfo: nil))
		controlTextDidEndEditing(Notification(name: NSControl.textDidEndEditingNotification, object: maxOverallUploadLimitTextField, userInfo: nil))
		controlTextDidEndEditing(Notification(name: NSControl.textDidEndEditingNotification, object: maxConcurrentDownloadsComboBox, userInfo: nil))
		controlTextDidEndEditing(Notification(name: NSControl.textDidEndEditingNotification, object: downloadDirTextField, userInfo: nil))
	}
	
	
	func initDir() {
		downloadDirPopUpButton.isHidden = true
		downloadDirTextField.isHidden = true
		if Preferences.shared.aria2Servers.isLocal {
			downloadDirPopUpButton.isHidden = false
			setPopbutton()
		} else {
			downloadDirTextField.isHidden = false
			downloadDirTextField.stringValue = options.dir
		}
	}
	
    func setPopbutton() {
		let dirURL = URL(fileURLWithPath: options.dir)
		if options.dir == "" {
			downloadDir.title = "Select A Folder"
		} else {
			downloadDir.title = dirURL.lastPathComponent
		}
		
		let image = NSWorkspace.shared.icon(forFile: dirURL.path)
		image.size = NSSize(width: 16, height: 16)
		downloadDir.image = image
	}

	@objc func setControlsStatus() {
		DispatchQueue.main.async {
			let enable = Aria2Websocket.shared.isConnected
            self.view.subviews.forEach {
                if let button = $0 as? NSPopUpButton,
                    button == self.menuPopupButton {
                    return
                }
                if let control = $0 as? NSControl {
                    control.isEnabled = enable
                }

            }
		}
	}
	
	@objc func updateOption() {
		DispatchQueue.main.async {
			self.initDir()
			let options = self.options
			self.maxConcurrentDownloadsComboBox.integerValue = options.maxConcurrentDownloads
			self.optimizeConcurrentDownloadsButton.state = options.optimizeConcurrentDownloads ? .on : .off
			self.maxOverallDownloadLimitTextField.integerValue = options.maxOverallDownloadLimit
			self.maxOverallUploadLimitTextField.integerValue = options.maxOverallUploadLimit
		}
	}
	
	

	
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == .showSetServersViewController {
			if let vc = segue.destinationController as? SetServersViewController {
				vc.serverListContent = Preferences.shared.aria2Servers.get()
				vc.onViewControllerDismiss = {
					self.selectServerIndex = $0
					self.initSelectMenu()
					self.initSocket()
				}
			}
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

extension GeneralViewController: NSMenuDelegate {
	func menuNeedsUpdate(_ menu: NSMenu) {
		initSelectMenu()
	}
	
	func menuDidClose(_ menu: NSMenu) {
		initSocket()
	}
	
	func initSocket() {
		DispatchQueue.main.async {
            if Aria2Websocket.shared.socket?.url != Preferences.shared.aria2Servers.serverURL() {
				Aria2Websocket.shared.initSocket()
			}
		}
	}
	
	func initSelectMenu() {
		if let item = selectMenu.items.last, item.action != #selector(setServers) {
			selectMenu.removeItem(item)
		}
		
		while selectMenu.items.count > 2 {
			selectMenu.removeItem(at: 0)
		}
		Preferences.shared.aria2Servers.get().map {
			NSMenuItem(title: $0.name, action: nil, keyEquivalent: "")
			}.enumerated().forEach { (arg) in
				let (i, item) = arg
				selectMenu.insertItem(item, at: i)
		}
		
		menuPopupButton.selectItem(at: selectServerIndex)
	}
	
}

// controls changed
extension GeneralViewController: NSComboBoxDelegate, NSControlTextEditingDelegate {
	
	func controlTextDidEndEditing(_ obj: Notification) {
		if let obj = obj.object as? NSObject {
			switch obj {
			case maxConcurrentDownloadsComboBox:
				guard maxConcurrentDownloadsComboBox.integerValue != options.maxConcurrentDownloads else {
					return
				}
				options.update(.maxConcurrentDownloads,
				               value: maxConcurrentDownloadsComboBox.stringValue) {
								if $0 { return }
								DispatchQueue.main.async {
									self.maxConcurrentDownloadsComboBox.integerValue = self.options.maxConcurrentDownloads
								}
				}
			case maxOverallDownloadLimitTextField:
				guard maxOverallDownloadLimitTextField.integerValue != options.maxOverallDownloadLimit else {
					return
				}
				options.update(.maxOverallDownloadLimit,
				               value: "\(maxOverallDownloadLimitTextField.integerValue * 1000)") {
								if $0 { return }
								DispatchQueue.main.async {
									self.maxOverallDownloadLimitTextField.integerValue = self.options.maxOverallDownloadLimit
								}
				}
			case maxOverallUploadLimitTextField:
				guard maxOverallUploadLimitTextField.integerValue != options.maxOverallUploadLimit else {
					return
				}
				options.update(.maxOverallUploadLimit,
				               value: "\(maxOverallUploadLimitTextField.integerValue * 1000)") {
								if $0 { return }
								DispatchQueue.main.async {
									self.maxOverallUploadLimitTextField.integerValue = self.options.maxOverallUploadLimit
								}
				}
				
			case downloadDirTextField:
				if !Preferences.shared.aria2Servers.isLocal {
					Preferences.shared.aria2Servers.set(downloadDirTextField.stringValue)
				}
			default:
				break
			}
		}
	}
	
	
	func comboBoxSelectionDidChange(_ notification: Notification) {
		if let value = maxConcurrentDownloadsComboBox.objectValueOfSelectedItem as? String, Int(value) != options.maxConcurrentDownloads {
			options.update(.maxConcurrentDownloads,
			               value: value) {
							if $0 { return }
							DispatchQueue.main.async {
								self.maxConcurrentDownloadsComboBox.integerValue = self.options.maxConcurrentDownloads
							}
			}
		}
	}
	
	
}
