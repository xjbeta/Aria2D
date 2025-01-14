//
//  ViewControllersManager.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation
import Cocoa

@MainActor
final class ViewControllersManager: NSObject, Sendable {

    static let shared = ViewControllersManager()
    
    private override init() {
    }
	
    
    // NewTask Window
    func openTorrent(_ file: String) {
        NotificationCenter.default.post(name: .newTask, object: nil, userInfo: ["file": file])
    }
    
    func openUrl(_ url: String) {
        NotificationCenter.default.post(name: .newTask, object: nil, userInfo: ["url": url])
    }
    
	// MainWindow HUD
	func showHUD(_ message: hudMessage) {
		NotificationCenter.default.post(name: .showHUD, object: nil, userInfo: ["message": message])
	}
	
	private var aria2cAlertStr: String? = nil
    
	func showAria2cAlert(_ str: String? = nil) {
		let info = str ?? aria2cAlertStr ?? ""
		guard info != "" else { return }
        Task {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
            
            guard let mainWindow = NSApp.mainWindow,
                  mainWindow.sheets.count == 0 else {
                self.aria2cAlertStr = info
                return
            }
            
            
            let alert = NSAlert()
            alert.messageText = "Aria2c didn't started."
            alert.informativeText = info
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.alertStyle = .warning
            alert.beginSheetModal(for: mainWindow) {
                if $0 == .alertFirstButtonReturn {
                    
                }
            }
            
            self.aria2cAlertStr = nil
        }
		
		/*
		func runScript() {
			NSAppleScript(source: "tell application \"Terminal\" \n activate \n do script \"echo test your aria2c confs\" \n tell application \"System Events\" \n keystroke \"\(args)\" \n end tell \n end tell")?.executeAndReturnError(nil)
		}
		*/
	}
	
    // LeftSourceList
    var selectedRow: SidebarItem = .none {
        didSet {
            selectedObjects = [Aria2Object]()
            switch selectedRow {
            case .downloading, .removed, .completed:
                Task {
                    await Aria2.shared.initData.debounce()
                }
            default:
                break
            }
        }
    }

	// DownloadsTableView selectedObjects
    var selectedObjects = [Aria2Object]()
	
	func showSelectedInFinder() {
        let urls = selectedObjects.compactMap {
            $0.path()
        }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
	}
	
	func openSelected() {
		guard Preferences.shared.aria2Servers.isLocal else { return }
        selectedObjects.compactMap {
			$0.path()
			}.filter {
				FileManager.default.fileExists(atPath: $0.path)
			}.forEach {
				NSWorkspace.shared.open($0)
		}
	}
	
	func selectedUrls() -> [URL] {
		var urls = selectedObjects.compactMap {
				$0.path()
		}
		
		urls = urls.map {
			URL(fileURLWithPath: $0.path + ".aria2")
			} + urls
		return urls.filter {
			FileManager.default.fileExists(atPath: $0.path)
		}
	}
	
	
    func showInfo() {
        NotificationCenter.default.post(name: .showInfoWindow, object: nil)
    }
	
	// Front Window
	enum frontWindow {
		case main, preference, changeOption, about, other
	}
    
    @MainActor
	var mainWindowFront: Bool {
		get {
			return NSApp.keyWindow?.windowController is MainWindowController
		}
	}
	
	
	// Aria2 Task

	
	var tasksShouldPause: Bool {
		get {
            guard selectedRow == .downloading else { return false }
        
            let canPauseList = selectedObjects.filter {
                $0.status == Status.active.rawValue || $0.status == Status.waiting.rawValue
            }
            let pausedList = selectedObjects.filter {
                $0.status == Status.paused.rawValue
            }
            if canPauseList.count >= pausedList.count {
                return true
            }
			return false
		}
	}
	
    @MainActor
	func pauseOrUnpause() async {
        guard ViewControllersManager.shared.selectedRow == .downloading else { return }
        let dataList = selectedObjects
        
        let canPauseList = dataList.filter {
            $0.status == Status.active.rawValue || $0.status == Status.waiting.rawValue
        }
        let pausedList = dataList.filter {
            $0.status == Status.paused.rawValue
        }
        
        if canPauseList.count >= pausedList.count {
            try? await Aria2.shared.pause(canPauseList.compactMap { $0.gid })
        } else if canPauseList.count < pausedList.count {
            try? await Aria2.shared.unpause(pausedList.compactMap { $0.gid })
        }
	}
	
    @MainActor
    func deleteTask() async {
        var gidForRemoveDownloadResult: [String] = []
        var gidForRemove: [String] = []
        
        selectedObjects.forEach {
            let status = $0.status
            let gid = $0.gid
            if status == Status.complete.rawValue || status == Status.error.rawValue || status == Status.removed.rawValue {
                gidForRemoveDownloadResult.append(gid)
            } else {
                gidForRemove.append(gid)
            }
        }
        
        try? await Aria2.shared.removeDownloadResult(gidForRemoveDownloadResult)
        try? await Aria2.shared.remove(gidForRemove)
    }
	
	func refresh() {
		switch selectedRow {
		case .downloading, .completed, .removed:
            Task {
                await Aria2.shared.initData.debounce()
            }
		default:
			break
		}
	}
}
