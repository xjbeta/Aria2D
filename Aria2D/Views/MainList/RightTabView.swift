//
//  RightTabView.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/15.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class RightTabView: NSTabViewController {

    @IBOutlet var loadingTab: NSTabViewItem!
    @IBOutlet var downloadTab: NSTabViewItem!
    
    var observe: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		if let view = loadingTab.view as? LoadingView {
			view.initVersionInfo()
		}
        if let vc = downloadTab.viewController as? MainListViewController {
            observe = vc.arrayController.observe((\.arrangedObjects)) { (arrayController, _) in
                let count = (arrayController.arrangedObjects as? [Any] ?? []).count
                DispatchQueue.main.async { [weak self] in
                    self?.updateContentView(count)
                }
            }
        }
    }
    
    func updateContentView(_ count: Int) {
        if let item = count == 0 ? loadingTab : downloadTab {
            tabView.selectTabViewItem(item)
        }
    }
	
	deinit {
		observe?.invalidate()
	}
	
}
