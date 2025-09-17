//
//  AppDelegate.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
    var mainWindowController: MainWindowController!
    
    lazy var logUrl: URL? = {
        do {
            var logPath = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            logPath.appendPathComponent(Bundle.main.bundleIdentifier!)
            var isDir = ObjCBool(false)
            if !FileManager.default.fileExists(atPath: logPath.path, isDirectory: &isDir) {
                try FileManager.default.createDirectory(at: logPath, withIntermediateDirectories: true, attributes: nil)
            }
            guard let appName = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else {
                return nil
            }
            logPath.appendPathComponent("\(appName).log")
            return logPath
        } catch let error {
            Log(error)
            return nil
        }
    }()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        deleteUselessFiles()
        
        Log("App will finish launching")
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        Log("App Version \(version) (Build \(build))")
        Log("macOS " + ProcessInfo().operatingSystemVersionString)
        
        
        do {
            try DataManager.shared.deleteAllAria2Objects()
//            try DataManager.shared.cleanUpExpiredLogs()
            try DataManager.shared.clearAllLogs()
        } catch let error {
            assert(false, "Can't init Aria2List in Core Data: \(error)")
        }
    }
	
    func applicationDidFinishLaunching(_ aNotification: Notification) {
		
        if !ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 12, patchVersion: 0)) {
			let alert: NSAlert = NSAlert()
			alert.messageText = "This version of macOS does not support Aria2D"
			alert.informativeText = "Update your Mac to version 10.12 or higher to use Aria2D."
			alert.alertStyle = .warning
			alert.addButton(withTitle: "OK")
			alert.runModal()
			
			NSApp.terminate(self)
		}
        
        let sb = NSStoryboard(name: "Main", bundle: nil)
        mainWindowController = sb.instantiateController(withIdentifier: "MainWindowController") as? MainWindowController
        mainWindowController.showWindow(self)
        
        // register for url event
        Preferences.shared.setLaunchServer()
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(self.handleURLEvent(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        Aria2Websocket.shared.initSocket()
        Preferences.shared.checkPlistFile()
        Task {
            await Aria2.shared.aria2c.autoStart()
        }
	}
	
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
				if window.className == "NSWindow" {
					window.makeKeyAndOrderFront(self)
				}
            }
        }
        return true
    }
	
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if let file = filenames.filter({ FileManager.default.fileExists(atPath: $0) }).first {
            ViewControllersManager.shared.openTorrent(file)
        }
    }
    
    func applicationDidChangeOcclusionState(_ notification: Notification) {
        if NSApp.occlusionState.rawValue == 8194 {
            //visible
            Aria2Websocket.shared.startTimer()
        } else {
            //Occlusion
            if !Preferences.shared.showDockIconSpeed {
                Aria2Websocket.shared.stopTimer()
            }
        }
    }
    
    @objc func handleURLEvent(event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let url = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue else { return }
        Log("URL event: \(url)")
        Task {
            await ViewControllersManager.shared.openUrl(url)
        }
    }
    
    func deleteUselessFiles() {
        if let url = logUrl {
            try? FileManager.default.removeItem(at: url)
        }
        if var url = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                 in: .userDomainMask,
                                                 appropriateFor: nil,
                                                 create: true) {
            // Remove Old Log
            var logPath = url
            logPath.appendPathComponent("Aria2D")
            logPath.appendPathComponent("Aria2D.log")
            try? FileManager.default.removeItem(atPath: logPath.path)
            
            // Remove Old Realm Files
            url.appendPathComponent(Bundle.main.bundleIdentifier!)
            try? FileManager.default.removeItem(atPath: url.path + "/default.realm")
            try? FileManager.default.removeItem(atPath: url.path + "/default.realm.lock")
            try? FileManager.default.removeItem(atPath: url.path + "/default.realm.management")
        }
        
        UserDefaults.standard.removeObject(forKey: PreferenceKeys.restartAria2c.rawValue)
        
        // Core Data
        if let path = NSPersistentContainer(name: "Aria2D").persistentStoreDescriptions.first?.url?.path {
            
            try? FileManager.default.removeItem(atPath: path)
            try? FileManager.default.removeItem(atPath: path + "-shm")
            try? FileManager.default.removeItem(atPath: path + "-wal")
        }
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // https://github.com/frankhu1089/Planet/blob/097a91949038536ae3218c9945f5240851191192/Planet/PlanetApp.swift#L159
        Task.detached(priority: .utility) {
            await Aria2c().autoClose()
            await NSApplication.shared.reply(toApplicationShouldTerminate: true)
        }
        
        return .terminateLater
    }
}

extension NSApplication {
    var `default`: AppDelegate {
        delegate as! AppDelegate
    }
}
