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

            observe = vc.arrayController.observe((\.arrangedObjects)) { [weak self] (arrayController, _) in
                let count = (arrayController.arrangedObjects as! [Any]).count
                if let item = count == 0 ? self?.loadingTab : self?.downloadTab {
                    self?.tabView.selectTabViewItem(item)
                }
            }
        }
    }
	
	deinit {
		observe?.invalidate()
	}
	
}
