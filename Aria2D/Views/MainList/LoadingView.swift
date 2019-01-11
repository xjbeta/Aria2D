//
//  LoadingView.swift
//  Aria2D
//
//  Created by xjbeta on 2016/11/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class LoadingView: NSView {

	@IBOutlet var label: NSTextField!
	@IBOutlet var versionLabel: NSTextField!
	
	@IBOutlet var featuresLabel: NSTextField!
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

	}
	
	func initVersionInfo() {
		updateVersionInfo()
        NotificationCenter.default.addObserver(forName: .updateConnectStatus, object: nil, queue: .main) { _ in
            self.updateVersionInfo()
        }
	}
	

	func updateVersionInfo() {
        let info = Aria2Websocket.shared.connectedServerInfo
        self.versionLabel.stringValue = info.version
        self.featuresLabel.stringValue = Preferences.shared.showAria2Features ? info.enabledFeatures : ""
        if Aria2Websocket.shared.isConnected {
            self.label.stringValue = info.name
        } else {
            self.label.stringValue = "Connecting..."
        }
	}
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
