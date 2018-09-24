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
	@IBOutlet var mainListTableView: MainListTableView!
    @IBOutlet weak var mainListScrollView: NSScrollView!
    
	@IBAction func cellDoubleAction(_ sender: Any) {
		switch ViewControllersManager.shared.selectedRow {
		case .completed:
			ViewControllersManager.shared.openSelected()
		case .baidu:
			if mainListTableView.selectedRowIndexes.count == 1,
                let row = mainListTableView.selectedRowIndexes.first {
                let data = DataManager.shared.data(PCSFile.self)[row]
				if data.isdir {
					Baidu.shared.selectedPath = data.path
				} else if data.isBackButton {
					Baidu.shared.selectedPath = data.backParentDir
				}
                initPathControl()
			}
		default:
			break
		}
	}
	
	@IBOutlet var downloadsTableViewMenu: DownloadsMenu!
	@IBOutlet var baiduFileListMenu: BaiduFileListMenu!

    @IBOutlet weak var baiduPathControl: NSPathControl!
    @IBAction func baiduPathControl(_ sender: Any) {
        if let clickedUrl = baiduPathControl.clickedPathItem?.url,
            var path = clickedUrl.path.removingPercentEncoding {
            if path.starts(with: "/Baidu") {
                path = String(clickedUrl.path.dropFirst(6))
            }
            
            if path == "" {
                path = Baidu.shared.mainPath
            }
            Baidu.shared.selectedPath = path
            initPathControl()
        }
    }
    var dlinksProgress: BaiduDlinksProgress!
    var notificationToken: NotificationToken? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
        initPathControl()
        ViewControllersManager.shared.selectedRow = .downloading
        initNotification()
    }
    
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == .showBaiduDlinksProgress {
			if let vc = segue.destinationController as? BaiduDlinksProgress {
				vc.dataSource = self
			}
        } else if segue.identifier == .showInfoWindow {
            if let wc = segue.destinationController as? NSWindowController,
                let vc = wc.contentViewController as? InfoViewController,
                let obj = self.selectedObjects(Aria2Object.self).first {
                vc.gid = obj.gid
            }
		}
	}
	
    func initNotification() {
        setRealmNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(getDlinks), name: .getDlinks, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteBaiduFile), name: .deleteFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showInfo), name: .showInfoWindow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sidebarSelectionChanged), name: .sidebarSelectionChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadData), name: .refreshMainList, object: nil)
    }
    
    
    @objc func getDlinks() {
        performSegue(withIdentifier: .showBaiduDlinksProgress, sender: self)
    }
    
    @objc func showInfo(_ notification: Notification) {
        performSegue(withIdentifier: .showInfoWindow, sender: self)
    }
    
    @objc func deleteBaiduFile() {
        let paths = selectedObjects(PCSFile.self).filter({ !$0.isBackButton }).map({ $0.path })
        
        Baidu.shared.delete(paths).done {
            let successPaths = $0.filter {
                $0.errno == 0
            }
            if successPaths.count == paths.count {
                DataManager.shared.deletePCSFile(successPaths.map{ $0.path })
            } else {
                Baidu.shared.getFileList(forPath: Baidu.shared.selectedPath).done {}
                    .catch {
                        Log("Get baidu file list error when delete file failed \($0)")
                }
            }
            }.catch { error in
                Baidu.shared.getFileList(forPath: Baidu.shared.selectedPath).done {}
                    .catch {
                        Log("Get baidu file list error when delete file failed \($0)")
                }
                Log("Delete files error \(error)")
        }
    }
    
    func selectedObjects<T: Object>(_ type: T.Type) -> [T] {
        return DataManager.shared.data(type).enumerated().filter {
            ViewControllersManager.shared.selectedIndexs.contains($0.offset)
            }.map {
                $0.element
        }
    }
    
    func initPathControl() {
        guard ViewControllersManager.shared.selectedRow == .baidu else {
            baiduPathControl.isHidden = true
            return
        }
        baiduPathControl.isHidden = false
        let str = "/Baidu" + Baidu.shared.selectedPath
        
        baiduPathControl.url = URL.init(string: str.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        
        baiduPathControl.pathItems.enumerated().forEach {
            if $0.offset == 0, $0.element.title == "Baidu" {
                $0.element.image = NSImage(named: "baidu")
            } else {
                $0.element.image = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
            }
        }
    }
    
    func setRealmNotification() {
        notificationToken?.invalidate()
        switch ViewControllersManager.shared.selectedRow {
        case .downloading, .completed, .removed:
            let data = DataManager.shared.data(Aria2Object.self)
            notificationToken = data.bind(to: mainListTableView, animated: true)
        case .baidu:
            let data = DataManager.shared.data(PCSFile.self)
            notificationToken = data.bind(to: mainListTableView, animated: true)
        default:
            break
        }
    }
    
    @objc func sidebarSelectionChanged() {
        DispatchQueue.main.async {
            self.initPathControl()
            switch ViewControllersManager.shared.selectedRow {
            case .baidu:
                self.mainListScrollView.contentInsets.bottom = 20
                self.mainListTableView.rowHeight = 40
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
		case .baidu:
			mainListTableView.menu = baiduFileListMenu
			return DataManager.shared.data(PCSFile.self).count
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
		case .baidu:
			if let cell = tableView.makeView(withIdentifier: .baiduFileTableCellView, owner: self) as? BaiduFileTableCellView {
				if let data = DataManager.shared.data(PCSFile.self)[safe: row] {
					cell.setData(data)
				}
				return cell
			}
		default:
			break
		}
		return nil
	}
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		return mainListTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainListTableRowView"), owner: self) as? MainListTableRowView
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		mainListTableView.setSelectedIndexs()
	}
	
}

// MARK: - MenuDelegate
extension MainListViewController: NSMenuDelegate {
	func menuWillOpen(_ menu: NSMenu) {
		mainListTableView.setSelectedIndexs()
		if menu == baiduFileListMenu {
			baiduFileListMenu.initItemState()
		}
	}
}

extension MainListViewController: BaiduDlinksDataSource {
	func selectedObjects() -> [Int] {
		return selectedObjects(PCSFile.self).filter {
			!$0.isBackButton && !$0.isdir
            }.map {
                $0.fsID
        }
	}
}
