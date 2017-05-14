//
//  Aria2Websocket.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/10.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Starscream

struct ConnectedServerInfo {
	var version = ""
	var name = ""
	var enabledFeatures = ""
}


class Aria2Websocket: NSObject {
	
    static let shared = Aria2Websocket()
	private override init() {
	}
	
	var socket = WebSocket(url: URL(fileURLWithPath: "ws://localhost:8080"))
	

	let refresh = WaitTimer(timeOut: .milliseconds(50)) {
		Aria2.shared.initData()
	}
	
	

	var connectedServerInfo = ConnectedServerInfo() {
		didSet {
			NotificationCenter.default.post(name: .updateVersionInfo, object: self)
		}
	}
	
	var isConnected = false {
		didSet {
			if isConnected != oldValue {
				NotificationCenter.default.post(name: .updateConnectStatus, object: self)
			}
			
		}
	}
	
	var aria2GlobalOption = [Aria2Option: String]() {
		didSet {
			NotificationCenter.default.post(name: .updateGlobalOption, object: self)
		}
	}
	

	
	func initSocket() {
		if let timer = timer {
			timer.cancel()
			self.timer = nil
		}
		socket.disconnect()
		let url = Preferences.shared.aria2Servers.serverURL()
		guard url != nil else { return }
		socket = WebSocket(url: url!)
		socket.callbackQueue = DispatchQueue(label: "com.xjbeta.Aria2D.starscream")
		socket.onConnect = {
			self.isConnected = true
			Aria2.shared.initData()
			Aria2.shared.getVersion {
				self.connectedServerInfo.version = "Version: \($0.0)"
				self.connectedServerInfo.enabledFeatures = $0.1
			}
			Aria2.shared.getGlobalOption()
			self.connectedServerInfo.name = Preferences.shared.aria2Servers.getSelectedName()
			ViewControllersManager.shared.showHUD(.connected)
			
			if true {
				Aria2.shared.getPeer("4a569e7e0fcbf020") {
					Log($0)
				}
			}

		}
		socket.onDisconnect = {
			self.isConnected = false
			self.connectedServerInfo.version = $0?.localizedFailureReason ?? ""
			self.connectedServerInfo.enabledFeatures = ""
			self.aria2GlobalOption = [:]
			DataManager.shared.deleteAllTaskObject()
		}
		socket.onText = {
			self.handle($0)
		}
		socket.connect()
		startTimer()
	}

	
	func handle(_ text: String) {
		let json = JSON(parseJSON: text)
		if json["id"].exists(),
			json["id"].stringValue.characters.count == 36 {
			socket.received(json, withID: json["id"].stringValue)
		} else if let method = aria2Notice(raw: json["method"].stringValue) {
			switch method {
			case .onDownloadStart:
				Aria2.shared.initData([json["params"][0]["gid"].gidValue])
				ViewControllersManager.shared.showHUD(.downloadStart)
			case .onDownloadComplete, .onBtDownloadComplete:
				json["params"][0]["gid"].gidValue.onDownloadComplete()
				ViewControllersManager.shared.showHUD(.downloadCompleted)
//			case .onDownloadPause:
//				Aria2.shared.initData([json["params"][0]["gid"].gidValue])
//			case .onDownloadError:
//				Aria2.shared.initData([json["params"][0]["gid"].gidValue])
//			case .onDownloadStop:
//				Aria2.shared.initData([json["params"][0]["gid"].gidValue])
			default:
				Aria2.shared.initData([json["params"][0]["gid"].gidValue])
			}
			
			// Save log
			if Preferences.shared.recordWebSocketLog{
				var log = WebSocketLog()
				log.method = method.rawValue
				log.sendJSON = ""
				log.receivedJSON = "\(json)"
				log.success = true
				log.time = Date().timeIntervalSince1970
				ViewControllersManager.shared.webSocketLog.append(log)
			}
		}
	}

	
	var isSuspend = Bool()
	private var timer: DispatchSourceTimer?
	
	
	private func startTimer() {
		timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue(label: "com.xjbeta.Aria2D.connectWebSocketQueue"))
		if let timer = timer {
			timer.scheduleRepeating(deadline: DispatchTime.now(), interval: .seconds(1))
			timer.setEventHandler {
				if !self.isConnected {
					self.socket.connect()
				} else {
					if DataManager.shared.activeCount() > 0 {
						Aria2.shared.updateActiveTasks()
					}
				}
			}
			timer.resume()
		}
	}
	
	
	
	func suspendTimer() {
		if !isSuspend, let timer = timer {
			timer.suspend()
			isSuspend = true
			return
		}
	}
	
	func resumeTimer() {
		if isSuspend, let timer = timer {
			timer.resume()
			isSuspend = false
		}
	}

}
