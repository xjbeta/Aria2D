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

@MainActor
class HUD: NSObject {
    
	convenience init(_ view: NSView) {
		self.init()
		self.view = view
		
		hud = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: .hudViewController) as? HUDViewController
        guard let hud = hud else { return }

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
        
	}
	
    private lazy var removeHUD: Debouncer = Debouncer(duration: 1.2) {
        await MainActor.run {
            self.disappearAnimation()
        }
    }
    
	
	private var hud: HUDViewController?
	private var view: NSView?
	
	
	func showHUD(_ message: hudMessage) {
        guard let hud else { return }
        if hud.view.isHidden {
            hud.view.wantsLayer = true
            hud.textlLabel.stringValue = message.rawValue
            
            appearAnimation()
            Task {
                await removeHUD.debounce()
            }
        } else {
            hud.textlLabel.stringValue = message.rawValue
            Task {
                await removeHUD.debounce()
            }
        }
	}
	
	private func appearAnimation() {
        guard let view = hud?.view else { return }
        view.isHidden = false
        view.alphaValue = 0
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            view.animator().alphaValue = 0.8
        }) {
            
        }
	}
	
	private func disappearAnimation() {
        guard let view = hud?.view else { return }
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



