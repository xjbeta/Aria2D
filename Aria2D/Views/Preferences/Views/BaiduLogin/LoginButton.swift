//
//  LoginButton.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/14.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
enum loginButtonTitles: String {
	case login = "Login"
	case setPCS = "SetPCS"
	case logout = "Logout"
	case out = ""
	init?(raw: String) {
		self.init(rawValue: raw)
	}
}


class LoginButton: NSButton {
	
	enum mouseLocations {
		case button, top, out
	}
	
    var shouldHighlight = true {
        didSet {
            if !shouldHighlight {
                mouseLocation = .out
                isHighlighted = false
            }
        }
    }
    
	var mouseLocation: mouseLocations = .out {
		didSet {
			if mouseLocation != oldValue {
				if Baidu.shared.isLogin {
					switch mouseLocation {
					case .button:
						title = loginButtonTitles.logout.rawValue
					case .top:
						title = loginButtonTitles.setPCS.rawValue
					case .out:
						title = loginButtonTitles.out.rawValue
					}
				} else {
					switch mouseLocation {
					case .button, .top:
						title = loginButtonTitles.login.rawValue
					case .out:
						title = loginButtonTitles.out.rawValue
					}
				}
			}
		}
	}
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		layer?.cornerRadius = 35
    }
	
	override func drawFocusRingMask() {
		let path = NSBezierPath(roundedRect: bounds, xRadius: 35, yRadius: 35)
		path.fill()
	}
	
	override func mouseEntered(with event: NSEvent) {
		super.mouseExited(with: event)
        guard shouldHighlight else { return }
		setTitle(with: event)
		isHighlighted = true
	}
	
    override func mouseExited(with event: NSEvent) {
		super.mouseExited(with: event)
        mouseLocation = .out
		isHighlighted = false
    }
	
	override func mouseMoved(with event: NSEvent) {
		super.mouseMoved(with: event)
        guard shouldHighlight else { return }
		setTitle(with: event)
		isHighlighted = true
	}

	func setTitle(with event: NSEvent) {
		let y = self.convert(event.locationInWindow, from: nil).y
		let height = self.frame.size.height
		mouseLocation = y > height/2 ? .button : .top
	}
	
    override func updateTrackingAreas() {
        trackingAreas.forEach {
            removeTrackingArea($0)
        }
        addTrackingArea(NSTrackingArea(rect: bounds,
                                       options: [.mouseEnteredAndExited, .activeInKeyWindow, .mouseMoved],
                                       owner: self,
                                       userInfo: nil))
        
    }
	
}
