//
//  BaiduSettingView.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/13.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class BaiduSettingView: NSViewController {
	
	@IBOutlet var loginButton: LoginButton!
	@IBOutlet var userName: NSTextField!
	@IBOutlet var capacityInfo: NSTextField!
	@IBOutlet var stackView: NSStackView!
	@IBOutlet var loginView: NSStackView!
	
	@IBAction func login(_ sender: Any) {
		if let title = loginButtonTitles(raw: loginButton.title) {
			switch title {
			case .login:
				performSegue(withIdentifier: .showLoginView, sender: self)
			case .logout:
				Baidu.shared.logout {}
			case .setPCS:
				performSegue(withIdentifier: .showPCSView, sender: self)
			case .out:
				break
			}
		}
        loginButton.mouseLocation = .out
		return
	}
	

	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == .showLoginView {
			if let vc = segue.destinationController as? BaiduLoginViewController {
				vc.onViewControllerDismiss = {
					self.view.window?.makeFirstResponder(self.loginButton)
				}
			}
		} else if segue.identifier == .showPCSView {
			if let vc = segue.destinationController as? SetPCSViewController {
				vc.onViewControllerDismiss = {
					self.view.window?.makeFirstResponder(self.loginButton)
				}
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.window?.makeFirstResponder(self.loginButton)
		initUserInfo()
		NotificationCenter.default.addObserver(self, selector: #selector(initUserInfo), name: .updateUserInfo, object: nil)
	}
	
	
	@objc func initUserInfo() {
		if Baidu.shared.isLogin {
			Baidu.shared.getUserInfo { name, image, capacity in
				DispatchQueue.main.async {
					self.userName.stringValue = name
					self.loginButton.image = image
					self.capacityInfo.stringValue = capacity
					self.stackView.showViews(animated: true)
					self.loginButton.needsDisplay = true
				}
			}
		} else {
			DispatchQueue.main.async {
				self.userName.stringValue = ""
				self.loginButton.image = self.defaultUserImage()
				self.capacityInfo.stringValue = ""
				self.stackView.hideViews(animated: true)
				self.loginButton.isHighlighted = false
				self.loginButton.mouseLocation = .out
			}
		}
	}
	
	func defaultUserImage() -> NSImage? {
		let defaultUserImage = NSImage(named: NSImage.Name(rawValue: "DefaultUserImage"))
		defaultUserImage?.size = NSSize(width: 70, height: 70)
		return defaultUserImage
	}
	
}

extension NSView {
	
	func hideViews(animated: Bool) {
		isHidden = true
		if animated {
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.3
				context.allowsImplicitAnimation = true
				self.window?.layoutIfNeeded()
				
				}, completionHandler: nil)
		}
	}
	
	func showViews(animated: Bool) {
		isHidden = false
		if animated {
			wantsLayer = true
			layer?.opacity = 0.0
		}
		
		if animated {
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.3
				context.allowsImplicitAnimation = true
				self.window?.layoutIfNeeded()
				
				}, completionHandler: {
					self.layer?.opacity = 1.0
			})
		}
	}
}
