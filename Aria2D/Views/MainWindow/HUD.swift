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


class HUD: NSObject {
	
	convenience init(_ view: NSView) {
		self.init()
		self.view = view
		
		hud = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: .hudViewController) as? HUDViewController
		if let hud = hud {
			hud.view.isHidden = true
			view.addSubview(hud.view)
			view.addConstraints([NSLayoutConstraint(item: hud.view,
			                                        attribute: .bottom,
			                                        relatedBy: .equal,
			                                        toItem: view,
			                                        attribute: .bottom,
			                                        multiplier: 1,
			                                        constant: -18),
			                     NSLayoutConstraint(item: hud.view,
			                                        attribute: .centerX,
			                                        relatedBy: .equal,
			                                        toItem: view,
			                                        attribute: .centerX,
			                                        multiplier: 1,
			                                        constant: 0)])
			
			removeHUD = WaitTimer(timeOut: .milliseconds(1200)) { [weak self] in
                DispatchQueue.main.async {
                    self?.disappearAnimation(hud.view)
                }
			}
		}
		
	}
	
	
	
	private var removeHUD = WaitTimer(timeOut: .seconds(0)) {
	}
	
	private var hud: HUDViewController?
	private var view: NSView?
	
	
	func showHUD(_ message: hudMessage) {
		
		if let hud = hud {
			if hud.view.isHidden {
				hud.view.wantsLayer = true
				hud.textlLabel.stringValue = message.rawValue
				
				appearAnimation(hud.view)
				removeHUD.run()
			} else {
				hud.textlLabel.stringValue = message.rawValue
				removeHUD.run()
			}
		}
	}
	

	
	
	private func appearAnimation(_ view: NSView) {
		DispatchQueue.main.async {
			view.isHidden = false
			view.alphaValue = 0
			NSAnimationContext.runAnimationGroup({
				$0.duration = 0.3
				view.animator().alphaValue = 0.8
			}) { }
		}
	}
	
	private func disappearAnimation(_ view: NSView) {
		DispatchQueue.main.async {
			view.isHidden = false
			view.alphaValue = 0.8
			NSAnimationContext.runAnimationGroup({
				$0.duration = 0.3
				view.animator().alphaValue = 0
			}) {
				view.isHidden = true
			}
		}
	}
}


class HUDViewController: NSViewController {
	
	@IBOutlet var textlLabel: NSTextField!
	
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



