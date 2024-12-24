//
//  Aria2OptionsViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2019/1/11.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class Aria2OptionsViewController: NSViewController, NSMenuDelegate {
    
// MARK: - Aria2c Process Status
    @objc var autoStartAria2c: Bool {
        get {
            return Preferences.shared.autoStartAria2c
        }
        set {
            Preferences.shared.autoStartAria2c = newValue
            initConfsView()
        }
    }
    
    
// MARK: - Aria2 paths And save interval

    @IBOutlet var aria2cPathPopUpButton: NSPopUpButton!
    @IBOutlet weak var aria2cStatusImageView: NSImageView!
    @IBAction func showAria2cInFinder(_ sender: Any) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: Preferences.shared.aria2cOptions.path(for: .aria2c))])
        initPathMenu()
    }
    
    @IBAction func installAria2Guide(_ sender: NSMenuItem) {
        performSegue(withIdentifier: .init("ShowInstallAria2GuideSegue"), sender: sender)
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
    
    @IBOutlet weak var autoSaveIntervalSlider: NSSlider!
    @IBOutlet weak var saveSessionIntervalSlider: NSSlider!
    @IBOutlet weak var autoSaveIntervalTextField: NSTextField!
    @IBOutlet weak var saveSessionIntervalTextField: NSTextField!
    
    // MARK: - Aria2 RPC

    @IBOutlet weak var enableRpcButton: NSButton!
    @IBOutlet weak var rpcListenAllButton: NSButton!
    @IBOutlet weak var rpcListenPortTextField: NSTextField!
    @IBOutlet weak var rpcSecretTextField: NSTextField!
    @IBOutlet weak var randomSecretButton: NSButton!
    @IBAction func randomSecret(_ sender: Any) {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let key = String((0..<16).map{ _ in letters.randomElement()! })
        rpcSecretTextField.stringValue = key
        updateOption(for: rpcSecretTextField)
    }
    
    // MARK: - Normal Download Options
    
    @IBOutlet weak var dirPopUpButton: NSPopUpButton!
    @IBOutlet weak var dirMenuItem: NSMenuItem!
    
    @IBAction func showDirInFinder(_ sender: Any) {
        if let dir = Preferences.shared.aria2Conf[.dir] {
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
            selectDirPanel.beginSheetModal(for: window) { result in
                if result == .OK, let url = self.selectDirPanel.url {
                    Preferences.shared.updateConf(key: .dir, with: url.path)
                }
                self.initDirMenu()
            }
        }
    }
    
    @IBOutlet weak var maxConcurrentDownloadsTextField: NSTextField!
    @IBOutlet weak var minSplitSizeTextField: NSTextField!
    @IBOutlet weak var splitSlider: NSSlider!
    @IBOutlet weak var splitValueTextField: NSTextField!
    @IBOutlet weak var userAgentTextField: NSTextField!
    
    // MARK: - BitTorrent Options
    
    @IBOutlet weak var btTrackerTextField: NSTextField!
    @IBOutlet weak var peerAgentTextField: NSTextField!
    @IBOutlet weak var seedRatioTextField: NSTextField!
    @IBOutlet weak var seedTimeTextField: NSTextField!
    
    @IBAction func sliderAction(_ sender: NSSlider) {
        let v = "\(sender.integerValue)"
        switch sender {
        case autoSaveIntervalSlider:
            Preferences.shared.updateConf(key: .autoSaveInterval, with: v)
            autoSaveIntervalTextField.integerValue = sender.integerValue
        case saveSessionIntervalSlider:
            Preferences.shared.updateConf(key: .saveSessionInterval, with: v)
            saveSessionIntervalTextField.integerValue = sender.integerValue
        case splitSlider:
            Preferences.shared.updateConf(key: .split, with: v)
            splitValueTextField.integerValue = sender.integerValue
        default:
            break
        }
    }
    @IBAction func checkButtonAction(_ sender: NSButton) {
        let v = "\(sender.state == .on)"
        switch sender {
        case enableRpcButton:
            Preferences.shared.updateConf(key: .enableRpc, with: v)
        case rpcListenAllButton:
            Preferences.shared.updateConf(key: .rpcListenAll, with: v)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPathMenu()
        initConfMenu()
        initDirMenu()
        initConfsView()
        
        let confs = Preferences.shared.aria2Conf
        
        autoSaveIntervalSlider.integerValue = confIntValue(.autoSaveInterval)
        saveSessionIntervalSlider.integerValue = confIntValue(.saveSessionInterval)
        autoSaveIntervalTextField.integerValue = autoSaveIntervalSlider.integerValue
        saveSessionIntervalTextField.integerValue = saveSessionIntervalSlider.integerValue
        
        enableRpcButton.state = confs[.enableRpc] == "true" ? .on : .off
        rpcListenAllButton.state = confs[.rpcListenAll] == "true" ? .on : .off
        rpcListenPortTextField.integerValue = confIntValue(.rpcListenPort)
        
        rpcSecretTextField.stringValue = confStringValue(.rpcSecret)
        
        maxConcurrentDownloadsTextField.integerValue = confIntValue(.maxConcurrentDownloads)
        splitSlider.integerValue = confIntValue(.split)
        splitValueTextField.integerValue = splitSlider.integerValue
        minSplitSizeTextField.stringValue = confStringValue(.minSplitSize)
        userAgentTextField.stringValue = confStringValue(.userAgent)
        
        btTrackerTextField.stringValue = confStringValue(.btTracker)
        peerAgentTextField.stringValue = confStringValue(.peerAgent)
        seedRatioTextField.stringValue = confStringValue(.seedRatio)
        seedTimeTextField.integerValue = confIntValue(.seedTime)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBTTracker), name: .updateBtTracker, object: nil)
    }
    
    @objc func updateBTTracker() {
        btTrackerTextField.stringValue = confStringValue(.btTracker)
    }
    
    func confStringValue(_ key: Aria2Option) -> String {
        let confs = Preferences.shared.aria2Conf
        let defaultConfs = Preferences.shared.defaultAria2cOptionsDic
        return confs[key] ?? defaultConfs[key] ?? ""
    }
    
    func confIntValue(_ key: Aria2Option) -> Int {
        let confs = Preferences.shared.aria2Conf
        let defaultConfs = Preferences.shared.defaultAria2cOptionsDic
        return Int(confs[key] ?? "") ?? Int(defaultConfs[key] ?? "") ?? 0
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
        } else if menu == dirPopUpButton.menu {
            initDirMenu()
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
            while menu.items.count > 5 {
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
        DispatchQueue.main.async {
            self.dirPopUpButton.selectItem(at: 0)
        }
        
        guard let dir = Preferences.shared.aria2Conf[.dir] else {
            dirMenuItem.title = "Unknown"
            return
        }

        let image = NSWorkspace.shared.icon(forFile: dir)
        image.size = NSSize(width: 16, height: 16)
        dirMenuItem.image = image
        dirMenuItem.title = dir.lastPathComponent
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

extension Aria2OptionsViewController: NSControlTextEditingDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let obj = obj.object as? NSObject,
            let textField = obj as? NSTextField else { return }
        updateOption(for: textField)
    }
    
    func updateOption(for obj: NSTextField) {
        var key: Aria2Option?
        switch obj {
        case rpcListenPortTextField:
            key = .rpcListenPort
        case rpcSecretTextField:
            key = .rpcSecret
        case maxConcurrentDownloadsTextField:
            key = .maxConcurrentDownloads
        case minSplitSizeTextField:
            key = .minSplitSize
        case userAgentTextField:
            key = .userAgent
        case btTrackerTextField:
            key = .btTracker
        case peerAgentTextField:
            key = .peerAgent
        case seedRatioTextField:
            key = .seedRatio
        case seedTimeTextField:
            key = .seedTime
        default:
            break
        }
        
        guard let k = key else { return }
        var v = ""
        switch k {
        case .rpcListenPort, .maxConcurrentDownloads, .seedTime:
            v = "\(obj.integerValue)"
        default:
            v = obj.stringValue
        }
        
        // ignore empty value
        if v == "" {
            Preferences.shared.deleteConfObject(k)
        } else {
            Preferences.shared.updateConf(key: k, with: v)
        }
    }
}
