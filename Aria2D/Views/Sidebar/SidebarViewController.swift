//
//  LeftSourceList.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {
	
    @IBOutlet var sidebarTableView: SidebarTableView!
	
    @IBOutlet weak var arrayController: NSArrayController!
    @IBOutlet weak var downloadSpeed: NSTextField!
    @IBOutlet weak var uploadSpeed: NSTextField!
    @IBOutlet weak var globalSpeedView: NSStackView!
    var observe: NSKeyValueObservation?
    @objc var predicate = NSPredicate(format: "status IN %@", [Status.active.rawValue])
    @objc var context: NSManagedObjectContext
    
    var sidebarItems: [SidebarItem] = [.downloading, .removed, .completed]
	
    var newTaskPreparedInfo = [String: String]()
    
    required init?(coder: NSCoder) {
        context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        if #available(OSX 11.0, *) {
            sidebarTableView.style = .fullWidth
        }
		initNotification()
		resetSidebarItems()
        
        observe = arrayController.observe(\.arrangedObjects) { [weak self] (arrayController, _) in
            guard let objs = arrayController.arrangedObjects as? [Aria2Object],
                Aria2Websocket.shared.isConnected else {
                    self?.globalSpeedView.isHidden = true
                    return
            }
            
            self?.globalSpeedView.isHidden = objs.count == 0
        }
	}
	
	func initNotification() {
        NotificationCenter.default.addObserver(forName: .newTask, object: nil, queue: .main) {
            if let userInfo = $0.userInfo as? [String: String] {
                self.newTaskPreparedInfo = userInfo
            }
            self.performSegue(withIdentifier: .showNewTaskViewController, sender: nil)
        }
		NotificationCenter.default.addObserver(self, selector: #selector(nextTag), name: .nextTag, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(previousTag), name: .previousTag, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(resetSidebarItems), name: .developerModeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGlobalStat), name: .updateGlobalStat, object: nil)
	}
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? NewTaskViewController {
            if newTaskPreparedInfo.count == 1 {
                vc.preparedInfo = newTaskPreparedInfo
            }
            newTaskPreparedInfo.removeAll()
        }
    }
	
	func setDefaultData() {
        
        if sidebarItems.count == 4 {
            sidebarItems.remove(at: 3)
            sidebarTableView.removeRows(at: IndexSet(integer: 3), withAnimation: .effectFade)
        } else if sidebarItems.count != 3 {
            sidebarItems = [.downloading, .removed, .completed]
            sidebarTableView.reloadData()
        }
        
        if sidebarTableView.selectedRow == -1 {
            sidebarTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        } else if sidebarTableView.selectedRow < sidebarTableView.numberOfRows {
            if let view = sidebarTableView.view(atColumn: sidebarTableView.selectedColumn, row: sidebarTableView.selectedRow, makeIfNecessary: false) as? SidebarTableCellView {
                view.isSelected = true
            }
        }
	}

	
	@objc func resetSidebarItems() {
		DispatchQueue.main.async {
			self.setDefaultData()
		}
	}
	
	@objc func nextTag() {
		if sidebarTableView.selectedRow < sidebarTableView.numberOfRows {
			sidebarTableView.selectRowIndexes(IndexSet(integer: sidebarTableView.selectedRow + 1), byExtendingSelection: false)
		}
	}
	
	@objc func previousTag() {
		if sidebarTableView.selectedRow >= 1 {
			sidebarTableView.selectRowIndexes(IndexSet(integer: sidebarTableView.selectedRow - 1), byExtendingSelection: false)
		}
	}
	
	
	@objc func showNewTask() {
        performSegue(withIdentifier: .showNewTaskViewController, sender: self)
	}
	
    @objc func updateGlobalStat(notification: NSNotification) {
        let dockTile = NSDockTile()
        let preferences = Preferences.shared
        globalSpeedView.isHidden = !preferences.showGlobalSpeed
        if !preferences.showDockIconSpeed {
            dockTile.badgeLabel = ""
            dockTile.badgeLabel = nil
        }
        
        guard preferences.showGlobalSpeed || preferences.showDockIconSpeed else {
            return
        }
        guard let userInfo = notification.userInfo else { return }
        
        if let updateServer = userInfo["updateServer"] as? Bool, updateServer {
            let isConnected = Aria2Websocket.shared.isConnected
            globalSpeedView.isHidden = !isConnected
            dockTile.badgeLabel = nil
            if isConnected,
                let activeCount = try? DataManager.shared.activeCount(),
                activeCount == 0 {
				
				dockTile.badgeLabel = ""
				dockTile.badgeLabel = nil
                globalSpeedView.isHidden = true
            }
        }
        
        guard let globalStat = userInfo["globalStat"] as? Aria2GlobalStat else { return }
        
        if preferences.showGlobalSpeed {
            if globalStat.numActive > 0 {
                downloadSpeed.stringValue = "⬇︎ \(globalStat.downloadSpeed.ByteFileFormatter())/s"
            } else {
                globalSpeedView.isHidden = true
            }
            
            if let activeBittorrentCount = (arrayController.arrangedObjects as? [Any])?.count,
                activeBittorrentCount > 0 {
                uploadSpeed.stringValue = "⬆︎ \(globalStat.uploadSpeed.ByteFileFormatter())/s"
            } else {
                uploadSpeed.stringValue = ""
            }
        }
        
        if preferences.showDockIconSpeed {
            if globalStat.numActive > 0 {
                dockTile.badgeLabel = "\(globalStat.downloadSpeed.ByteFileFormatter())/s"
            } else {
                dockTile.badgeLabel = nil
            }
        }
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
        observe?.invalidate()
	}
}

extension SidebarViewController: NSTableViewDelegate, NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return sidebarItems.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		if let cell = sidebarTableView.makeView(withIdentifier: .sidebarTableCellView, owner: self) as? SidebarTableCellView,
			let item = sidebarItems[safe: row] {
			cell.item = item
			return cell
		}
		return nil
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		if let row = sidebarItems.firstIndex(of: ViewControllersManager.shared.selectedRow),
			let view = sidebarTableView.view(atColumn: sidebarTableView.selectedColumn, row: row, makeIfNecessary: false) as? SidebarTableCellView {
			view.isSelected = false
		}
		
		if sidebarTableView.selectedRow >= 0,
            sidebarTableView.selectedRow < sidebarTableView.numberOfRows,
            let view = sidebarTableView.view(atColumn: sidebarTableView.selectedColumn, row: sidebarTableView.selectedRow, makeIfNecessary: false) as? SidebarTableCellView {
			view.isSelected = true
		}
		if let item = sidebarItems[safe: sidebarTableView.selectedRow] {
			ViewControllersManager.shared.selectedRow = item
		}
		NotificationCenter.default.post(name: .sidebarSelectionChanged, object: nil)
	}
	
}

