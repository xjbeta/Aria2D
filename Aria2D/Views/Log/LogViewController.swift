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
    @IBOutlet weak var hideActive: NSButton!
    @IBAction func hideActive(_ sender: Any) {
        Preferences.shared.hideActiveLog = hideActive.state == .on
        updateLog()
    }
    @IBAction func refresh(_ sender: Any) {
		updateLog()
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
        hideActive.state = Preferences.shared.hideActiveLog ? .on : .off
        updateLog()
    }
    
    func updateLog() {
        webSocketLog = ViewControllersManager.shared.webSocketLog
        if Preferences.shared.hideActiveLog {
            webSocketLog = webSocketLog.filter {
                $0.method != "updateActiveTasks()"
            }
        }
        
        
        
        logTableView.reloadData()
    }
    
	
    @IBAction func copyJSON(_ sender: Any) {
        if let str = webSocketLog[safe: logTableView.clickedRow]?.receivedJSON {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([str as NSString])
        }
    }
    
	func numberOfRows(in tableView: NSTableView) -> Int {
		return webSocketLog.count
	}
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if let identifier = tableColumn?.identifier,
            let log = webSocketLog[safe: row] {
            switch identifier.rawValue {
            case "LogTableTime":
                let date = Date(timeIntervalSince1970: log.time)
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                return formatter.string(from: date)
            case "LogTableMethod":
                return log.method
            case "LogTableSuccess":
                return log.success ? NSControl.StateValue.on : NSControl.StateValue.off
            case "LogTableSendJSON":
                return log.sendJSON
            default:
                break
            }
        }
        return nil
    }
}
