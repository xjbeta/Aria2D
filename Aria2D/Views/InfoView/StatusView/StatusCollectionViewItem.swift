//
//  StatusCollectionViewItem.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/9.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class StatusCollectionViewItem: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func setItem(_ value: String) {
		if let view = view as? StatusCollectionViewItemView {
			view.value = value
			view.layer?.borderWidth = 0.5
			view.layer?.borderColor = NSColor.gray.cgColor
			view.layer?.cornerRadius = 2
		}
	}
}
