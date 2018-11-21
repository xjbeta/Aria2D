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
	
	@IBOutlet var progressIndicator: NSProgressIndicator!
	
	var sidebarItems: [SidebarItem] = [.downloading, .removed, .completed]
	
    var newTaskViewFile = ""
    
	override func viewDidLoad() {
		super.viewDidLoad()
		initIndicator()
		initNotification()
//        ViewControllersManager.shared.selectedRow = .downloading
		resetSidebarItems()
	}
	
	
	func initIndicator() {
		progressIndicator.isHidden = !ViewControllersManager.shared.waiting
		progressIndicator.startAnimation(self)
		ViewControllersManager.shared.updateIndicator = {
			DispatchQueue.main.async {
				self.progressIndicator.isHidden = !ViewControllersManager.shared.waiting
			}
		}
	}
	
	

	
	func initNotification() {
        NotificationCenter.default.addObserver(forName: .newTask, object: nil, queue: .main) {
            if let userInfo = $0.userInfo as? [String: String], let file = userInfo["file"] {
                self.newTaskViewFile = file
            }
            self.performSegue(withIdentifier: .showNewTaskViewController, sender: nil)
        }
		NotificationCenter.default.addObserver(self, selector: #selector(nextTag), name: .nextTag, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(previousTag), name: .previousTag, object: nil)
        
		NotificationCenter.default.addObserver(self, selector: #selector(resetSidebarItems), name: .developerModeChanged, object: nil)
	}
	
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? NewTaskViewController {
            if newTaskViewFile != "" {
                vc.fileURL = URL(fileURLWithPath: newTaskViewFile)
            }
            newTaskViewFile = ""
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
	

	
	deinit {
		NotificationCenter.default.removeObserver(self)
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
		if let row = sidebarItems.index(of: ViewControllersManager.shared.selectedRow),
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

