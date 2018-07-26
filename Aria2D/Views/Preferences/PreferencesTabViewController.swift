//
//  PreferencesTabViewController.swift
//  Aria2D
//
//  Created by xjbeta on 16/5/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class PreferencesTabViewController: NSTabViewController {

	lazy var baiduItem = NSTabViewItem()
    var originalSizes = [String: CGSize]()
    
	override func viewDidLoad() {
		super.viewDidLoad()
		initItems()
//        self.tabView.selectTabViewItem(at: 0)
		NotificationCenter.default.addObserver(self, selector: #selector(initItems), name: .developerModeChanged, object: nil)
	}
	
	@objc func initItems() {
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
        autoResizeWindow(tabViewItem)
    }
    
    func autoResizeWindow(_ tabViewItem: NSTabViewItem?) {
        if let title = tabViewItem?.label {
            if !originalSizes.keys.contains(title) {
                originalSizes[title] = tabViewItem?.view?.frame.size
            }
            if let size = originalSizes[title], let window = view.window {
                window.autoResize(toFill: size)
            }
        }
    }
    
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}

extension NSWindow {
	func autoResize(toFill size: CGSize) {
		let contentFrame = frameRect(forContentRect: CGRect(origin: .zero, size: size))
		var frame = self.frame
		frame.origin.y = frame.origin.y + (frame.size.height - contentFrame.size.height)
		frame.size = contentFrame.size
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.15
            self.animator().setFrame(frame, display: false)
        })
	}
}
