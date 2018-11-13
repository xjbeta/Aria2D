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
        do {
            let _ = try Realm()
        } catch let error {
            assert(false, "Can't init Realm database: \(error)")
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
        
        DataManager.shared.deleteAll()
        
        let sb = NSStoryboard(name: "Main", bundle: nil)
        mainWindowController = sb.instantiateController(withIdentifier: "MainWindowController") as? MainWindowController
        mainWindowController.showWindow(self)
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
	
    @objc func activationController(_ controller: DMActivationController, parentWindowFor mode: DMActivationMode) -> NSWindow? {
		return mainWindowController.window
	}
    
    @objc private func activationController(_ controller: DMActivationController!, shouldShowDialogFor reason: DMShowDialogReason, withAdditionalInfo additionalInfo: [AnyHashable : Any]!, proposedActivationMode ioProposedMode: UnsafeMutablePointer<DMActivationMode>!, completionHandlerSetter handlerSetter: ((DMCompletionHandler?) -> Void)!) -> Bool {
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
			
			let licenseAlert = NSAlert()
			licenseAlert.messageText = NSLocalizedString("licenseInfo.messageText", comment: "")
            
			licenseAlert.informativeText = "This product is licensed to:\n    email: \(license["email"] as? String ?? "")\n    activation id: \(license["activation_number"] as? String ?? "")"
            
			licenseAlert.addButton(withTitle: NSLocalizedString("licenseInfo.okButton", comment: ""))
			licenseAlert.addButton(withTitle: NSLocalizedString("licenseInfo.invalidateButton", comment: ""))
			
            
            let warningAlert = NSAlert()
            warningAlert.alertStyle = .critical
            warningAlert.messageText = NSLocalizedString("licenseInfo.invalidateButton", comment: "")
            warningAlert.informativeText = NSLocalizedString("licenseInfo.informativeText", comment: "")
            warningAlert.addButton(withTitle: NSLocalizedString("licenseInfo.okButton", comment: ""))
            warningAlert.addButton(withTitle: NSLocalizedString("licenseInfo.cancelButton", comment: ""))
            
			DispatchQueue.main.async {
				licenseAlert.beginSheetModal(for: window) {
					if $0 == .alertSecondButtonReturn {
                        let response = warningAlert.runModal()
                        if response == .alertFirstButtonReturn {
                            InvalidateAppLicense()
                        }
					}
				}
			}
		}
	}
}
