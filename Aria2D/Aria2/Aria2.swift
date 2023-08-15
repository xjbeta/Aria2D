//
//  Aria2.swift
//  Aria2D
//
//  Created by xjbeta on 2016/12/18.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import PromiseKit

class Aria2: NSObject {
	static let shared = Aria2()

	fileprivate override init() {
	}
	
    let initData = WaitTimer(timeOut: .milliseconds(150)) {
        Aria2.shared.initAllData()
    }

    let sortData = WaitTimer(timeOut: .milliseconds(150)) {
        Aria2.shared.sortAllData()
    }
    
    let aria2c = Aria2c()
    
    let context = DataManager.shared.context
    
    private func initAllData() {
        struct Result: Decodable {
            var result: [[[Aria2Object]]]
        }
        
        let params = [[
            Aria2WebsocketParams(
                method: Aria2Method.tellActive,
                params: nil ).object,
            Aria2WebsocketParams(
                method: Aria2Method.tellWaiting,
                params: [0, 1000]).object,
            Aria2WebsocketParams(
                method: Aria2Method.tellStopped,
                params: [0, 1000]).object]]

        send(method: Aria2Method.multicall,
             params: params)
            .done { data in
                let re = try JSONDecoder().decode(Result.self, data: data, in: self.context).result.flatMap({ $0 }).flatMap({ $0 })
                
                try DataManager.shared.initAllObjects(re)
            }.catch {
                Log("\(#function) error \($0)")
        }
    }
	
	private func sortAllData() {
        send(method: Aria2Method.multicall,
             params: [[
                Aria2WebsocketParams(
                    method: Aria2Method.tellActive,
                    params: [["gid", "status"]]).object,
                Aria2WebsocketParams(
                    method: Aria2Method.tellWaiting,
                    params: [0, 1000, ["gid", "status"]]).object,
                Aria2WebsocketParams(
                    method: Aria2Method.tellStopped,
                    params: [0, 1000, ["gid", "status"]]).object]])
            .done { data in
                struct GIDList: Decodable {
                    var result: [[[[String: String]]]]
                }
                
                let re = try JSONDecoder().decode(GIDList.self, from: data).result.flatMap ({ $0 }).flatMap ({ $0 })
				
				let actives = re.filter {
					$0.contains(where: {
						$0.value == Status.active.string()
					})
				}
				
				if actives.count == 0 {
					NotificationCenter.default.post(name: .updateGlobalStat, object: nil, userInfo: ["updateServer": true])
				}
				
                try DataManager.shared.sortAllObjects(re)
            }.catch {
                Log("\(#function) error \($0)")
        }
	}
	
    func initData(_ gid: String, block: @escaping (_ result: Aria2Object) -> Void = { _ in}) {
        send(method: Aria2Method.tellStatus,
             params: [gid])
            .done { data in
                struct Result: Decodable {
                    let result: Aria2Object
                }
                let re = try JSONDecoder().decode(Result.self, data: data, in: self.context).result
                try DataManager.shared.initObject(re)
                block(re)
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func updateActiveTasks() {
        send(method: Aria2Method.multicall,
             params: [[
                Aria2WebsocketParams(
                    method: Aria2Method.tellActive,
                    params: [["gid",
                              "status",
                              "completedLength",
                              "totalLength",
                              "downloadSpeed",
                              "uploadLength",
                              "uploadSpeed",
                              "connections",
                              "bittorrent",
                              "dir"]]).object,
                Aria2WebsocketParams(
                    method: Aria2Method.getGlobalStat,
                    params: []).object]])
            .done { data in
                struct Result: Decodable {
                    let result: [ResultObj]
                    struct ResultObj: Decodable {
                        var status: [Aria2Status] = []
                        var globalStat: Aria2GlobalStat?
                        init(from decoder: Decoder) throws {
                            let unkeyedContainer = try decoder.singleValueContainer()
                            if let stats = try? unkeyedContainer.decode([[Aria2Status]].self) {
                                status = stats.flatMap({ $0 })
                            } else if let globalStat = try? unkeyedContainer.decode([Aria2GlobalStat].self).first {
                                self.globalStat = globalStat
                            }
                        }
                    }
                }
                try JSONDecoder().decode(Result.self, data: data, in: self.context).result.forEach {
                    if let stat = $0.globalStat {
                        NotificationCenter.default.post(name: .updateGlobalStat, object: nil, userInfo: ["globalStat": stat, "updateServer": false])
                    } else if $0.status.count > 0 {
                        try DataManager.shared.updateStatus($0.status)
                    }
                }
        }.catch {
            Log("\(#function) error \($0)")
        }
    }

    func updateStatus(_ gids: [String], block: (([Aria2Status]) -> Void)? = nil) {
        guard effectiveGIDs(gids).count > 0 else { return }
        let params = gids.map {
            Aria2WebsocketParams(
                method: Aria2Method.tellStatus,
                params: [$0, ["gid",
                              "status",
                              "completedLength",
                              "totalLength",
                              "downloadSpeed",
                              "uploadLength",
                              "uploadSpeed",
                              "connections",
                              "bittorrent",
                              "dir"]]).object
        }

        send(method: Aria2Method.multicall,
                             params: [params])
            .done { data in
                struct Result: Decodable {
                    var result: [[Aria2Status]]
                }
                let result = try JSONDecoder().decode(Result.self, data: data, in: self.context).result.flatMap({ $0 })
                try DataManager.shared.updateStatus(result)
                self.sortData.run()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func shutdown(_ block: @escaping () -> Void) {
        saveSession {
            self.send(method: Aria2Method.shutdown,
                                 params: [])
                .done { _ in
                    block()
                }.catch {
                    Log("\(#function) error \($0)")
            }
        }
    }

    func saveSession(_ block: @escaping () -> Void) {
        send(method: Aria2Method.saveSession,
                             params: [])
            .done { _ in
                block()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func getFiles(_ gid: String, block: @escaping () -> Void = {}) {
        send(method: Aria2Method.getFiles,
             params: [gid])
            .done { data in
                struct Result: Decodable {
                    let result: [Aria2File]
                }
                let re = try JSONDecoder().decode(Result.self, data: data, in: self.context).result
                try DataManager.shared.updateFiles(gid, files: re)
                block()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }


    func addUri(_ uri: String, options: [String: String] = [:]) {
        var opt = options
        if let path = Preferences.shared.aria2Servers.getServer().customPath,
            opt["dir"] == nil {
            opt["dir"] = path
        }
        send(method: Aria2Method.addUri,
             params: [[uri], opt])
            .done { data in
                struct Result: Decodable {
                    let result: String
                }
                if let gid = data.decode(Result.self)?.result {
                    self.updateStatus([gid])
                }
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func addTorrent(_ data: String, options: [String: String] = [:]) {
        var opt = options
        if let path = Preferences.shared.aria2Servers.getServer().customPath, opt["dir"] == nil {
            opt["dir"] = path
        }
        send(method: Aria2Method.addTorrent,
             params: [data, [], opt])
            .done { data in
                struct Result: Decodable {
                    let result: String
                }
                if let result = data.decode(Result.self)?.result {
                    self.updateStatus([result])
                }
            }.catch {
                Log("\(#function) error \($0)")
        }
    }



    func pause(_ gids: [String]) {
        let method = Preferences.shared.useForce ? Aria2Method.forcePause : Aria2Method.pause
        let params = gids.map {
            Aria2WebsocketParams(method: method, params: [$0]).object
        }
        send(method: Aria2Method.multicall,
             params: [params])
            .done { _ in
                self.updateStatus(gids)
            }.catch {
                Log("\(#function) error \($0)")
        }
    }


    func unpause(_ gids: [String]) {
        let params = gids.map {
            Aria2WebsocketParams(method: Aria2Method.unpause, params: [$0]).object
        }
        send(method: Aria2Method.multicall,
             params: [params])
            .done { _ in
                self.updateStatus(gids)
            }.catch {
                Log("\(#function) error \($0)")
        }
    }



    func removeDownloadResult(_ gids: [String]) {
        guard gids.count > 0 else { return }
        let params = gids.map {
            Aria2WebsocketParams(method: Aria2Method.removeDownloadResult, params: [$0]).object
        }
        send(method: Aria2Method.multicall,
             params: [params])
            .done { _ in
                self.sortData.run()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }


    func remove(_ gids: [String]) {
        guard gids.count > 0 else { return }
        let method = Preferences.shared.useForce ? Aria2Method.forceRemove : Aria2Method.remove
        let params = gids.map {
            Aria2WebsocketParams(method: method, params: [$0]).object
        }
        send(method: Aria2Method.multicall,
             params: [params])
            .done { _ in
                self.sortData.run()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }



    func pauseAll() {
        let method = Preferences.shared.useForce ? Aria2Method.forcePauseAll : Aria2Method.pauseAll
        send(method: method,
             params: [])
            .done { _ in
                self.sortData.run()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func unPauseAll() {
        send(method: Aria2Method.unpauseAll,
             params: [])
            .done { _ in
                self.sortData.run()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func changeGlobalOption(_ key: Aria2Option, value: String, completion: @escaping (_ success: Bool) -> Void) {
        send(method: Aria2Method.changeGlobalOption,
             params: [[key.rawValue: value]])
            .done { data in
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
            }.catch {
                Log("\(#function) error \($0)")
        }
    }
    func getGlobalOption(_ block: @escaping () -> Void = {}) {
        send(method: Aria2Method.getGlobalOption,
             params: [])
            .done { data in
                if let options = data.decode(OptionResult.self)?.result {
                    Aria2Websocket.shared.aria2GlobalOption = options
                    block()
                }
            }.catch {
                Log("\(#function) error \($0)")
        }
    }


    func getVersion(_ block: @escaping (_ version: String, _ features: String) -> Void) {
        send(method: Aria2Method.getVersion,
             params: [])
            .done { data in
                struct Result: Decodable {
                    var result: Aria2Version
                }
                if let result = data.decode(Result.self)?.result {
                    block(result.version, result.enabledFeatures.map({ "✓ " + $0 }).joined(separator: "\n"))
                }
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func getOption(_ gid: String, block: @escaping (_ options: [Aria2Option: String]) -> Void) {
        send(method: Aria2Method.getOption,
             params: [gid])
            .done { data in
                if let options = data.decode(OptionResult.self)?.result {
                    block(options)
                }
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func getPeer(_ gid: String, block: @escaping (_ peer: [Aria2Peer]) -> Void) {
        send(method: Aria2Method.getPeers,
             params: [gid])
            .done { data in
                struct Result: Decodable {
                    let result: [Aria2Peer]
                }
                if let result = data.decode(Result.self)?.result {
                    block(result)
                }
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func getServers(_ gid: String, block: @escaping () -> Void) {
        send(method: Aria2Method.getServers,
             params: [gid])
            .done { _ in
                block()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }

    func getUris(_ gid: String, block: @escaping () -> Void) {
        send(method: Aria2Method.getUris,
             params: [gid])
            .done { _ in
                block()
            }.catch {
                Log("\(#function) error \($0)")
        }
    }


    func changeOption(_ gid: String, key: String, value: String , block: @escaping (_ success: Bool) -> Void) {
        send(method: Aria2Method.changeOption,
             params: [gid, [key: value]])
            .done { data in
                struct Result: Decodable {
                    let result: String
                }
                if let result = data.decode(Result.self)?.result,
                    result == "OK" {
                    block(true)
                }
            }.catch {
                Log("\(#function) error \($0)")
        }
    }
}



fileprivate extension Aria2 {
    
    func send<T>(method: String, params: T, jsonrpc: Double? = 2.0, _ methodName: String = #function) -> Promise<Data> {
        let id = UUID().uuidString
        return Promise { resolver in
            let str: [String: Any] = {
                var str: [String: Any] = ["jsonrpc": 2.0,
                                          "id": id,
                                          "method": method]
                if let jsonrpc = jsonrpc {
                    str["jsonrpc"] = jsonrpc
                }
                
                if Preferences.shared.aria2Servers.getSelectedToken().count > 0 {
                    let token = "token:\(Preferences.shared.aria2Servers.getSelectedToken())"
                    if var params = params as? [Any] {
                        if method != Aria2Method.multicall {
                            params.insert(token, at: 0)
                            str["params"] = params
                        }
                        if params.count > 0 {
                            str["params"] = params
                        }
                    }
                } else {
                    if let params = params as? [Any], params.count != 0 {
                        str["params"] = params
                    }
                }
                return str
            }()
            
            Aria2Websocket.shared.write(str, withID: id, method: methodName)
                .done {
                    resolver.fulfill($0)
                }.catch {
                    resolver.reject($0)
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
        
        var object: [String: Any] {
            get {
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
	}

	
	func effectiveGIDs(_ gids: [String]) -> [String] {
		return gids.filter { $0.count == 16 }
	}
	
}

