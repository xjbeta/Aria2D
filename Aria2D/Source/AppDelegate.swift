//
//  AppDelegate.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
    var mainWindowController: MainWindowController!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            
            schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        }, deleteRealmIfMigrationNeeded: true)
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let _ = try! Realm()
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
        
        DataManager.shared.deleteAll()
		Aria2Websocket.shared.initSocket()
		Baidu.shared.checkTokenEffective()
		Preferences.shared.checkPlistFile()
		Aria2.shared.aria2c.autoStart()
        
        let sb = NSStoryboard(name: "Main", bundle: nil)
        mainWindowController = sb.instantiateController(withIdentifier: "MainWindowController") as? MainWindowController
        mainWindowController.showWindow(self)
        self.setDevMate()
        
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
    
}

extension AppDelegate: DevMateKitDelegate {
	
	func setDevMate() {
		#if DEBUG
			DMKitDebugAddDevMateMenu()
		#endif
		//DevMate
		DevMateKit.sendTrackingReport(nil, delegate: self)
		
        //        DevMateKit.setupIssuesController(self, reportingUnhandledIssues: true)
		
		if !string_check(nil).boolValue {
			DevMateKit.setupTimeTrial(self, withTimeInterval: kDMTrialWeek)
		}
		NotificationCenter.default.addObserver(self, selector: #selector(activateApp), name: .activateApp, object: nil)
		
	}
	
    @objc func feedbackController(_ controller: DMFeedbackController, parentWindowFor mode: DMFeedbackMode) -> NSWindow {
        return mainWindowController.window!
	}
	
	@objc func activationController(_ controller: DMActivationController!, parentWindowFor mode: DMActivationMode) -> NSWindow? {
		return mainWindowController.window
	}
	
	@objc func activationController(_ controller: DMActivationController!, shouldShowDialogFor reason: DMShowDialogReason, withAdditionalInfo additionalInfo: [AnyHashable : Any]!, proposedActivationMode ioProposedMode: UnsafeMutablePointer<DMActivationMode>!, completionHandlerSetter handlerSetter: ((DMCompletionHandler?) -> Void)!) -> Bool {
		ioProposedMode.pointee = .sheet
		handlerSetter { _ in
			ViewControllersManager.shared.showAria2cAlert()
		}
		return true
	}
	
	@objc func activateApp() {
		// Swift does't work with macros, so check our Examples project on GitHub (https://github.com/DevMate/DevMateKit)
		// to see how to create _my_secret_activation_check variable
		if !string_check(nil).boolValue {
			DevMateKit.runActivationDialog(self, in: .sheet)
		} else if let window = mainWindowController.window,
            let license = string_info()?.takeUnretainedValue() as? [String: AnyObject] {
			
			let licenseSheet = NSAlert()
			licenseSheet.messageText = "Your application is already activated."
			
//			Log(license)
			
			licenseSheet.informativeText = "This product is licensed to:\n    email: \(license["email"] as? String ?? "")\n    activation id: \(license["activation_number"] as? String ?? "")"
			licenseSheet.addButton(withTitle: "OK")
			licenseSheet.addButton(withTitle: "Invalidate License")
			
			DispatchQueue.main.async {
				licenseSheet.beginSheetModal(for: window) {
					if $0 == .alertSecondButtonReturn {
						InvalidateAppLicense()
					}
				}
			}
		}
	}
}
