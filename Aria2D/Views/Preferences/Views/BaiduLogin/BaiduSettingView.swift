//
//  BaiduSettingView.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/13.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class BaiduSettingView: NSViewController {
	
    enum tabViewItem: Int {
        case info, login, error, progress
    }
    
    @IBOutlet var userName: NSTextField!
    @IBOutlet var capacityInfo: NSTextField!
    @IBOutlet weak var capacityProgressIndicator: NSProgressIndicator!

    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBAction func tryAgain(_ sender: Any) {
        initUserInfo()
    }
    
    @IBAction func logout(_ sender: Any) {
        Baidu.shared.logout({
            self.initUserInfo()
        }) { _ in
            self.setTabView(.error)
        }
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		initUserInfo()
	}

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? BaiduViewController {
            vc.dismiss = {
                self.dismiss(vc)
                self.initUserInfo()
            }
        }
    }
    
	func initUserInfo() {
        setTabView(.progress)
        Baidu.shared.checkBaiduState {
            switch $0 {
            case .success:
                Baidu.shared.getUserInfo ({ name, capacity, capacityPer  in
                    DispatchQueue.main.async {
                        self.userName.stringValue = name
                        self.capacityInfo.stringValue = capacity
                        self.capacityProgressIndicator.doubleValue = capacityPer
                        self.setTabView(.info)
                    }
                }) { _ in
                    self.setTabView(.error)
                }
            case .error:
                self.setTabView(.error)
            default:
                self.setTabView(.login)
            }
        }
	}
	
    func setTabView(_ item: tabViewItem) {
        DispatchQueue.main.async {
            if item == .progress {
                self.progressIndicator.startAnimation(self)
            }
            self.tabView.selectTabViewItem(at: item.rawValue)
        }
    }
}
