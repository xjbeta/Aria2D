//
//  InfoWindowController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/6.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class InfoWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
		
		if let window = window {
			window.titlebarAppearsTransparent = true
			window.titleVisibility = .hidden
			window.isMovableByWindowBackground = true
            window.standardWindowButton(.zoomButton)?.superview?.isHidden = true
            
		}
    }
	
	override func keyDown(with event: NSEvent) {
		let commandKey = NSEvent.ModifierFlags.command.rawValue
		if event.type == .keyDown {
			if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
				switch event.charactersIgnoringModifiers! {
				case "w":
					window?.close()
					return
				default:
					break
				}
			}
		}
		super.keyDown(with: event)
	}
}

