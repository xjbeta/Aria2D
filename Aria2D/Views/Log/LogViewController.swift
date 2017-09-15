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
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		if let identifier = tableColumn?.identifier,
            let log = webSocketLog[safe: row] {
            var text = ""
			switch identifier.rawValue {
			case "LogTableTime":
				let date = Date(timeIntervalSince1970: log.time)
				let formatter = DateFormatter()
				formatter.dateFormat = "HH:mm:ss"				
				text = formatter.string(from: date)
			case "LogTableMethod":
				text = log.method
			case "LogTableSuccess":
				text = "\(log.success)"
			case "LogTableSendJSON":
				text = log.sendJSON
			case "LogTableReceivedJSON":
                if let cell = tableView.makeView(withIdentifier: .receivedJSONTableCellView, owner: nil) as? ReceivedJSONTableCellView {
                    cell.text = log.receivedJSON
                    return cell
                }
			default:
				return nil
			}
            if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
		}
		return nil
	}
}
