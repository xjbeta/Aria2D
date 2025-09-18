//
//  Aria2.swift
//  Aria2D
//
//  Created by xjbeta on 2016/12/18.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

@MainActor
final class Aria2: NSObject, Sendable {
	static let shared = Aria2()

	fileprivate override init() {
	}
	
    let reloadAll = Debouncer(duration: 0.2) {
        try? await Aria2.shared.reloadAll()
    }
    
    let sortAll = Debouncer(duration: 0.2) {
        try? await Aria2.shared.sortAll()
    }
    
    let reloadAllForName = Debouncer(duration: 10) {
        try? await Aria2.shared.reloadAll()
    }
    
    let aria2c = Aria2c()
    
    private func reloadAll() async throws {
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

        let data = try await send(method: Aria2Method.multicall, params: params)
        struct Result: Decodable {
            var result: [[[Aria2Object]]]
        }
        
        let objs = try JSONDecoder().decode(Result.self, from: data).result.flatMap({ $0 }).flatMap({ $0 })
        
        try DataManager.shared.reloadAllObjects(objs)
    }
	
    private func sortAll() async throws {
        let data = try await send(
            method: Aria2Method.multicall,
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
        
        struct GIDList: Decodable {
            var result: [[[[String: String]]]]
        }
        
        let re = try JSONDecoder().decode(GIDList.self, from: data).result.flatMap ({ $0 }).flatMap ({ $0 })
        
        let actives = re.filter {
            $0.contains(where: {
                $0.value == Status.active.rawValue
            })
        }
        
        if actives.count == 0 {
            NotificationCenter.default.post(name: .updateGlobalStat, object: nil, userInfo: ["updateServer": true])
        }
        
        try DataManager.shared.sortAllObjects(re)
    }
	
    func reloadData(_ gids: [String]) async throws {
        struct Result: Decodable {
            let result: [[Aria2Object]]
        }
        
        let params = gids.map {
            Aria2WebsocketParams(method: Aria2Method.tellStatus, params: [$0]).object
        }
        let data = try await send(method: Aria2Method.multicall, params: [params])
        let objs = try JSONDecoder().decode(Result.self, from: data).result.flatMap { $0 }
        
        try DataManager.shared.reloadObjects(objs)
    }

    func updateActiveTasks() async throws {
        let data = try await send(
            method: Aria2Method.multicall,
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
        struct Result: Decodable {
            let result: [ResultObj]
        }
        
        let results = try JSONDecoder().decode(Result.self, from: data).result
        
        for result in results {
            if let stat = result.globalStat {
                NotificationCenter.default.post(name: .updateGlobalStat, object: nil, userInfo: ["globalStat": stat, "updateServer": false])
            } else if result.status.count > 0 {
                try DataManager.shared.updateStatus(result.status)
            }
        }
        
        
        if let c = try? DataManager.shared.getAria2Objects().filter({
            $0.name == Aria2Object.unknownName
            && $0.status != Status.waiting.rawValue
            && $0.totalLength > 0
        }).count,
           c > 0 {
            await reloadAllForName.debounce()
        }
    }

    func shutdown() async throws {
        try await saveSession()
        try await send(method: Aria2Method.shutdown, params: [])
    }

    func saveSession() async throws {
        try await send(method: Aria2Method.saveSession, params: [])
    }

    func getFiles(_ gid: String) async throws {
        let data = try await send(method: Aria2Method.getFiles, params: [gid])
        struct Result: Decodable {
            let result: [Aria2File]
        }
        let re = try JSONDecoder().decode(Result.self, from: data).result
        try DataManager.shared.updateFiles(gid, files: re)
    }

    func addUri(_ uri: String, options: [String: String] = [:]) async throws {
        var opt = options
        if let path = Preferences.shared.aria2Servers.getServer().customPath,
            opt["dir"] == nil {
            opt["dir"] = path
        }
        let data = try await send(method: Aria2Method.addUri, params: [[uri], opt])
        struct Result: Decodable {
            let result: String
        }
        if let gid = data.decode(Result.self)?.result {
            try await reloadData([gid])
        }
    }

    func addTorrent(_ data: String, options: [String: String] = [:]) async throws {
        var opt = options
        if let path = Preferences.shared.aria2Servers.getServer().customPath, opt["dir"] == nil {
            opt["dir"] = path
        }
        let data = try await send(method: Aria2Method.addTorrent, params: [data, [], opt])
        struct Result: Decodable {
            let result: String
        }
        if let result = data.decode(Result.self)?.result {
            try await reloadData([result])
        }
    }

    func pause(_ gids: [String]) async throws {
        let method = Preferences.shared.useForce ? Aria2Method.forcePause : Aria2Method.pause
        let params = gids.map {
            Aria2WebsocketParams(method: method, params: [$0]).object
        }
        try await send(method: Aria2Method.multicall, params: [params])
        try await reloadData(gids)
    }

    func unpause(_ gids: [String]) async throws {
        let params = gids.map {
            Aria2WebsocketParams(method: Aria2Method.unpause, params: [$0]).object
        }
        try await send(method: Aria2Method.multicall, params: [params])
        try await reloadData(gids)
    }

    func removeDownloadResult(_ gids: [String]) async throws {
        guard gids.count > 0 else { return }
        let params = gids.map {
            Aria2WebsocketParams(method: Aria2Method.removeDownloadResult, params: [$0]).object
        }
        try await send(method: Aria2Method.multicall, params: [params])
        await sortAll.debounce()
    }

    func remove(_ gids: [String]) async throws {
        guard gids.count > 0 else { return }
        let method = Preferences.shared.useForce ? Aria2Method.forceRemove : Aria2Method.remove
        let params = gids.map {
            Aria2WebsocketParams(method: method, params: [$0]).object
        }
        try await send(method: Aria2Method.multicall, params: [params])
        await sortAll.debounce()
    }


    func pauseAll() async throws {
        let method = Preferences.shared.useForce ? Aria2Method.forcePauseAll : Aria2Method.pauseAll
        try await send(method: method, params: [])
        await sortAll.debounce()
    }

    func unPauseAll() async throws {
        try await send(method: Aria2Method.unpauseAll, params: [])
        await sortAll.debounce()
    }

    func changeGlobalOption(_ key: Aria2Option, value: String) async throws -> Bool {
        let data = try await send(method: Aria2Method.changeGlobalOption, params: [[key.rawValue: value]])
        struct Result: Codable {
            let result: String
        }
        if let result = data.decode(Result.self)?.result,
            result == "OK" {
            Aria2Websocket.shared.aria2GlobalOption[key] = value
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    func getGlobalOption() async throws -> [Aria2Option : String]? {
        let data = try await send(method: Aria2Method.getGlobalOption, params: [])
        let options = data.decode(OptionResult.self)?.result
        if let options {
            Aria2Websocket.shared.aria2GlobalOption = options
        }
        return options
    }


    func getVersion() async throws -> (version: String, features: String)? {
        let data = try await send(method: Aria2Method.getVersion, params: [])
        struct Result: Decodable {
            var result: Aria2Version
        }
        if let result = data.decode(Result.self)?.result {
            let features = result.enabledFeatures.map({ "✓ " + $0 }).joined(separator: "\n")
            return (result.version, features)
        } else {
            return nil
        }
    }

    func getOption(_ gid: String) async throws -> [Aria2Option: String]? {
        let data = try await send(method: Aria2Method.getOption, params: [gid])
        return data.decode(OptionResult.self)?.result
    }

    @discardableResult
    func getPeer(_ gid: String) async throws -> [Aria2Peer]? {
        let data = try await send(method: Aria2Method.getPeers, params: [gid])
        struct Result: Decodable {
            let result: [Aria2Peer]
        }
        return data.decode(Result.self)?.result
    }

    func getServers(_ gid: String) async throws {
        try await send(method: Aria2Method.getServers, params: [gid])
    }

    func getUris(_ gid: String) async throws {
        try await send(method: Aria2Method.getUris, params: [gid])
    }

    @discardableResult
    func changeOption(_ gid: String, key: String, value: String) async throws -> Bool {
        let data = try await send(method: Aria2Method.changeOption, params: [gid, [key: value]])
        struct Result: Decodable {
            let result: String
        }
        if let result = data.decode(Result.self)?.result,
            result == "OK" {
            return true
        } else {
            return false
        }
    }
}



fileprivate extension Aria2 {
    
    @discardableResult
    func send<T>(method: String, params: T, jsonrpc: Double? = 2.0, _ methodName: String = #function) async throws -> Data {
        let id = UUID().uuidString
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
        
        return try await Aria2Websocket.shared.write(str, withID: id, method: methodName)
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

