//
//  DownloadsViewController.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/19.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class DownloadsViewController: NSViewController {
	@IBOutlet var downloadsTableView: DownloadsTableView!
    
	@IBAction func cellDoubleAction(_ sender: Any) {
		switch ViewControllersManager.shared.selectedRow {
		case .completed:
			ViewControllersManager.shared.openSelected()
		case .baidu:
			if downloadsTableView.selectedRowIndexes.count == 1,
                let row = downloadsTableView.selectedRowIndexes.first {
                let data = DataManager.shared.data(PCSFile.self)[row]
				if data.isdir {
					Baidu.shared.selectedPath = data.path
				} else if data.isBackButton {
					Baidu.shared.selectedPath = data.backParentDir
				}
			}
		default:
			break
		}
	}
	
	@IBOutlet var downloadsTableViewMenu: DownloadsMenu!
	@IBOutlet var baiduFileListMenu: BaiduFileListMenu!

	var dlinksProgress: BaiduDlinksProgress!
	
	override func viewDidLoad() {
		super.viewDidLoad()
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
	

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}



// MARK: - TableView
extension DownloadsViewController: NSTableViewDelegate, NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		switch ViewControllersManager.shared.selectedRow {
		case .downloading, .completed, .removed:
			downloadsTableView.menu = downloadsTableViewMenu
			return DataManager.shared.data(Aria2Object.self).count
		case .baidu:
			downloadsTableView.menu = baiduFileListMenu
			return DataManager.shared.data(PCSFile.self).count
		default:
			return 0
		}
	}
	
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		switch ViewControllersManager.shared.selectedRow {
		case .downloading, .completed, .removed:
			if let cell = tableView.makeView(withIdentifier: .downloadsTableCell, owner: self) as? DownloadsTableCellView {
				if let data = DataManager.shared.data(Aria2Object.self)[safe: row] {
					cell.setData(data)
				}
				return cell
			}
		case .baidu:
			if let cell = tableView.makeView(withIdentifier: .baiduFileListCell, owner: self) as? BaiduFileListCellView {
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
		return downloadsTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DownloadsTableRowView"), owner: self) as? DownloadsTableRowView
		
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		downloadsTableView.setSelectedIndexs()
	}
	
}

// MARK: - MenuDelegate
extension DownloadsViewController: NSMenuDelegate {
	func menuWillOpen(_ menu: NSMenu) {
		downloadsTableView.setSelectedIndexs()
		if menu == baiduFileListMenu {
			baiduFileListMenu.initItemState()
		}
	}
}




extension DownloadsViewController {
	
	
	func initNotification() {
		downloadsTableView.initNotification()
		downloadsTableView.setRealmNotification()
		NotificationCenter.default.addObserver(self, selector: #selector(getDlinks), name: .getDlinks, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteBaiduFile), name: .deleteFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showInfo), name: .showInfoWindow, object: nil)
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
	
	
}

extension DownloadsViewController: BaiduDlinksDataSource {
	func selectedObjects() -> [Int] {
		return selectedObjects(PCSFile.self).filter {
			!$0.isBackButton && !$0.isdir
            }.map {
                $0.fsID
        }
	}
}
