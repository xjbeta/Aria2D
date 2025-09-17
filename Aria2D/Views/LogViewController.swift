//
//  LogViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/18.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa
import Foundation

class LogViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
	@IBOutlet var recordLog: NSButton!
	@IBAction func recordLog(_ sender: Any) {
		Preferences.shared.recordWebSocketLog = recordLog.state == .on
	}
    @IBOutlet weak var hideActive: NSButton!
    @IBAction func hideActive(_ sender: Any) {
        Preferences.shared.hideActiveLog = hideActive.state == .on
        initPredicate()
    }

	@IBAction func clear(_ sender: Any) {
        try? DataManager.shared.clearAllLogs()
        reloadData()
	}

	@IBOutlet var logTableView: NSTableView!
    
    @IBOutlet var arrayController: NSArrayController!
    @objc dynamic var predicate: NSPredicate? = nil
    
    @objc dynamic var logs = [Aria2Log]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		recordLog.state = Preferences.shared.recordWebSocketLog ? .on : .off
        hideActive.state = Preferences.shared.hideActiveLog ? .on : .off
        
        arrayController.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        initPredicate()
        reloadData()
        Task {
            await DataManager.shared.addObserver(self, forTable: .aria2Log)
        }
    }
    
    func initPredicate() {
        predicate = hideActive.state == .on ? NSPredicate(format: "method != %@", "updateActiveTasks()") : nil
    }
    
    func reloadData() {
        logs = (try? DataManager.shared.getLogs()) ?? []
    }
	
    @IBAction func copyJSON(_ sender: Any) {
        guard let logs = arrayController.arrangedObjects as? [Aria2Log],
            let str = logs[safe: logTableView.clickedRow]?.receivedJSON else {
                return
        }        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([str as NSString])
    }
}

extension LogViewController: DatabaseChangeObserver {
    @MainActor
    func databaseDidChange(notification: DatabaseChangeNotification) async {
        switch notification.changeType {
        case .insert(let ids):
            guard let new = try? DataManager.shared.getLogs(ids) else {
                return
            }
            logs.append(contentsOf: new)
        case .delete(let ids):
            logs.removeAll {
                ids.contains($0.date)
            }
        case .reload:
            reloadData()
        case .update:
            break
        }
    }
}
