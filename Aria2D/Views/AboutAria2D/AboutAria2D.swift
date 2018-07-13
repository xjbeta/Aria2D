//
//  AboutAria2D.swift
//  Aria2D
//
//  Created by xjbeta on 2016/10/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class AboutAria2D: NSViewController {
    
	@objc var appName: String {
		return Bundle.main.infoDictionary?["CFBundleExecutable"] as? String ?? ""
	}
	
	@objc var appVersion: String {
		let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
		let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
		return "Version \(version) (\(build))"
	}
	
	@objc var appCopyright: String {
		return Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? ""
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
}
