//
//  Aria2.swift
//  Aria2D
//
//  Created by xjbeta on 2016/12/18.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Starscream
import Just

class Aria2: NSObject {
	static let shared = Aria2()

	fileprivate override init() {
	}
	
	let refresh = WaitTimer(timeOut: .milliseconds(50)) {
		Aria2.shared.initData()
	}
	
	func initData() {
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [[Aria2WebsocketParams(method: Aria2Method.tellActive,
		                                                    params: nil).object(),
		                               Aria2WebsocketParams(method: Aria2Method.tellWaiting,
		                                                    params: [0, 1000]).object(),
		                               Aria2WebsocketParams(method: Aria2Method.tellStopped,
		                                                    params: [0, 1000]).object()]])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					DataManager.shared.setData(json)
				default:
					break
				}
		}
	}
	
	let aria2c = Aria2c()

	func initData(_ gids: [GID], update: Bool = true, block: @escaping (_ json: JSON) -> Void = { _ in}) {
		guard effectiveGIDs(gids).count > 0 else { return }
		let params = gids.map {
			Aria2WebsocketParams(method: Aria2Method.tellStatus,
			                     params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					if update {
						DataManager.shared.updateStatus(json)
					}
					block(json)
				default:
					break
				}
		}
	}



	func updateActiveTasks() {
		Aria2WebsocketObject(method: Aria2Method.tellActive,
		                     params: [["gid",
									   "completedLength",
									   "totalLength",
									   "downloadSpeed",
									   "connections"]])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					DataManager.shared.updateActive(json)
				default:
					break
				}
		}
	}

	func shutdown() {
		saveSession {
			Aria2WebsocketObject(method: Aria2Method.shutdown,
			                     params: [])
				.writeToWebsocket { _ in }
		}
	}

	func saveSession(_ block: @escaping () -> Void) {
		Aria2WebsocketObject(method: Aria2Method.saveSession,
		                     params: [])
			.writeToWebsocket { _ in
				block()
		}
	}

	func getFiles(_ gids: [GID]) {
		guard effectiveGIDs(gids).count > 0 else { return }
		let params = gids.map {
			Aria2WebsocketParams(method: Aria2Method.getFiles,
			                     params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					DataManager.shared.updateFiles(gids, json: json["result"])
				default:
					break
				}
		}
	}

	func addUri(_ uri: String, options: [String: String] = [:]) {
		var opt = options
		if let path = Preferences.shared.aria2Servers.getServer().customPath, opt["dir"] == nil {
			opt["dir"] = path
		}
		Aria2WebsocketObject(method: Aria2Method.addUri,
		                     params: [[uri], opt])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					json["result"].gidValue.initData()
				default:
					break
				}
		}
	}

	func addUri(fromBaidu uri: [String], name: String) {
		guard uri.count > 0 else { return }

		var options: [String: String] = ["out": name,
			"continue": "true",
			"split": "50",
			"max-connection-per-server": "16",
			"min-split-size": "1M",
			"user-agent": "netdisk"]
		
		if let path = Preferences.shared.aria2Servers.getServer().customPath {
			options["dir"] = path
		}
		
		Aria2WebsocketObject(method: Aria2Method.addUri,
		                     params: [uri, options])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					json["result"].gidValue.initData()
				default:
					break
				}
		}
	}


	func addTorrent(_ data: String, options: [String: String] = [:]) {
		var opt = options
		if let path = Preferences.shared.aria2Servers.getServer().customPath, opt["dir"] == nil {
			opt["dir"] = path
		}
		Aria2WebsocketObject(method: Aria2Method.addTorrent,
		                     params: [data, [], opt])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					Log(json)
				default:
					break
				}
		}
	}



	func pause(_ gids: [GID]) {
		guard effectiveGIDs(gids).count > 0 else { return }
		let method = Preferences.shared.useForce ? Aria2Method.forcePause : Aria2Method.pause
		let params = gids.map {
			Aria2WebsocketParams(method: method, params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket { _ in
				self.initData(gids)
		}
	}


	func unpause(_ gids: [GID]) {
		guard effectiveGIDs(gids).count > 0 else { return }
		let params = gids.map {
			Aria2WebsocketParams(method: Aria2Method.unpause, params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket { _ in
				self.initData(gids)
		}
	}



	func removeDownloadResult(_ gids: [GID]) {
		guard effectiveGIDs(gids).count > 0 else { return }
		let params = gids.map {
			Aria2WebsocketParams(method: Aria2Method.removeDownloadResult, params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					let successGids = gids.filter {
						json["result"][$0][0].stringValue == "OK"
					}
					guard successGids.count == gids.count else {
						self.refresh.run()
						return
					}
					DataManager.shared.onDownloadRemove(gids)
				default:
					break
				}
		}
	}


	func remove(_ gids: [GID]) {
		guard effectiveGIDs(gids).count > 0 else { return }
		let method = Preferences.shared.useForce ? Aria2Method.forceRemove : Aria2Method.remove
		let params = gids.map {
			Aria2WebsocketParams(method: method, params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket {
				switch $0 {
				case .success:
					self.initData(gids)
				default:
					break
				}
				
		}
	}



	func pauseAll() {
		let method = Preferences.shared.useForce ? Aria2Method.forcePauseAll : Aria2Method.pauseAll
		Aria2WebsocketObject(method: method,
		                     params: [])
			.writeToWebsocket { _ in
				self.refresh.run()
		}
	}

	func unPauseAll() {
		Aria2WebsocketObject(method: Aria2Method.unpauseAll,
		                     params: [])
			.writeToWebsocket { _ in
				self.refresh.run()
		}
	}

	func changeGlobalOption(_ key: Aria2Option, value: String, completion: @escaping (_ success: Bool) -> Void) {
		Aria2WebsocketObject(method: Aria2Method.changeGlobalOption,
		                     params: [[key.rawValue: value]])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					if json["result"].stringValue == "OK" {
						Aria2Websocket.shared.aria2GlobalOption[key] = value
						completion(true)
					} else {
						completion(false)
					}
				default:
					break
				}
		}
	}
	func getGlobalOption() {
		Aria2WebsocketObject(method: Aria2Method.getGlobalOption,
		                     params: [])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					if let dic = json["result"].dictionaryObject as? [String: String] {
						var options: [Aria2Option: String] = [:]
						for i in dic {
							options[Aria2Option(rawValue: i.key)] = i.value
						}
						Aria2Websocket.shared.aria2GlobalOption = options
					}
				default:
					break
				}
		}
	}
	

	func getVersion(_ block: @escaping (_ version: String, _ features: String) -> Void) {
		Aria2WebsocketObject(method: Aria2Method.getVersion,
		                     params: [])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					let features = json["result"]["enabledFeatures"].arrayValue.map {
						"✓ " + $0.stringValue
					}.joined(separator: "\n")
					block(json["result"]["version"].stringValue, features)
				default:
					break
				}
		}
	}
	
	func getOption(_ gid: GID, block: @escaping (_ options: JSON) -> Void) {
		
		Aria2WebsocketObject(method: Aria2Method.getOption,
		                     params: [gid])
			.writeToWebsocket {
				switch $0 {
				case .success(let json):
					block(json["result"])
				default:
					break
				}
		}
	}
	
	func getPeer(_ gid: GID, block: @escaping (_ peer: JSON) -> Void) {
		Aria2WebsocketObject(method: Aria2Method.getPeers,
		                     params: [gid])
			.writeToWebsocket {
				
				switch $0 {
				case .success(let json):
					block(json["result"])
				default:
					break
				}
		}
		
	}
	
	func changeOption(_ gid: GID, key: String, value: String , block: @escaping (_ result: WebSocketResult) -> Void) {
		Aria2WebsocketObject(method: Aria2Method.changeOption,
		                     params: [gid, [key: value]])
			.writeToWebsocket {
				block($0)
		}
	}
}



fileprivate extension Aria2 {
	struct Aria2WebsocketObject {
		private var id: String
		private var method: String
		private var jsonrpc: Double?
		private var params: [Any]?
		
		init<T>(method: String, params: T, jsonrpc: Double? = 2.0) {
			self.id = UUID().uuidString
			self.method = method
			self.params = params as? [Any]
			self.jsonrpc = jsonrpc
		}
		
		func writeToWebsocket(_ methodName: String = #function, block: @escaping (_ result: WebSocketResult) -> Void) {

			
			let str: [String: Any] = {
				var str: [String: Any] = ["jsonrpc": 2.0,
				                          "id": id,
				                          "method": method]
				if let jsonrpc = jsonrpc {
					str["jsonrpc"] = jsonrpc
				}
				
				if Preferences.shared.aria2Servers.getSelectedToken().characters.count > 0 {
					let token = "token:\(Preferences.shared.aria2Servers.getSelectedToken())"
					if var params = params {
						if method != Aria2Method.multicall {
							params.insert(token, at: 0)
							str["params"] = params
						}
						if params.count > 0 {
							str["params"] = params
						}
					}
				} else {
					if let params = params, params.count != 0 {
						str["params"] = params
					}
				}
				return str
			}()
			
			Aria2Websocket.shared.socket.write(str, withID: id, method: methodName) {
				block($0)
			}
		}
	}
	
	struct Aria2WebsocketParams {
		private var method: String
		private var params: [Any]?
		init(method: String, params: [Any]?) {
			self.method = method
			self.params = params
		}
		func object() -> [String: Any] {
			if Preferences.shared.aria2Servers.getSelectedToken().characters.count > 0 {
				let token = "token:\(Preferences.shared.aria2Servers.getSelectedToken())"
				if var p = params {
					p.insert(token, at: 0)
					return ["methodName": method, "params": p]
				} else {
					return ["methodName": method, "params": [token]]
				}
			} else {
				if let p = params {
					return ["methodName": method, "params": p]
				} else {
					return ["methodName": method]
				}
			}
		}
	}

	
	func effectiveGIDs(_ gids: [GID]) -> [GID] {
		return gids.filter { $0.characters.count == 16 }
	}
	
}


extension String {
	func paramsEncode() -> String {
//		base64 Encoded
		let base64 = self.data(using: .utf8)?.base64EncodedString() ?? ""
//		Percent Encoded
		if base64.characters.last == "=" {
			return String(base64.characters.dropLast()) + "%3D"
		}
		return ""
	}
}







extension WebSocket {

	private class WaitingList: NSObject {
		static let shared = WaitingList()
		
		fileprivate override init() {
		}
		
		private var contents: [String : Any] = [:]
		private let defaultValue = "defaultValue"
		private var semaphores: [String : DispatchSemaphore] = [:]
		
		func add(_ key: String, block: @escaping (_ value: Any, _ timeOut: Bool) -> Void) {
			contents[key] = defaultValue
			let semaphore = DispatchSemaphore(value: 0)
			self.semaphores[key] = semaphore
			DispatchQueue.global().async {
				switch semaphore.wait(timeout: .now() + .seconds(5)) {
				case .success:
					block(self.contents[key] as Any, false)
				case .timedOut:
					block("", true)
					self.remove(key)
				}
			}
		}
		
		func update(_ key: String, value: Any) {
			if contents[key] as? String == defaultValue,
				let semaphore = semaphores[key] {
				contents[key] = value
				semaphore.signal()
			}
		}
		
		private func remove(_ key: String) {
			contents.removeValue(forKey: key)
		}       
	}
	
	func write(_ dic: [String: Any],
	           withID id: String,
	           method: String,
	           completion: @escaping (_ result: WebSocketResult) -> Void) {
		let time = Date().timeIntervalSince1970
		WaitingList.shared.add(id) { (data, success) in
			if let json = data as? JSON {
				// Save log
				if Preferences.shared.recordWebSocketLog, JSON(dic)["method"].stringValue != Aria2Method.tellActive {
					var log = WebSocketLog()
					let sendJSON = JSON(dic)
					log.method = method
					log.sendJSON = "\(sendJSON)"
					log.receivedJSON = {
						// delete urls in json
						var str = "\(json)"
						while str.contains("\"uri\" : \"") {
							str = str.delete(between: "\"uris\" : [", and: "],")
						}
						return str
					}()
					log.success = !success
					log.time = time
					ViewControllersManager.shared.webSocketLog.append(log)
				}
				
				if !success {
					if json["error"].exists() {
						completion(.receiveError(message: json["error"]["message"].stringValue))
						return
					} else {
						completion(.success(json: json))
						return
					}
				} else {
					completion(.timeOut)
					return
				}
			}
			completion(.somethingError)
		}
		do {
			let data = try JSON(dic).rawData()
			self.write(data: data)
		} catch {
			completion(.somethingError)
			return
		}
	}
	
	func received(_ value: Any, withID id: String) {
		WaitingList.shared.update(id, value: value)
	}
}

enum WebSocketResult {
	case success(json: JSON)
	case timeOut
	case receiveError(message: String)
	case somethingError
}
