//
//  LogViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/18.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

struct WebSocketLog {
	var time: TimeInterval = 0
	var method = ""
	var success = false
	var sendJSON = ""
	var receivedJSON = ""
}


class LogViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	@IBOutlet var recordLog: NSButton!
	@IBAction func recordLog(_ sender: Any) {
		Preferences.shared.recordWebSocketLog = recordLog.state == .on
	}
	@IBAction func refresh(_ sender: Any) {
		webSocketLog = ViewControllersManager.shared.webSocketLog
		logTableView.reloadData()
	}
	
	@IBAction func clear(_ sender: Any) {
		webSocketLog.removeAll()
		ViewControllersManager.shared.webSocketLog.removeAll()
		logTableView.reloadData()
	}

	@IBOutlet var logTableView: NSTableView!
	var webSocketLog: [WebSocketLog] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		recordLog.state = Preferences.shared.recordWebSocketLog ? .on : .off
		webSocketLog = ViewControllersManager.shared.webSocketLog
		logTableView.reloadData()
    }
	
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		
		return webSocketLog.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		if let identifier = tableColumn?.identifier.rawValue, let log = webSocketLog[safe: row] {
			switch identifier {
			case "LogTableTime":
				let date = Date(timeIntervalSince1970: log.time)
				let formatter = DateFormatter()
				formatter.dateFormat = "HH:mm:ss"				
				return formatter.string(from: date)
			case "LogTableMethod":
				return log.method
			case "LogTableSuccess":
				return "\(log.success)"
			case "LogTableSendJSON":
				return log.sendJSON
			case "LogTableReceivedJSON":
				return log.receivedJSON
			default:
				break
			}
		}
		return nil
	}
}
