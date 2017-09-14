//
//  Aria2Websocket.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/10.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
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
			NotificationCenter.default.post(name: .updateVersionInfo, object: nil)
		}
	}
	
	var isConnected = false {
		didSet {
			if isConnected != oldValue {
				NotificationCenter.default.post(name: .updateConnectStatus, object: nil)
			}	
		}
	}
	
	var aria2GlobalOption = [Aria2Option: String]() {
		didSet {
			NotificationCenter.default.post(name: .updateGlobalOption, object: nil)
		}
	}
	

	
	func initSocket() {
		if let timer = timer {
			timer.cancel()
			self.timer = nil
		}
		if socket.isConnected {
			socket.disconnect()
		}
		
		let url = Preferences.shared.aria2Servers.serverURL()
		guard url?.host != nil else { return }
		socket = WebSocket(url: url!)
		socket.callbackQueue = DispatchQueue(label: "com.xjbeta.Aria2D.starscream")
		socket.delegate = self

		socket.connect()
		startTimer()
	}



	
	func showNotification(_ gid: String) {
		let notification = NSUserNotification()
		notification.title = "Completed"
        let obj = DataManager.shared.data(Aria2Object.self).filter({ $0.gid == gid }).first
		notification.subtitle = obj?.path()?.lastPathComponent ?? "Unknown"
		
		if let totalLength = obj?.totalLength {
			let formatter = ByteCountFormatter()
			notification.informativeText = formatter.string(fromByteCount: totalLength)
		}
		
		notification.soundName = NSUserNotificationDefaultSoundName
		NSUserNotificationCenter.default.deliver(notification)

	}
	
	
	var isSuspend = Bool()
	private var timer: DispatchSourceTimer?
	
	private var timerQueue = DispatchQueue(label: "com.xjbeta.Aria2D.connectWebSocketQueue")
	
	private func startTimer() {
		timer = DispatchSource.makeTimerSource(flags: [], queue: timerQueue)
		if let timer = timer {
			timer.schedule(deadline: .now(), repeating: .seconds(1))
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
		if !isSuspend, timer != nil {
			timer?.suspend()
			isSuspend = true
		}
	}
	
	func resumeTimer() {
		if isSuspend, timer != nil {
			timer?.resume()
			isSuspend = false
			Aria2.shared.initData()
		}
	}

}
extension Aria2Websocket: WebSocketDelegate {
	func websocketDidConnect(socket: WebSocket) {
		isConnected = true
		Aria2.shared.initData()
		Aria2.shared.getVersion { (v, str) in
			self.connectedServerInfo.version = "Version: \(v)"
			self.connectedServerInfo.enabledFeatures = str
		}
		
		
		Aria2.shared.getGlobalOption()
		self.connectedServerInfo.name = Preferences.shared.aria2Servers.getSelectedName()
		ViewControllersManager.shared.showHUD(.connected)
	}
	
	func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
		isConnected = false
		connectedServerInfo.version = error?.localizedFailureReason ?? ""
		connectedServerInfo.enabledFeatures = ""
		aria2GlobalOption = [:]
		DataManager.shared.deleteAllAria2Objects()
	}
	
	func websocketDidReceiveMessage(socket: WebSocket, text: String) {
		if let data = text.data(using: .utf8) {
			if let json = try? JSONDecoder().decode(JSONRPC.self, from: data),
				json.id.count == 36 {
				socket.received(data, withID: json.id)
			} else if let json = try? JSONDecoder().decode(JSONNotice.self, from: data) {
				let gids = json.params.map { $0.gid }
				switch json.method {
				case .onDownloadStart:
					Aria2.shared.updateStatus(gids)
					ViewControllersManager.shared.showHUD(.downloadStart)
				case .onDownloadPause:
					Aria2.shared.updateStatus(gids)
				case .onDownloadError:
					Aria2.shared.updateStatus(gids)
				case .onDownloadComplete, .onBtDownloadComplete:
					Aria2.shared.updateStatus(gids)
					if !NSApp.isActive && Preferences.shared.completeNotice {
						gids.forEach {
							showNotification($0)
						}
					}
					ViewControllersManager.shared.showHUD(.downloadCompleted)
				case .onDownloadStop:
					Aria2.shared.updateStatus(gids)
				}
				if Preferences.shared.developerMode ,Preferences.shared.recordWebSocketLog {
					var log = WebSocketLog()
					log.method = json.method.rawValue
					log.receivedJSON = String(data: data, encoding: .utf8) ?? ""
					log.success = true
					log.time = Date().timeIntervalSince1970
					ViewControllersManager.shared.webSocketLog.append(log)
				}
			}
		}
	}
	
	func websocketDidReceiveData(socket: WebSocket, data: Data) {
		
	}
	
}
