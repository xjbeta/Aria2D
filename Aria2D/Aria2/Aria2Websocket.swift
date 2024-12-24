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

@MainActor
final class Aria2Websocket: NSObject, Sendable {
	
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
    
    let waitingList = WaitingList()
    
    private var timerTask: Task<Void, Never>?
    private var isTimerRunning = false
	
	func initSocket() {
        stopTimer()
        
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
	
	func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timerTask = Task {
            while isTimerRunning {
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
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
        
        Task {
            await Aria2.shared.initData.debounce()
        }
	}
	
    func stopTimer() {
        isTimerRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    func write(_ dic: [String: Any],
               withID id: String,
               method: String) -> Promise<Data> {
        return Promise { resolver in
            let time = Double(Date().timeIntervalSince1970)
            
            Task {
                let (data, timeOut) = await waitingList.wait(id)
                // Save log
                if Preferences.shared.developerMode,
                    Preferences.shared.recordWebSocketLog {
                    
                    Task {
                        var receivedJSON = ""
                        if let str = String(data: data, encoding: .utf8),
                            let shrotData = Aria2Websocket.shared.clearUrls(str),
                            let shortStr = String(data: shrotData, encoding: .utf8) {
                            receivedJSON = shortStr
                        }
                        
                        await MainActor.run {
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
        Task {
            await waitingList.update(id, value: value)
        }
    }
}

enum webSocketResult: Error {
    case timeOut
    case receiveError(message: String)
    case somethingError
}

extension Aria2Websocket: @preconcurrency WebSocketDelegate {
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
        Task {
            await Aria2.shared.initData.debounce()
        }
        
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
                print("received, id: \(json.id)")
                
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


actor WaitingList {
    private var contents: [String: Data] = [:]
    private var semaphores: [String: DispatchSemaphore] = [:]
    
    func wait(_ key: String) async -> (value: Data, timeOut: Bool) {
        if let existingData = contents[key] {
            remove(key)
            return (existingData, false)
        }
        
        let success: Bool = await withCheckedContinuation { continuation in
            let semaphore = DispatchSemaphore(value: 0)
            semaphores[key] = semaphore
            
            DispatchQueue.global().async {
                let success = semaphore.wait(timeout: .now() + .seconds(30)) == .success
                continuation.resume(returning: success)
            }
        }
        
        let data = contents[key] ?? Data()
        remove(key)
        return (data, !success)
    }
    
    func update(_ key: String, value: Data) {
        guard semaphores[key] != nil else {
            return
        }
        contents[key] = value
        semaphores[key]?.signal()
    }
    
    private func remove(_ key: String) {
        contents[key] = nil
        semaphores[key] = nil
    }
}
