//
//  MainWindow.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSDraggingDestination {
	
	var hud: HUD?

    override func windowDidLoad() {
        super.windowDidLoad()
		if let window = window {
			window.titlebarAppearsTransparent = true
			window.titleVisibility = .hidden
			window.isMovableByWindowBackground = true
            window.registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeURL as String)])
			if let view = window.contentView {
				hud = HUD(view)
			}
			initNotification()
		}
		ViewControllersManager.shared.showAria2cAlert()
	}

	
	func initNotification() {
		NotificationCenter.default.addObserver(forName: .showHUD, object: nil, queue: .main) {
			if let userInfo = $0.userInfo as? [String: Any] {
				self.showHUD(message: userInfo["message"] as? hudMessage ?? .error)
			}
		}
	}
	
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            return urls.contains {
                $0.pathExtension == "torrent"
            } ? .copy : []
        }
        return []
    }

    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            if let url = urls.filter({ $0.pathExtension == "torrent" }).first {
                ViewControllersManager.shared.openTorrent(url.path)
                return true
            }
        }
        return false
    }
    
	
	func showHUD(message: hudMessage) {
		hud?.showHUD(message)
	}
	
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}


