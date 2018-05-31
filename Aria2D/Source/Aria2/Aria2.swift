//
//  Aria2.swift
//  Aria2D
//
//  Created by xjbeta on 2016/12/18.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class Aria2: NSObject {
	static let shared = Aria2()

	fileprivate override init() {
	}
	
	let refresh = WaitTimer(timeOut: .milliseconds(50)) {
		Aria2.shared.initData()
	}
	
    func initData() {
        let block: ((webSocketResult) -> Void) = {
            switch $0 {
            case .success(let data):
                struct InitDataResult: Decodable {
                    var result: [[[Aria2Object]]]
                }
                if let objs = data.decode(InitDataResult.self)?.result.flatMap ({ $0 }).flatMap ({ $0 }) {
                    DataManager.shared.initAllObjects(objs)
                }
            default:
                break
            }
        }

        var params: [Any]? = []

        switch ViewControllersManager.shared.selectedRow {
        case .downloading:
            params = [[Aria2WebsocketParams(method: Aria2Method.tellActive,
                                            params: nil ).object(),
                       Aria2WebsocketParams(method: Aria2Method.tellWaiting,
                                            params: [0, 1000]).object()]]
        case .removed, .completed:
            params = [[Aria2WebsocketParams(method: Aria2Method.tellStopped,
                                 params: [0, 1000]).object()]]
        default:
            break
        }

        Aria2WebsocketObject(method: Aria2Method.multicall,
                             params: params)
            .writeToWebsocket {
                block($0)
        }
    }
	
	func sortData() {
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [[Aria2WebsocketParams(method: Aria2Method.tellActive,
		                                                    params: [["gid"]]).object(),
		                               Aria2WebsocketParams(method: Aria2Method.tellWaiting,
		                                                    params: [0, 1000, ["gid"]]).object(),
		                               Aria2WebsocketParams(method: Aria2Method.tellStopped,
		                                                    params: [0, 1000, ["gid"]]).object()]])
			.writeToWebsocket {
				switch $0 {
				case .success(let data):
					
					struct GIDList: Decodable {
						var result: [[[[String: String]]]]
					}
					
                    if let gids = data.decode(GIDList.self)?.result.flatMap ({ $0 }).flatMap ({ $0 }).map ({ $0["gid"] }).compactMap ({ $0 }) {
						DataManager.shared.sortAllObjects(gids)
					}
				default:
					break
				}
		}
	}
	
	
	
	let aria2c = Aria2c()

	func initData(_ gid: String, block: @escaping (_ result: Data) -> Void = { _ in}) {
		Aria2WebsocketObject(method: Aria2Method.tellStatus,
		                     params: [gid])
			.writeToWebsocket {
				switch $0 {
				case .success(let data):
					block(data)
				default:
					break
				}
		}
	}



	func updateActiveTasks() {
		Aria2WebsocketObject(method: Aria2Method.tellActive,
		                     params: [["gid",
		                               "status",
									   "completedLength",
									   "totalLength",
									   "downloadSpeed",
									   "uploadLength",
									   "connections"]])
			.writeToWebsocket {
				switch $0 {
				case .success(let data):
					struct Result: Decodable {
						let result: [Aria2Status]
					}
					if let result = data.decode(Result.self)?.result {
						DataManager.shared.updateStatus(result)
					}
				default:
					break
				}
		}
	}
	
	func updateStatus(_ gids: [String], block: (([Aria2Status]) -> Void)? = nil) {
		guard effectiveGIDs(gids).count > 0 else { return }
		let params = gids.map {
			Aria2WebsocketParams(method: Aria2Method.tellStatus,
			                     params: [$0, ["gid",
			                                   "status",
			                                   "completedLength",
			                                   "totalLength",
			                                   "downloadSpeed",
			                                   "uploadLength",
			                                   "connections",
			                                   "bittorrent",
			                                   "dir"]]).object()
		}
		
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket {
				switch $0 {
				case .success(let data):
					
					struct Result: Decodable {
						struct ResultObj: Decodable {
							let error: ErrorResult?
							let dic: [Aria2Status]?
							init(from decoder: Decoder) throws {
								let unkeyedContainer = try decoder.singleValueContainer()
								error = try? unkeyedContainer.decode(ErrorResult.self)
								dic = try? unkeyedContainer.decode([Aria2Status].self)
							}
						}
						var result: [ResultObj]
						
						func errorObjs() -> [ErrorResult] {
							return result.map {
								$0.error
                                }.compactMap { $0 }
						}
						
						func initObjs() -> [Aria2Status] {
							return result.map {
								$0.dic
                                }.compactMap { $0 }.flatMap { $0 }
						}
					}
					if let result = data.decode(Result.self) {
						DataManager.shared.updateStatus(result.initObjs())
						DataManager.shared.updateError(result.errorObjs())
					}
					self.sortData()
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

    func getFiles(_ gid: String, block: @escaping () -> Void = {}) {
		Aria2WebsocketObject(method: Aria2Method.getFiles,
		                     params: [gid])
			.writeToWebsocket {
				switch $0 {
				case .success(let data):
					struct Result: Decodable {
						let result: [Aria2File]
					}
					if let re = data.decode(Result.self)?.result {
						DataManager.shared.updateFiles(gid, files: re)   
					}
                    block()
				default:
					break
				}
		}
	}
	

	func addUri(_ uri: String, options: [String: String] = [:]) {
		var opt = options
		if let path = Preferences.shared.aria2Servers.getServer().customPath,
			opt["dir"] == nil {
			opt["dir"] = path
		}
		Aria2WebsocketObject(method: Aria2Method.addUri,
		                     params: [[uri], opt])
			.writeToWebsocket {
				switch $0 {
				case .success(let data):
					struct Result: Decodable {
						let result: String
					}
					if let gid = data.decode(Result.self)?.result {
						self.updateStatus([gid])
					}
				default:
					break
				}
		}
	}

	func addUri(fromBaidu uri: [String], name: String) {
		guard uri.count > 0 else { return }

		var options: [String: String] = ["out": name,
			"continue": "true",
			"split": "255",
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
				case .success(let data):
					struct Result: Decodable {
						let result: String
					}
					if let result = data.decode(Result.self)?.result {
						self.updateStatus([result])
					}
					break
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
				case .success(let data):
					struct Result: Decodable {
						let result: String
					}
					if let result = data.decode(Result.self)?.result {
						self.updateStatus([result])
					}
				default:
					break
				}
		}
	}



	func pause(_ gids: [String]) {
		let method = Preferences.shared.useForce ? Aria2Method.forcePause : Aria2Method.pause
		let params = gids.map {
			Aria2WebsocketParams(method: method, params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket { _ in
				self.updateStatus(gids)
		}
	}


	func unpause(_ gids: [String]) {
		let params = gids.map {
			Aria2WebsocketParams(method: Aria2Method.unpause, params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket { _ in
				self.updateStatus(gids)
		}
	}



	func removeDownloadResult(_ gids: [String]) {
		guard gids.count > 0 else { return }
		let params = gids.map {
			Aria2WebsocketParams(method: Aria2Method.removeDownloadResult, params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket {
				switch $0 {
				case .success:
					self.sortData()
				default:
					break
				}
		}
	}


	func remove(_ gids: [String]) {
		guard gids.count > 0 else { return }
		let method = Preferences.shared.useForce ? Aria2Method.forceRemove : Aria2Method.remove
		let params = gids.map {
			Aria2WebsocketParams(method: method, params: [$0]).object()
		}
		Aria2WebsocketObject(method: Aria2Method.multicall,
		                     params: [params])
			.writeToWebsocket {
				switch $0 {
				case .success:
					self.updateStatus(gids)
				default:
					break
				}
		}
	}



	func pauseAll() {
		let gids = DataManager.shared.data(Aria2Object.self).filter {
			$0.status == .active && $0.status == .waiting
			}.map {
				$0.gid
		} as [String]
		let method = Preferences.shared.useForce ? Aria2Method.forcePauseAll : Aria2Method.pauseAll
		Aria2WebsocketObject(method: method,
		                     params: [])
			.writeToWebsocket { _ in
				self.updateStatus(gids)
		}
	}

	func unPauseAll() {
		let gids = DataManager.shared.data(Aria2Object.self).filter {
			$0.status == .paused
			}.map {
				$0.gid
		} as [String]
		Aria2WebsocketObject(method: Aria2Method.unpauseAll,
		                     params: [])
			.writeToWebsocket { _ in
				self.updateStatus(gids)
		}
	}

	func changeGlobalOption(_ key: Aria2Option, value: String, completion: @escaping (_ success: Bool) -> Void) {
		Aria2WebsocketObject(method: Aria2Method.changeGlobalOption,
		                     params: [[key.rawValue: value]])
			.writeToWebsocket {
				switch $0 {
				case .success(let data):
					struct Result: Codable {
						let result: String
					}
					if let result = data.decode(Result.self)?.result,
						result == "OK" {
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
				case .success(let data):
					if let options = data.decode(OptionResult.self)?.result {
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
				case .success(let data):
					struct Result: Decodable {
						var result: Aria2Version
					}
					if let result = data.decode(Result.self)?.result {
						block(result.version, result.enabledFeatures.map({ "✓ " + $0 }).joined(separator: "\n"))
					}
				default:
					break
				}
		}
	}
	
	func getOption(_ gid: String, block: @escaping (_ options: [Aria2Option: String]) -> Void) {
		
		Aria2WebsocketObject(method: Aria2Method.getOption,
		                     params: [gid])
			.writeToWebsocket {
				switch $0 {
				case .success(let data):
					if let options = data.decode(OptionResult.self)?.result {
						block(options)
					}
				default:
					break
				}
		}
	}
	
    func getPeer(_ gid: String, block: @escaping (_ peer: [Aria2Peer]) -> Void) {
        Aria2WebsocketObject(method: Aria2Method.getPeers,
                             params: [gid])
            .writeToWebsocket {
                switch $0 {
                case .success(let data):
                    struct Result: Decodable {
                        let result: [Aria2Peer]
                    }
                    if let result = data.decode(Result.self)?.result {
                        block(result)
                    }
                    
                default:
                    break
                }
        }
    }
    
    func getServers(_ gid: String, block: @escaping () -> Void) {
        Aria2WebsocketObject(method: Aria2Method.getServers,
                             params: [gid])
            .writeToWebsocket {
                switch $0 {
                case .success(let data):

                    block()
                    
                default:
                    break
                }
        }
    }
    
    func getUris(_ gid: String, block: @escaping () -> Void) {
        Aria2WebsocketObject(method: Aria2Method.getUris,
                             params: [gid])
            .writeToWebsocket {
                switch $0 {
                case .success(let data):
                    
                    block()
                    
                default:
                    break
                }
        }
    }
    
    
	func changeOption(_ gid: String, key: String, value: String , block: @escaping (_ success: Bool) -> Void) {
		Aria2WebsocketObject(method: Aria2Method.changeOption,
		                     params: [gid, [key: value]])
			.writeToWebsocket {
                switch $0 {
                case .success(let data):
                    struct Result: Decodable {
                        let result: String
                    }
                    if let result = data.decode(Result.self)?.result,
                        result == "OK" {
                        block(true)
                        return
                    }
                default:
                    break
                }
                block(false)
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
		
		func writeToWebsocket(_ methodName: String = #function, block: @escaping (_ result: webSocketResult) -> Void) {

			
			let str: [String: Any] = {
				var str: [String: Any] = ["jsonrpc": 2.0,
				                          "id": id,
				                          "method": method]
				if let jsonrpc = jsonrpc {
					str["jsonrpc"] = jsonrpc
				}
				
				if Preferences.shared.aria2Servers.getSelectedToken().count > 0 {
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
			
			Aria2Websocket.shared.write(str, withID: id, method: methodName) {
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
			if Preferences.shared.aria2Servers.getSelectedToken().count > 0 {
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

	
	func effectiveGIDs(_ gids: [String]) -> [String] {
		return gids.filter { $0.count == 16 }
	}
	
}


extension String {
	func paramsEncode() -> String {
//		base64 Encoded
		let base64 = self.data(using: .utf8)?.base64EncodedString() ?? ""
//		Percent Encoded
		if base64.last == "=" {
			return String(base64.dropLast()) + "%3D"
		}
		return ""
	}
}


enum webSocketResult {
	case success(data: Data)
	case timeOut
	case receiveError(message: String)
	case somethingError
}
