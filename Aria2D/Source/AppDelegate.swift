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
	
	var window: NSWindow? {
		return NSApp.mainWindow
	}
	
    func applicationDidFinishLaunching(_ aNotification: Notification) {
		
        if !ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 11, patchVersion: 0)) {
			let alert: NSAlert = NSAlert()
			alert.messageText = "This version of macOS does not support Aria2D"
			alert.informativeText = "Update your Mac to version 10.11 or higher to use Aria2D."
			alert.alertStyle = .warning
			alert.addButton(withTitle: "OK")
			alert.runModal()
			
			NSApp.terminate(self)
		}
		
		
		self.setDevMate()
		Aria2Websocket.shared.initSocket()
		Baidu.shared.checkLogin(nil)
		Preferences.shared.checkPlistFile()
		Aria2.shared.aria2c.autoStart()
	}
	
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
				if window.className == "NSWindow" {
					window.className.sort()
					window.makeKeyAndOrderFront(self)
				}
            }
        }
        return true
    }
	
	func applicationWillBecomeActive(_ notification: Notification) {
		Aria2Websocket.shared.resumeTimer()
	}
	
	func applicationWillResignActive(_ notification: Notification) {
		Aria2Websocket.shared.suspendTimer()
	}
	
	func applicationWillTerminate(_ notification: Notification) {
		Aria2.shared.aria2c.autoClose()
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
	
	@objc func feedbackController(_ controller: DMFeedbackController!, parentWindowFor mode: DMFeedbackMode) -> NSWindow? {
		return self.window
	}
	
	@objc func activationController(_ controller: DMActivationController!, parentWindowFor mode: DMActivationMode) -> NSWindow? {
		return self.window
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
		} else if let window = self.window, let license = string_info()?.takeUnretainedValue() as? [String: AnyObject] {
			
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
