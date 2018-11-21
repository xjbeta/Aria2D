//
//  LogViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/18.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class LogViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var arrayController: NSArrayController!
    @objc dynamic var predicate: NSPredicate? = nil
    @objc var context: NSManagedObjectContext
    
    required init?(coder: NSCoder) {
        context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
    }
    
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
        DataManager.shared.deleteLogs()
	}

	@IBOutlet var logTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		recordLog.state = Preferences.shared.recordWebSocketLog ? .on : .off
        hideActive.state = Preferences.shared.hideActiveLog ? .on : .off
        initPredicate()
    }
    
    func initPredicate() {
        predicate = hideActive.state == .on ? NSPredicate(format: "method != %@", "updateActiveTasks()") : nil
    }
	
    @IBAction func copyJSON(_ sender: Any) {
        guard let logs = arrayController.arrangedObjects as? [WebSocketLog],
            let str = logs[safe: logTableView.clickedRow]?.receivedJSON else {
                return
        }        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([str as NSString])
    }
}
