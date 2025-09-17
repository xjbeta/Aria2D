//
//  MainListViewController.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/19.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainListViewController: NSViewController {
	@IBOutlet var mainListTableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    @objc dynamic var predicate: NSPredicate? = nil
    
    
	@IBAction func cellDoubleAction(_ sender: Any) {
		switch ViewControllersManager.shared.selectedRow {
		case .completed:
			ViewControllersManager.shared.openSelected()
		default:
			break
		}
	}
	
	@IBOutlet var downloadsTableViewMenu: DownloadsMenu!
    
    @objc dynamic var objects = [Aria2Object]()
    
	override func viewDidLoad() {
		super.viewDidLoad()
        ViewControllersManager.shared.selectedRow = .downloading
        initNotification()
        
        arrayController.sortDescriptors = [NSSortDescriptor(key: "status", ascending: true),
                                           NSSortDescriptor(key: "sortDate", ascending: false)]
        
        reloadData()
        Task {
            await DataManager.shared.addObserver(self, forTable: .aria2Object)
        }
    }
    
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .showInfoWindow {
            guard let wc = segue.destinationController as? NSWindowController,
                  let vc = wc.contentViewController as? InfoViewController,
                  let index = mainListTableView.selectedIndexs().first,
                  let objs = arrayController.arrangedObjects as? [Aria2Object],
                  let obj = objs[safe: index] else {
                return
            }
            vc.gid = obj.gid
		}
	}
	
    func initNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(showInfo), name: .showInfoWindow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sidebarSelectionChanged), name: .sidebarSelectionChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadData), name: .refreshMainList, object: nil)
    }
    
    @objc func sidebarSelectionChanged() {
        var statuses: [Status] = []
        switch ViewControllersManager.shared.selectedRow {
        case .downloading:
            statuses = [.active, .paused, .waiting]
        case .removed:
            statuses = [.error, .removed]
        case .completed:
            statuses = [.complete]
        case .none:
            break
        }
        
        predicate = NSPredicate(format: "status IN %@", statuses.map({ $0.rawValue }))
    }
    
    @objc func showInfo() {
        performSegue(withIdentifier: .showInfoWindow, sender: self)
    }
    
    
    @objc func shouldReloadData() {
        mainListTableView.reloadData()
    }
    
    func reloadData() {
        objects = (try? DataManager.shared.getAria2Objects()) ?? []
    }
    
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - TableView
extension MainListViewController: NSTableViewDelegate {

    func tableViewSelectionDidChange(_ notification: Notification) {
        setSelectedIndexsForMainList()
    }

    func selectedObjects() -> [Aria2Object] {
        let selectedIndexs = mainListTableView.selectedIndexs()
        guard let objs = arrayController.arrangedObjects as? [Aria2Object] else { return [] }
        return objs.enumerated().filter {
            selectedIndexs.contains($0.offset)
            }.map {
                $0.element
        }
    }
    
    func setSelectedIndexsForMainList() {
        ViewControllersManager.shared.selectedObjects = selectedObjects()
    }

}

// MARK: - MenuDelegate
extension MainListViewController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        setSelectedIndexsForMainList()
    }
}

extension MainListViewController: DatabaseChangeObserver {
    @MainActor
    func databaseDidChange(notification: DatabaseChangeNotification) async {
        switch notification.changeType {
        case .insert(let ids):
            guard let objs = try? DataManager.shared.getAria2Objects(ids) else {
                return
            }
            objects.append(contentsOf: objs)
        case .delete(let ids):
            objects.removeAll {
                ids.contains($0.gid)
            }
        case .reload:
            reloadData()
        case .update(let ids):
            guard let objs = try? DataManager.shared.getAria2Objects(ids) else { return }
            objs.forEach { obj in
                guard let index = objects.firstIndex(where: { $0.gid == obj.gid }) else { return }
                objects[safe: index]?.update(obj)   
            }
        }
    }
}
