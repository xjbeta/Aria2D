//
//  Aria2OptionsViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2019/1/11.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class Aria2OptionsViewController: NSViewController, NSMenuDelegate {
    
// MARK: - Aria2 paths And save interval

    @IBOutlet var aria2cPathPopUpButton: NSPopUpButton!
    @IBOutlet weak var aria2cStatusImageView: NSImageView!
    @IBAction func showAria2cInFinder(_ sender: Any) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: Preferences.shared.aria2cOptions.path(for: .aria2c))])
        initPathMenu()
    }
    @IBOutlet weak var aria2cConfsGridView: NSGridView!
    lazy var selectAria2cPanel = NSOpenPanel()
    @IBAction func selectAria2c(_ sender: Any) {
        selectAria2cPanel.prompt = "Select"
        selectAria2cPanel.canChooseFiles = true
        selectAria2cPanel.canChooseDirectories = false
        selectAria2cPanel.allowsMultipleSelection = false
        selectAria2cPanel.delegate = self
        selectAria2cPanel.hidesOnDeactivate = true
        if let window = view.window {
            selectAria2cPanel.beginSheetModal(for: window) { result in
                if result == .OK,
                    let url = self.selectAria2cPanel.url,
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
    
    lazy var selectConfPanel = NSOpenPanel()
    @IBAction func selectConf(_ sender: Any) {
        selectConfPanel.prompt = "Select"
        selectConfPanel.canChooseFiles = true
        selectConfPanel.canChooseDirectories = false
        selectConfPanel.allowsMultipleSelection = false
        selectConfPanel.allowedFileTypes = ["conf"]
        
        if let window = view.window {
            selectConfPanel.beginSheetModal(for: window) { result in
                if result == .OK, let url = self.selectConfPanel.url {
                    Preferences.shared.aria2cOptions.customAria2cConf = url.path
                    Preferences.shared.aria2cOptions.selectedAria2cConf = .custom
                }
                self.initConfMenu()
            }
        }
    }
    @IBOutlet weak var dirPopUpButton: NSPopUpButton!
    @IBOutlet weak var dirMenuItem: NSMenuItem!
    
    @IBAction func showDirInFinder(_ sender: Any) {
        if let dir = Preferences.shared.aria2cOptionsDic["dir"] as? String {
            NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: dir)])
        }
    }
    
    lazy var selectDirPanel = NSOpenPanel()
    @IBAction func selectDir(_ sender: Any) {
        selectDirPanel.prompt = "Select"
        selectDirPanel.canChooseFiles = false
        selectDirPanel.canChooseDirectories = true
        selectDirPanel.allowsMultipleSelection = false
        
        if let window = view.window {
            selectConfPanel.beginSheetModal(for: window) { result in
                if result == .OK, let url = self.selectConfPanel.url {
                    var dic = Preferences.shared.aria2cOptionsDic
                    dic["dir"] = url.path
                    Preferences.shared.updateAria2cOptionsDic(dic)
                }
//                self.initConfMenu()
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
//        aria2cConfsGridView.subviews.forEach {
//            if let control = $0 as? NSControl {
//                control.isEnabled = autoStartAria2c
//            }
//        }
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
        guard let button = aria2cConfPathPopUpButton else {
            return
        }
        
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
    
    func initDirMenu() {
        guard let dir = Preferences.shared.aria2cOptionsDic["dir"] as? String else {
            return
        }
        
        let image = NSWorkspace.shared.icon(forFile: dir)
        image.size = NSSize(width: 16, height: 16)
        dirMenuItem.image = image
        dirMenuItem.title = dir.lastPathComponent
        dirPopUpButton.selectItem(at: 0)
    }
}

extension Aria2OptionsViewController: NSOpenSavePanelDelegate {
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
