//
//  LogViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/18.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

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
        ViewControllersManager.shared.deleteAllLog()
		logTableView.reloadData()
	}

	@IBOutlet var logTableView: NSTableView!
	var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
		recordLog.state = Preferences.shared.recordWebSocketLog ? .on : .off
        hideActive.state = Preferences.shared.hideActiveLog ? .on : .off
        updateLog()
    }
    
    func updateLog() {
        notificationToken?.invalidate()
        notificationToken = getLogs().bind(to: logTableView, animated: true)
        logTableView.reloadData()
    }
    
	
    @IBAction func copyJSON(_ sender: Any) {
        if let str = getLogs()[safe: logTableView.clickedRow]?.receivedJSON {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([str as NSString])
        }
    }
    
    func getLogs() -> Results<WebSocketLog> {
        return Preferences.shared.hideActiveLog ? ViewControllersManager.shared.getLogs().filter("method != %@", "updateActiveTasks()") : ViewControllersManager.shared.getLogs()
    }
    
	func numberOfRows(in tableView: NSTableView) -> Int {
		return getLogs().count
	}
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let identifier = tableColumn?.identifier,
            let log = getLogs()[safe: row] {
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
    
    deinit {
        notificationToken?.invalidate()
    }
}
