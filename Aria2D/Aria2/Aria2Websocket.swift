//
//  Aria2Websocket.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/10.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import Starscream
import PromiseKit

struct ConnectedServerInfo {
	var version = ""
	var name = ""
	var enabledFeatures = ""
}

class Aria2Websocket: NSObject {
	
    static let shared = Aria2Websocket()
	private override init() {
	}
	
    var socket: WebSocket? = nil
    
    var isConnected = false
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
        
        socket?.disconnect()
        
        if let url = Preferences.shared.aria2Servers.serverURL() {
            guard url.host != nil else { return }
            
            socket = WebSocket(request: .init(url: url))
            socket?.delegate = self
            socket?.connect()
            startTimer()
        }

	}
	
	func showNotification(_ obj: Aria2Object) {
		let notification = NSUserNotification()
		notification.title = "Completed"
        notification.subtitle = obj.name
		notification.informativeText = obj.totalLength.ByteFileFormatter()
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
                    self.socket?.disconnect()
                    guard let url = self.socket?.request.url else { return }
                    self.socket = WebSocket.init(request: .init(url: url))
                    self.socket?.delegate = self
                    self.socket?.connect()
                } else {
                    DispatchQueue.main.async {
                        guard let count = try? DataManager.shared.activeCount(),
                            count > 0 else {
                                return
                        }
                        Aria2.shared.updateActiveTasks()
                        
                        if let infoVC = NSApp.keyWindow?.contentViewController as? InfoViewController {
                            infoVC.updateStatusInTimer()
                        }
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
			Aria2.shared.initData.run()
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
               method: String) -> Promise<Data> {
        return Promise { resolver in
            let time = Double(Date().timeIntervalSince1970)
            WaitingList.shared.add(id) { (data, timeOut) in
                // Save log
                if Preferences.shared.developerMode,
                    Preferences.shared.recordWebSocketLog {
                    DispatchQueue.global(qos: .background).async {
                        var receivedJSON = ""
                        if let str = String(data: data, encoding: .utf8),
                            let shrotData = Aria2Websocket.shared.clearUrls(str),
                            let shortStr = String(data: shrotData, encoding: .utf8) {
                            receivedJSON = shortStr
                        }

                        DispatchQueue.main.async {
                            let log = WebSocketLog(context: DataManager.shared.context)
                            log.method = method
                            log.sendJSON = "\(dic)"
                            log.receivedJSON = receivedJSON
                            
                            log.success = !timeOut
                            log.date = time
                            DataManager.shared.saveContext()
                        }
                    }
                }
                
                if !timeOut {
                    resolver.fulfill(data)
                } else {
                    resolver.reject(webSocketResult.timeOut)
                }
            }
            do {
                socket?.write(data: try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted), completion: nil)
            } catch let er {
                resolver.reject(webSocketResult.receiveError(message: "\(er)"))
                return
            }
        }
    }
    
    func received(_ value: Data, withID id: String) {
        WaitingList.shared.update(id, value: value)
    }
}

enum webSocketResult: Error {
    case timeOut
    case receiveError(message: String)
    case somethingError
}

extension Aria2Websocket: WebSocketDelegate {
	func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
		switch event {
		case .connected(let headers):
			isConnected = true
			Log("websocket is connected: \(headers)")
			webSocketDidOpen()
		case .disconnected(let reason, let code):
			isConnected = false
			Log("websocket is disconnected: \(reason) with code: \(code)")
			webSocket(didCloseWithCode: Int(code), reason: reason)
		case .text(let string):
			webSocket(didReceiveMessageWith: string)
		case .binary(let data):
			Log("Received data: \(data.count)")
		case .ping(_):
			Log("websocket ping")
		case .pong(_):
			Log("websocket pong")
		case .viabilityChanged(_):
			Log("websocket viablityChanged")
		case .reconnectSuggested(_):
			Log("websocket reconnectSuggested")
		case .cancelled:
			isConnected = false
			Log("websocket cancelled")
		case .error(let error):
			isConnected = false
			Log("websocket error \(String(describing: error))")
		case .peerClosed:
			isConnected = false
			Log("websocket peerClosed")
		}
	}
    
    
    func webSocketDidOpen() {
        Aria2.shared.initData.run()
        connectedServerInfo.name = Preferences.shared.aria2Servers.getSelectedName()
        Aria2.shared.getVersion {
            self.connectedServerInfo.version = "Version: \($0)"
            self.connectedServerInfo.enabledFeatures = $1
            NotificationCenter.default.post(name: .updateConnectStatus, object: nil)
        }
        Aria2.shared.getGlobalOption()
        ViewControllersManager.shared.showHUD(.connected)
        NotificationCenter.default.post(name: .sidebarSelectionChanged, object: nil)
        NotificationCenter.default.post(name: .updateGlobalStat, object: nil, userInfo: ["updateServer": true])
    }
    
    func webSocket(didCloseWithCode code: Int, reason: String) {
        connectedServerInfo.version = reason
        connectedServerInfo.enabledFeatures = ""
        aria2GlobalOption = [:]
        DataManager.shared.deleteAllAria2Objects()
        NotificationCenter.default.post(name: .updateConnectStatus, object: nil)
        NotificationCenter.default.post(name: .updateGlobalStat, object: nil, userInfo: ["updateServer": true])
    }
    
    func webSocket(didReceiveMessageWith string: String) {
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
                    if !NSApp.isActive,
                        Preferences.shared.completeNotice,
                        let gid = gids.first {
                        Aria2.shared.initData(gid) {
                            self.showNotification($0)
                        }
                    }
                    ViewControllersManager.shared.showHUD(.downloadCompleted)
                case .onDownloadStop:
                    Aria2.shared.updateStatus(gids)
                }
                if Preferences.shared.developerMode, Preferences.shared.recordWebSocketLog {
                    let log = WebSocketLog(context: DataManager.shared.context)
                    log.method = json.method.rawValue
                    log.receivedJSON = String(data: data, encoding: .utf8) ?? ""
                    log.success = true
                    log.date = Double(Date().timeIntervalSince1970)
                    DataManager.shared.saveContext()
                }
            }
        }
    }
    
    
    func clearUrls(_ json: String) -> Data? {
        let markStr = "\"uris\":"
        var json = json
        
        if json.contains(markStr) {
            
            let sIndex = json.indexes(of: "[").map({$0.utf16Offset(in: json)})
            let eIndex = json.indexes(of: "]").map({$0.utf16Offset(in: json)})
            let mIndex = json.indexes(of: markStr).map({$0.utf16Offset(in: json)})
            
            var ranges: [Range<String.Index>] = []
            
            mIndex.forEach { urlIndex in
                if let tt = sIndex.filter({ $0 > urlIndex }).min(),
                    let yy = eIndex.filter({ $0 > urlIndex }).min() {
                    ranges.append(json.index(after: .init(utf16Offset: tt, in: json)) ..< .init(utf16Offset: yy, in: json))
                }
            }
            ranges.reverse()
            ranges.forEach {
                json.removeSubrange($0)
            }
            return json.data(using: .utf8)
        }
        return json.data(using: .utf8)
    }
    
}


// https://stackoverflow.com/a/32306142
extension StringProtocol {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
