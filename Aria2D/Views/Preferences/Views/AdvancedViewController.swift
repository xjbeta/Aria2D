//
//  Aria2OptionsViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/5/24.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class AdvancedViewController: NSViewController, NSMenuDelegate {
	
	@IBOutlet var aria2cPathPopUpButton: NSPopUpButton!
    @IBOutlet weak var aria2cStatusImageView: NSImageView!
    @IBAction func showAria2cInFinder(_ sender: Any) {
		NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: Preferences.shared.aria2cOptions.path(for: .aria2c))])
        initPathMenu()
	}
    @IBOutlet weak var aria2cConfsGridView: NSGridView!
    @IBAction func selectAria2c(_ sender: Any) {
		let openPanel = NSOpenPanel()
		openPanel.prompt = "Select"
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = false
		openPanel.allowsMultipleSelection = false
		openPanel.delegate = self
		openPanel.hidesOnDeactivate = true
		if let window = view.window {
			openPanel.beginSheetModal(for: window) { result in
				if result == .OK,
					let url = openPanel.url,
					FileManager.default.isExecutableFile(atPath: url.path) {
					Preferences.shared.aria2cOptions.customAria2c = url.path
				}
                DispatchQueue.main.async {
                    self.initPathMenu()
                }
			}
		}
	}
	
	@IBOutlet var aria2cConfPathPopUpButton: NSPopUpButton!
	@IBAction func showConfInFinder(_ sender: Any) {
		NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: Preferences.shared.aria2cOptions.path(for: .aria2cConf))])
	}
	@IBAction func selectConf(_ sender: Any) {
		let openPanel = NSOpenPanel()
		openPanel.prompt = "Select"
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = false
		openPanel.allowsMultipleSelection = false
		openPanel.allowedFileTypes = ["conf"]

		if let window = view.window {
			openPanel.beginSheetModal(for: window) { result in
				if result == .OK, let url = openPanel.url {
					Preferences.shared.aria2cOptions.customAria2cConf = url.path
					Preferences.shared.aria2cOptions.selectedAria2cConf = .custom
				}
				self.initConfMenu()
			}
		}
	}

	@objc var autoStartAria2c: Bool {
		get {
			return Preferences.shared.autoStartAria2c
		}
		set {
			Preferences.shared.autoStartAria2c = newValue
			initConfsView()
		}
	}
	
	@objc var restartAria2c: Bool {
		get {
			return Preferences.shared.restartAria2c
		}
		set {
			Preferences.shared.restartAria2c = newValue
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		initPathMenu()
		initConfMenu()
		initConfsView()
    }
	
	func menuDidClose(_ menu: NSMenu) {
		if menu == aria2cPathPopUpButton.menu {
            if let title = aria2cPathPopUpButton.selectedItem?.title,
                FileManager.default.isExecutableFile(atPath: title) {
                Preferences.shared.aria2cOptions.customAria2c = title
            }
            initPathMenu()
		} else if menu == aria2cConfPathPopUpButton.menu {
			switch aria2cConfPathPopUpButton.indexOfSelectedItem {
			case 0:
				Preferences.shared.aria2cOptions.selectedAria2cConf = .default🙂
			case 1:
				Preferences.shared.aria2cOptions.selectedAria2cConf = .custom
			default:
				initConfMenu()
			}
		}
	}
	
	func initConfsView() {
        aria2cConfsGridView.subviews.forEach {
            if let control = $0 as? NSControl {
                control.isEnabled = autoStartAria2c
            }
        }
	}
	
	
	func initPathMenu() {
		let options = Preferences.shared.aria2cOptions
		let path = options.customAria2c
        let paths = Aria2.shared.aria2c.aria2cPaths()
        aria2cStatusImageView.image = Aria2.shared.aria2c.checkCustomPath() ? NSImage(named: "NSStatusAvailable") : NSImage(named: "NSStatusUnavailable")
        
        if let menu = aria2cPathPopUpButton.menu {
            while menu.items.count > 3 {
                aria2cPathPopUpButton.menu?.removeItem(at: 0)
            }
            
            if paths.count > 0 {
                paths.enumerated().forEach {
                    menu.insertItem(NSMenuItem(title: $0.element, action: nil, keyEquivalent: ""), at: $0.offset)
                }
            }
            
            if let index = paths.firstIndex(of: path) {
                aria2cPathPopUpButton.selectItem(at: index)
            } else if FileManager.default.isExecutableFile(atPath: path) {
                menu.insertItem(NSMenuItem(title: path, action: nil, keyEquivalent: ""), at: 0)
                aria2cPathPopUpButton.selectItem(at: 0)
            } else {
                menu.insertItem(NSMenuItem(title: "-", action: nil, keyEquivalent: ""), at: 0)
                aria2cPathPopUpButton.selectItem(at: 0)
            }
        }
	}
	
	func initConfMenu() {
		
		let options = Preferences.shared.aria2cOptions
		let index = options.selectedIndex(.aria2cConf)
		let path = Preferences.shared.aria2cOptions.customAria2cConf
		if let button = aria2cConfPathPopUpButton {
			if index == 1 {
				if button.itemArray.count == 5 {
					button.item(at: 1)?.title = path
				} else if button.itemArray.count == 4 {
					button.insertItem(withTitle: path, at: 1)
				}
			}
			DispatchQueue.main.async {
				button.selectItem(at: index)
			}
		}
	}
    
}

extension AdvancedViewController: NSOpenSavePanelDelegate {
	func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
		var isDir: ObjCBool = ObjCBool(false)
		if FileManager.default.isExecutableFile(atPath: url.path), url.lastPathComponent == "aria2c" {
			return true
		} else if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
			return isDir.boolValue
		}
		return false
	}
	
}


struct Aria2cOptions {
	enum selectablePaths {
		case aria2c
		case aria2cConf
	}
	
	enum aria2cConfPaths: Int {
		case default🙂
		case custom
	}
    
    var customAria2c = ""
	
	let defaultAria2cConf: String = {
		do {
			var url = try FileManager.default.url(for: .applicationSupportDirectory , in: .userDomainMask, appropriateFor: nil, create: true)
			url.appendPathComponent(Bundle.main.bundleIdentifier!)
			url.appendPathComponent("Aria2D.conf")
			return url.path
		} catch { }
		return ""
	}()
	
	var customAria2cConf = ""
	var selectedAria2cConf: aria2cConfPaths = .default🙂
	var lastPID = ""
	var lastLaunch = ""
	
	init() {
	}
	
	mutating func resetLastConf() {
		lastPID = ""
		lastLaunch = ""
	}
	
	func path(for selectablePaths: selectablePaths) -> String {
		switch selectablePaths {
		case .aria2c:
            return customAria2c
		case .aria2cConf:
			switch selectedAria2cConf {
			case .default🙂:
				return defaultAria2cConf
			case .custom:
				return customAria2cConf == "" ? defaultAria2cConf : customAria2cConf
			}
		}
	}
	
	
	func selectedIndex(_ selectablePaths: selectablePaths) -> Int {
		switch selectablePaths {
		case .aria2c:
//            switch selectedAria2c {
//            case .internal🙂:
//                return 0
//            case .system:
//                return 1
//            case .custom:
//                return customAria2c == "" ? 0 : 2
//            }
            return 0
		case .aria2cConf:
			switch selectedAria2cConf {
			case .default🙂:
				return 0
			case .custom:
				return customAria2cConf == "" ? 0 : 1
			}
		}
	}
	
	
	init?(data: Data) {
		if let coding = NSKeyedUnarchiver.unarchiveObject(with: data) as? Encoding {
			customAria2c = coding.customAria2c
			customAria2cConf = coding.customAria2cConf
			selectedAria2cConf = coding.selectedAria2cConf
			lastPID = coding.lastPID
			lastLaunch = coding.lastLaunchPath
		} else {
			return nil
		}
	}
	
	
	func encode() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: Encoding(self))
	}
	
//	@objc(Encoding)
	@objc(_TtCV6Aria2D13Aria2cOptionsP33_AF457B311616EC08278CC3017ADC7BED8Encoding)
	private class Encoding: NSObject, NSCoding {
		
		var customAria2c = ""
		var customAria2cConf = ""
		var selectedAria2cConf: aria2cConfPaths = .default🙂
		
		var lastPID = ""
		var lastLaunchPath = ""
		
		init(_ aria2cOptions: Aria2cOptions) {
			customAria2c = aria2cOptions.customAria2c
			customAria2cConf = aria2cOptions.customAria2cConf
			selectedAria2cConf = aria2cOptions.selectedAria2cConf
			lastPID = aria2cOptions.lastPID
			lastLaunchPath = aria2cOptions.lastLaunch
		}
		
		required init?(coder aDecoder: NSCoder) {
			self.customAria2c = aDecoder.decodeObject(forKey: "customAria2c") as? String ?? ""
			self.customAria2cConf = aDecoder.decodeObject(forKey: "customAria2cConf") as? String ?? ""
			self.selectedAria2cConf = aria2cConfPaths(rawValue: aDecoder.decodeInteger(forKey: "selectedAria2cConf")) ?? .default🙂
			self.lastPID = aDecoder.decodeObject(forKey: "lastPID") as? String ?? ""
			self.lastLaunchPath = aDecoder.decodeObject(forKey: "lastLaunchPath") as? String ?? ""
		}
		
		func encode(with aCoder: NSCoder) {
			aCoder.encode(self.customAria2c, forKey: "customAria2c")
			aCoder.encode(self.customAria2cConf, forKey: "customAria2cConf")
			aCoder.encode(self.selectedAria2cConf.rawValue, forKey: "selectedAria2cConf")
			aCoder.encode(self.lastPID, forKey: "lastPID")
			aCoder.encode(self.lastLaunchPath, forKey: "lastLaunchPath")
			
		}
	}
	
}
