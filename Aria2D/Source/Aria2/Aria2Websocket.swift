//
//  Aria2Websocket.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/10.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SocketRocket

struct ConnectedServerInfo {
	var version = ""
	var name = ""
	var enabledFeatures = ""
}

class Aria2Websocket: NSObject {
	
    static let shared = Aria2Websocket()
	private override init() {
	}
	
    var socket: SRWebSocket? = nil
    
    var isConnected: Bool {
        get {
            return socket?.readyState == .OPEN
        }
    }
	
	let refresh = WaitTimer(timeOut: .milliseconds(50)) {
		Aria2.shared.initData()
	}

	var connectedServerInfo = ConnectedServerInfo()
	
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
        
        socket?.close()
        
        if let url = Preferences.shared.aria2Servers.serverURL() {
            guard url.host != nil else { return }
            
            socket = SRWebSocket(url: url)
            socket?.delegate = self
            socket?.open()
            startTimer()
        }

	}
	
	func showNotification(_ gid: String) {
		let notification = NSUserNotification()
		notification.title = "Completed"
		let obj = DataManager.shared.aria2Object(gid: gid)
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
                    self.socket?.close()
                    let url = self.socket?.url
                    self.socket = SRWebSocket(url: url!)
                    self.socket?.delegate = self
                    self.socket?.open()
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
    
    
    private class WaitingList: NSObject {
        static let shared = WaitingList()
        
        fileprivate override init() {
        }
        
        private var contents: [String: Data] = [:]
        private var semaphores: [String: DispatchSemaphore] = [:]
        private var lock = NSLock()
        
        func add(_ key: String, block: @escaping (_ value: Data, _ timeOut: Bool) -> Void) {
            let semaphore = DispatchSemaphore(value: 0)
            lock.lock()
            semaphores[key] = semaphore
            lock.unlock()
            DispatchQueue.global().async {
                switch semaphore.wait(timeout: .now() + .seconds(60)) {
                case .success:
                    block(self.contents[key] ?? Data(), false)
                case .timedOut:
                    block(Data(), true)
                }
                WaitingList.shared.remove(key)
            }
        }
        
        func update(_ key: String, value: Data) {
            lock.lock()
            contents[key] = value
            semaphores[key]?.signal()
            lock.unlock()
        }
        
        private func remove(_ key: String) {
            lock.lock()
            defer {
                lock.unlock()
            }
            if !contents.isEmpty {
                contents.removeValue(forKey: key)
            }
            if !semaphores.isEmpty {
                semaphores.removeValue(forKey: key)
            }
        }
    }
    
    func write(_ dic: [String: Any],
               withID id: String,
               method: String,
               completion: @escaping (_ result: webSocketResult) -> Void) {
        let time = Date().timeIntervalSince1970
        WaitingList.shared.add(id) { (data, timeOut) in
            // Save log
            if Preferences.shared.developerMode,
                Preferences.shared.recordWebSocketLog {
                let log = WebSocketLog()
                log.method = method
                log.sendJSON = "\(dic)"
                log.receivedJSON = String(data: data, encoding: .utf8) ?? ""
                log.success = !timeOut
                log.time = time
                ViewControllersManager.shared.addLog(log)
            }
            
            if !timeOut {
                completion(.success(data: data))
            } else {
                completion(.timeOut)
            }
        }
        do {
            try socket?.send(data: try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted))
        } catch {
            completion(.somethingError)
            return
        }
    }
    
    func received(_ value: Data, withID id: String) {
        WaitingList.shared.update(id, value: value)
    }


}




extension Aria2Websocket: SRWebSocketDelegate {
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        Aria2.shared.initData()
        connectedServerInfo.name = Preferences.shared.aria2Servers.getSelectedName()
        Aria2.shared.getVersion {
            self.connectedServerInfo.version = "Version: \($0)"
            self.connectedServerInfo.enabledFeatures = $1
            NotificationCenter.default.post(name: .updateConnectStatus, object: nil)
        }
        Aria2.shared.getGlobalOption()
        ViewControllersManager.shared.showHUD(.connected)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        connectedServerInfo.version = reason ?? ""
        connectedServerInfo.enabledFeatures = ""
        aria2GlobalOption = [:]
        DataManager.shared.deleteAllAria2Objects()
        NotificationCenter.default.post(name: .updateConnectStatus, object: nil)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {
        if let data = string.data(using: .utf8) {
            if let json = try? JSONDecoder().decode(JSONRPC.self, from: data),
                json.id.count == 36 {
                received(data, withID: json.id)
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
                if Preferences.shared.developerMode, Preferences.shared.recordWebSocketLog {
                    let log = WebSocketLog()
                    log.method = json.method.rawValue
                    log.receivedJSON = String(data: data, encoding: .utf8) ?? ""
                    log.success = true
                    log.time = Date().timeIntervalSince1970
                    ViewControllersManager.shared.addLog(log)
                }
            }
        }
    }
    
}

