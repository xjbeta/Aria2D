//
//  LeftSourceListView.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class LeftSourceListView: NSOutlineView {


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }

    override func becomeFirstResponder() -> Bool {
        return false
    }

    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
    
    var nodes = [LeftSourceListNodeChild]()
	let node = LeftSourceListNode(name: "Download", icon: nil)
	let downloading = LeftSourceListNodeChild(name: "Downloading", icon: nil)
	let removed = LeftSourceListNodeChild(name: "Removed", icon: nil)
	let completed = LeftSourceListNodeChild(name: "Completed", icon: nil)
	let baidu = LeftSourceListNodeChild(name: "Baidu", icon: nil)
	
    func setDefaultData() {
		if Baidu.shared.isLogin && Preferences.shared.developerMode {
			if nodes.count == 3 {
				node.children.append(baidu)
				nodes.append(baidu)
				insertItems(at: IndexSet(integer: 3), inParent: nil, withAnimation: .effectFade)
			} else {
				node.children = [downloading, completed, removed, baidu]
				nodes = [downloading, completed, removed, baidu]
				reloadData()
			}
		} else {
			if nodes.count == 4 {
				node.children.remove(at: 3)
				nodes.remove(at: 3)
				removeItems(at: IndexSet(integer: 3), inParent: nil, withAnimation: .effectFade)
			} else {
				node.children = [downloading, completed, removed]
				nodes = [downloading, completed, removed]
				reloadData()
			}
		}
		if selectedRow == -1 {
			selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
		}
    }
	
    func initNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(nextTag), name: .nextTag, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(previousTag), name: .previousTag, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(resetLeftOutlineView), name: .resetLeftOutlineView, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(resetLeftOutlineView), name: .developerModeChanged, object: nil)
    }
    
	@objc func resetLeftOutlineView() {
		DispatchQueue.main.async {
			self.setDefaultData()
		}
	}
		
    @objc func nextTag() {
        if selectedRow < numberOfRows {
            selectRowIndexes(IndexSet(integer: selectedRow + 1), byExtendingSelection: false)
        }
    }
    
    @objc func previousTag() {
        if selectedRow >= 1 {
            selectRowIndexes(IndexSet(integer: selectedRow - 1), byExtendingSelection: false)
        }
    }
    
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
    
}
