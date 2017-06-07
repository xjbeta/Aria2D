//
//  HUD.swift
//  Aria2D
//
//  Created by xjbeta on 2016/10/15.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

enum hudMessage: String {
	case connecting = "Connecting..."
	case connected = "Connected"
	case downloadStart = "Download Start"
	case downloadCompleted = "Download Completed"
	case error = "Something Error"
	case cannotPause = "Some task cannot be paused now"
	case cannotUnpause = "Some task cannot be unpaused now"
}



protocol HUDDelegate {
	func windowOfView() -> NSWindow?
}

class HUD: NSObject {
	
	var delegate: HUDDelegate?
	
	override init() {
		super.init()
		removeHUD = WaitTimer(timeOut: .milliseconds(1200)) {
			self.disappearAnimation(self.hud.backView)
		}
		hud = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "HUDViewController")) as! HUDViewController
	}
	
	
	private var hud = HUDViewController()
	private var removeHUD = WaitTimer(timeOut: .seconds(0)) {
	}
	
	
	func showHUD(_ message: hudMessage) {
		if let view = delegate?.windowOfView()?.contentView {
			if isDisplayed(in: view) {
				hud.textlLabel.stringValue = message.rawValue
				removeHUD.run()
			} else {
				hud.view.wantsLayer = true
				hud.backView.wantsLayer = true
				hud.textlLabel.stringValue = message.rawValue
				view.addSubview(hud.backView)
				view.addConstraints([NSLayoutConstraint(item: hud.backView,
				                                           attribute: .bottom,
				                                           relatedBy: .equal,
				                                           toItem: view,
				                                           attribute: .bottom,
				                                           multiplier: 1,
				                                           constant: -18),
				                        NSLayoutConstraint(item: hud.backView,
				                                           attribute: .centerX,
				                                           relatedBy: .equal,
				                                           toItem: view,
				                                           attribute: .centerX,
				                                           multiplier: 1,
				                                           constant: 0)])
				appearAnimation(hud.backView)
				removeHUD.run()
			}
			
			
			
		}

	}
	

	
	
	private func appearAnimation(_ view: NSView) {
		view.isHidden = false
		view.alphaValue = 0
		NSAnimationContext.runAnimationGroup({
			$0.duration = 0.3
			$0.allowsImplicitAnimation = true
			view.animator().alphaValue = 0.8
		}) {
			
		}
	}
	
	private func disappearAnimation(_ view: NSView) {
		view.alphaValue = 0.8
		NSAnimationContext.runAnimationGroup({
			$0.duration = 0.3
			$0.allowsImplicitAnimation = true
			view.animator().alphaValue = 0
		}) {
			view.isHidden = true
			view.alphaValue = 0.8
			view.removeFromSuperview()
		}
	}
	
	private func isDisplayed(in view: NSView?) -> Bool {
		return view?.subviews.filter {
			$0 is HUDBackView
			}.count ?? 0 > 0
	}
	
	
	
}


class HUDViewController: NSViewController {
	
	@IBOutlet var textlLabel: NSTextField!
	
	@IBOutlet var backView: HUDBackView!
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
}


class HUDBackView: NSView {
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		NSColor.black.setFill()
		dirtyRect.fill()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		wantsLayer = true
		layer?.cornerRadius = 4
	}
}



