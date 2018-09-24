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
        Baidu.shared.logout().done {
            self.initUserInfo()
            }.catch {
                Log("Logout baidu error \($0)")
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
        Baidu.shared.checkLogin().then { _ in
            Baidu.shared.getUserInfo()
            }.done(on: .main) { info in
                self.userName.stringValue = info.username
                self.capacityInfo.stringValue = "\(Int64(info.quota.used).ByteFileFormatter())/\(Int64(info.quota.total).ByteFileFormatter())"
                self.capacityProgressIndicator.doubleValue = info.quota.total == 0 ? 0 : Double(info.quota.used)/Double(info.quota.total)
                self.setTabView(.info)
            }.catch {
                switch $0 {
                case BaiduHTTPError.shouldLogin:
                    self.setTabView(.login)
                default:
                    Log("Init baidu user info error \($0)")
                    self.setTabView(.error)
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
