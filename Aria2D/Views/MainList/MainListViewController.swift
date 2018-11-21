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
    @objc var context: NSManagedObjectContext
    
    
	@IBAction func cellDoubleAction(_ sender: Any) {
		switch ViewControllersManager.shared.selectedRow {
		case .completed:
			ViewControllersManager.shared.openSelected()
		default:
			break
		}
	}
	
	@IBOutlet var downloadsTableViewMenu: DownloadsMenu!
    
    required init?(coder: NSCoder) {
        context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        ViewControllersManager.shared.selectedRow = .downloading
        initNotification()
        
        arrayController.sortDescriptors = [NSSortDescriptor(key: "status", ascending: true),
                                           NSSortDescriptor(key: "sortValue", ascending: false)]
    }
    
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .showInfoWindow {
            if let wc = segue.destinationController as? NSWindowController,
                let vc = wc.contentViewController as? InfoViewController,
                let obj = arrayController.selectedObjects.first as? Aria2Object {
                vc.gid = obj.gid
            }
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
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: .showInfoWindow, sender: self)
        }
    }
    
    
    @objc func shouldReloadData() {
        DispatchQueue.main.async {
            self.mainListTableView.reloadData()
        }
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
