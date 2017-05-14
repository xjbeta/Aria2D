//
//  PreferencesTabViewController.swift
//  Aria2D
//
//  Created by xjbeta on 16/5/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class PreferencesTabViewController: NSTabViewController {

	
    lazy var originalSizes = [String: NSSize]()
	lazy var baiduItem = NSTabViewItem()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initItems()
		NotificationCenter.default.addObserver(self, selector: #selector(initItems), name: .developerModeChanged, object: nil)
	}
	
	func initItems() {
		if Preferences.shared.developerMode {
			if tabViewItems.count == 2 {
				self.addTabViewItem(baiduItem)
			}
		} else if tabViewItems.count == 3, let item = tabViewItems.last, item.label == "Baidu" {
			baiduItem = item
			self.removeTabViewItem(item)
		}
	}
	
	
	
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, willSelect: tabViewItem)
		if let item = tabViewItem {
			let originalSize = originalSizes[item.label]
			if originalSize == nil {
				originalSizes[item.label] = item.view?.frame.size
			}
		}
	}
	
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
		
        if let window = self.view.window,
			let item = tabViewItem,
			let size = self.originalSizes[item.label] {
            let contentFrame = window.frameRect(forContentRect: NSMakeRect(0.0, 0.0, size.width, size.height))
            var frame = window.frame
            frame.origin.y = frame.origin.y + (frame.size.height - contentFrame.size.height)
			frame.size = contentFrame.size
			NSAnimationContext.runAnimationGroup({
				$0.duration = 0.15
				window.animator().setFrame(frame, display: true, animate: true)
			})
        }
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}
