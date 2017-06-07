//
//  RightTabView.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/15.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class RightTabView: NSTabViewController {

    @IBOutlet var loadingTab: NSTabViewItem!
    @IBOutlet var downloadTab: NSTabViewItem!
    override func viewDidLoad() {
        super.viewDidLoad()
		let title = self.title ?? ""
		title.sort()
        ViewControllersManager.shared.selectedRowDidSet = {
            self.setSelectedTab()
        }
		if let view = loadingTab.view as? LoadingView {
			view.initVersionInfo()
		}
    }
    
    
    func setSelectedTab() {
        switch ViewControllersManager.shared.selectedRow {
		case .downloading, .completed, .removed:
			updateTab()
			setNotificationToken()
		case .baidu:
			tabView.selectTabViewItem(downloadTab)
			notificationToken?.stop()
			notificationToken = nil
        default:
            tabView.selectTabViewItem(loadingTab)
			notificationToken?.stop()
			notificationToken = nil
        }
		
    }
	
	var notificationToken: NotificationToken? = nil
	var oldCountValue = -1
	
	func setNotificationToken() {
		let obj = DataManager.shared.data(TaskObject.self)
		notificationToken = obj.addNotificationBlock { _ in
			if data.count > 0 && self.oldCountValue == 0 {
				self.updateTab()
			} else if data.count == 0 && self.oldCountValue > 0 {
				self.updateTab()
			}
			self.oldCountValue = data.count
		}
	}
	
	func updateTab() {
		if DataManager.shared.data(TaskObject.self).count == 0 {
			tabView.selectTabViewItem(loadingTab)
		} else {
			tabView.selectTabViewItem(downloadTab)
		}
	}
	
	
	deinit {
		notificationToken?.stop()
	}
	
}
