//
//  ViewControllersManager.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllersManager: NSObject {

    static let shared = ViewControllersManager()
    
    private override init() {
        super.init()
    }
	
	
	// MainWindow HUD
	func showHUD(_ message: hudMessage) {
		NotificationCenter.default.post(name: .showHUD, object: nil, userInfo: ["message": message])
	}
	
	private var aria2cAlertStr: String? = nil
	func showAria2cAlert(_ str: String? = nil) {
		let info = str ?? aria2cAlertStr ?? ""
		guard info != "" else { return }
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			if let mainWindow = NSApp.mainWindow, mainWindow.sheets.count == 0 {
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
			} else {
				self.aria2cAlertStr = info
			}
		}
		
		/*
		func runScript() {
			NSAppleScript(source: "tell application \"Terminal\" \n activate \n do script \"echo test your aria2c confs\" \n tell application \"System Events\" \n keystroke \"\(args)\" \n end tell \n end tell")?.executeAndReturnError(nil)
		}
		*/
	}
	
	
	
	// LeftSourceList Indicator
	private var waitingCount = 0
	
	var updateIndicator: (() -> Void)?
	
	var waiting: Bool {
		get {
			return waitingCount > 0
		}
		set {
			if newValue {
				waitingCount += 1
			} else if waitingCount > 0 {
				waitingCount -= 1
			}
			updateIndicator?()
		}
	}
	
	
    // LeftSourceList
    var selectedRowDidSet: (() -> Void)?
    
    var selectedRow: LeftSourceListRow = .none {
        willSet {
            if newValue == .baidu {
                Baidu.shared.getFileList(forPath: Baidu.shared.selectedPath)
            }
        }
        didSet {
            selectedRowDidSet?()
        }
    }

	// DownloadsTableView selectedIndexs
    var selectedIndexs = IndexSet()
	func showOptions() {
		NotificationCenter.default.post(name: .showOptionsWindow, object: self)
	}
	
	func showSelectedInFinder() {
		let urls = selectedUrls()
		if urls.count > 0 {
			NSWorkspace.shared.activateFileViewerSelecting(urls)
		}
	}
	
	func openSelected() {
		guard Preferences.shared.aria2Servers.isLocal else { return }
		DataManager.shared.data(Aria2Object.self).enumerated().filter {
			selectedIndexs.contains($0.offset)
			}.flatMap {
			$0.element.path()
			}.filter {
				FileManager.default.fileExists(atPath: $0.path)
			}.forEach {
				NSWorkspace.shared.open($0)
		}
	}
	
	func selectedUrls() -> [URL] {
		var urls = DataManager.shared.data(Aria2Object.self).enumerated().filter {
			selectedIndexs.contains($0.offset)
			}.flatMap {
				$0.element.path()
		}
		
		urls = urls.map {
			URL(fileURLWithPath: $0.path + ".aria2")
			} + urls
		return urls.filter {
			FileManager.default.fileExists(atPath: $0.path)
		}
	}
	
	
	func showStatus() {
		NotificationCenter.default.post(name: .showStatusWindow, object: self)
	}
	
	// LogViewController
	var webSocketLog: [WebSocketLog] = []
	
	// Front Window
	enum frontWindow {
		case main, preference, changeOption, about, other
	}
	var mainWindowFront: Bool {
		get {
			return NSApp.keyWindow?.windowController is MainWindowController
		}
	}
	
	
	// Aria2 Task

	
	var tasksShouldPause: Bool {
		get {
			if selectedRow == .downloading {
				let dataList = selectedIndexs.map {
					DataManager.shared.data(Aria2Object.self)[$0]
				}
				let canPauseList = dataList.filter {
					$0.status == .active || $0.status == .waiting
				}
				let pausedList = dataList.filter {
					$0.status == .paused
				}
				if canPauseList.count >= pausedList.count {
					return true
				}
			}
			return false
		}
	}
	
	func pauseOrUnpause() {
		if selectedRow == .downloading {
			let dataList = selectedIndexs.map {
				DataManager.shared.data(Aria2Object.self)[$0]
			}
			let canPauseList = dataList.filter {
				$0.status == .active || $0.status == .waiting
			}
			let pausedList = dataList.filter {
				$0.status == .paused
			}
			if canPauseList.count >= pausedList.count {
				Aria2.shared.pause(canPauseList.map { $0.gid })
			} else if canPauseList.count < pausedList.count {
				Aria2.shared.unpause(pausedList.map { $0.gid })
			}
		}
	}
	
	func deleteTask() {
		var gidForRemoveDownloadResult: [String] = []
		var gidForRemove: [String] = []
		
		ViewControllersManager.shared.selectedIndexs.forEach {
			let data = DataManager.shared.data(Aria2Object.self)[$0]
			let status = data.status
			let gid = data.gid
			if status == .complete || status == .error || status == .removed {
				gidForRemoveDownloadResult.append(gid)
			} else {
				gidForRemove.append(gid)
			}
		}
		
		Aria2.shared.removeDownloadResult(gidForRemoveDownloadResult)
		Aria2.shared.remove(gidForRemove)
	}
	
	func refresh() {
		switch selectedRow {
		case .downloading, .completed, .removed:
			Aria2.shared.initData()
		case .baidu:
			Baidu.shared.getFileList(forPath: Baidu.shared.selectedPath)
		default:
			break
		}
	}
}
