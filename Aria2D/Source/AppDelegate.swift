//
//  AppDelegate.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

@NSApplicationMain
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
            try DataManager.shared.initAria2List()
            DataManager.shared.deleteAllAria2Objects()
            DataManager.shared.cleanUpLogs()
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
        
        self.setDevMate()
        Aria2Websocket.shared.initSocket()
        Preferences.shared.checkPlistFile()
        Aria2.shared.aria2c.autoStart()
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
	
    
	
	func applicationWillTerminate(_ notification: Notification) {
		Aria2.shared.aria2c.autoClose()
	}
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if let file = filenames.filter({ FileManager.default.fileExists(atPath: $0) }).first {
            ViewControllersManager.shared.openTorrent(file)
        }
    }
    
    func applicationDidChangeOcclusionState(_ notification: Notification) {
        if NSApp.occlusionState.rawValue == 8194 {
            //visible
            Aria2Websocket.shared.resumeTimer()
        } else {
            //Occlusion
            Aria2Websocket.shared.suspendTimer()
        }
    }
    
    @objc func handleURLEvent(event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let url = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue else { return }
        Log("URL event: \(url)")
        ViewControllersManager.shared.openUrl(url)
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
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Aria2D")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving and Undo support
    
    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

    
}

extension AppDelegate: DevMateKitDelegate {
	
	func setDevMate() {
		#if DEBUG
			DMKitDebugAddDevMateMenu()
		#endif
		//DevMate
        if let url = logUrl {
            DevMateKit.setupCustomLogFileURLs([url as NSURL,
                                               NSURL(fileURLWithPath: Aria2.shared.aria2c.logPath)])
        }
        
		DevMateKit.sendTrackingReport(nil, delegate: self)
		
        DevMateKit.setupIssuesController(self, reportingUnhandledIssues: true)
		
	}
	
    @objc func feedbackController(_ controller: DMFeedbackController, parentWindowFor mode: DMFeedbackMode) -> NSWindow {
        return mainWindowController.window!
	}
	
}
