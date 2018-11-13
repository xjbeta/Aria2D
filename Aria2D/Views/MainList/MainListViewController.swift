//
//  MainListViewController.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/19.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class MainListViewController: NSViewController {
	@IBOutlet var mainListTableView: NSTableView!
    @IBOutlet weak var mainListScrollView: NSScrollView!
    
	@IBAction func cellDoubleAction(_ sender: Any) {
		switch ViewControllersManager.shared.selectedRow {
		case .completed:
			ViewControllersManager.shared.openSelected()
		default:
			break
		}
	}
	
	@IBOutlet var downloadsTableViewMenu: DownloadsMenu!

    var notificationToken: NotificationToken? = nil
    
    var enablePcsDownload = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
        ViewControllersManager.shared.selectedRow = .downloading
        initNotification()
    }
    
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .showInfoWindow {
            if let wc = segue.destinationController as? NSWindowController,
                let vc = wc.contentViewController as? InfoViewController,
                let obj = self.selectedObjects(Aria2Object.self).first {
                vc.gid = obj.gid
            }
		}
	}
	
    func initNotification() {
        setRealmNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(showInfo), name: .showInfoWindow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sidebarSelectionChanged), name: .sidebarSelectionChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadData), name: .refreshMainList, object: nil)
    }
    
    @objc func showInfo(_ notification: Notification) {
        performSegue(withIdentifier: .showInfoWindow, sender: self)
    }
    
    
    func selectedObjects<T: Object>(_ type: T.Type) -> [T] {
        return DataManager.shared.data(type).enumerated().filter {
            ViewControllersManager.shared.selectedIndexs.contains($0.offset)
            }.map {
                $0.element
        }
    }
    
    
    func setRealmNotification() {
        notificationToken?.invalidate()
        switch ViewControllersManager.shared.selectedRow {
        case .downloading, .completed, .removed:
            let data = DataManager.shared.data(Aria2Object.self)
            notificationToken = data.bind(to: mainListTableView, animated: true)
        default:
            break
        }
    }
    
    @objc func sidebarSelectionChanged() {
        DispatchQueue.main.async {
            switch ViewControllersManager.shared.selectedRow {
            default:
                self.mainListScrollView.contentInsets.bottom = 0
                self.mainListTableView.rowHeight = 50
            }
            self.setRealmNotification()
        }
    }
    
    @objc func shouldReloadData() {
        DispatchQueue.main.async {
            self.mainListTableView.reloadData()
        }
    }

	deinit {
		NotificationCenter.default.removeObserver(self)
        notificationToken?.invalidate()
	}
}



// MARK: - TableView
extension MainListViewController: NSTableViewDelegate, NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		switch ViewControllersManager.shared.selectedRow {
		case .downloading, .completed, .removed:
			mainListTableView.menu = downloadsTableViewMenu
			return DataManager.shared.data(Aria2Object.self).count
		default:
			return 0
		}
	}
	
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		switch ViewControllersManager.shared.selectedRow {
		case .downloading, .completed, .removed:
			if let cell = tableView.makeView(withIdentifier: .downloadsTableCellView, owner: self) as? DownloadsTableCellView {
				if let data = DataManager.shared.data(Aria2Object.self)[safe: row] {
					cell.setData(data)
				}
				return cell
			}
		default:
			break
		}
		return nil
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		setSelectedIndexsForMainList()
	}
    
    func setSelectedIndexsForMainList() {
        
        let selectedIndexs: IndexSet = {
            if mainListTableView.clickedRow != -1 {
                if mainListTableView.selectedRowIndexes.contains(mainListTableView.clickedRow) {
                    return mainListTableView.selectedRowIndexes
                } else {
                    return IndexSet(integer: mainListTableView.clickedRow)
                }
            } else {
                return mainListTableView.selectedRowIndexes
            }
        }()
        
        ViewControllersManager.shared.selectedIndexs = selectedIndexs
    }
	
}

// MARK: - MenuDelegate
extension MainListViewController: NSMenuDelegate {
	func menuWillOpen(_ menu: NSMenu) {
		setSelectedIndexsForMainList()
	}
}
