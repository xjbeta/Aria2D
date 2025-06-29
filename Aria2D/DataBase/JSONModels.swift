//
//  JSONModels.swift
//  Aria2D
//
//  Created by xjbeta on 2017/7/10.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation

struct JSONRPC: Decodable {
	let jsonrpc: String
//	let method: String
//	var params: Data
	let id: String
}

struct JSONNotice: Decodable {
	struct GID: Decodable {
		let gid: String
	}
	let jsonrpc: String
	let method: Aria2Notice
	let params: [GID]
}

struct Aria2Status: Decodable {
	let gid: String
	let status: String
	let totalLength: Int64
	let completedLength: Int64
	let uploadLength: Int64
	let downloadSpeed: Int64
    let uploadSpeed: Int64
	let connections: Int
    let bittorrent: Aria2Bittorrent?
	let dir: String?
	
	private enum CodingKeys: String, CodingKey {
		case gid,
		status,
		totalLength,
		completedLength,
		uploadLength,
		downloadSpeed,
        uploadSpeed,
		connections,
		bittorrent,
		dir
	}
	
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		gid = try values.decode(String.self, forKey: .gid)
		status = try values.decode(String.self, forKey: .status)
		totalLength = Int64(try values.decode(String.self, forKey: .totalLength)) ?? 0
		completedLength = Int64(try values.decode(String.self, forKey: .completedLength)) ?? 0
		uploadLength = Int64(try values.decode(String.self, forKey: .uploadLength)) ?? 0
		downloadSpeed = Int64(try values.decode(String.self, forKey: .downloadSpeed)) ?? 0
        uploadSpeed = Int64(try values.decode(String.self, forKey: .uploadSpeed)) ?? 0
		connections = Int(try values.decode(String.self, forKey: .connections)) ?? 0
		dir = try values.decodeIfPresent(String.self, forKey: .dir)
        bittorrent = try values.decodeIfPresent(Aria2Bittorrent.self, forKey: .bittorrent)
	}
}

struct Aria2GlobalStat: Decodable {
    let downloadSpeed: Int64
    let uploadSpeed: Int64
    let numActive: Int
    let numStopped: Int
    let numWaiting: Int
    let numStoppedTotal: Int
    
    private enum CodingKeys: String, CodingKey {
        case downloadSpeed,
        uploadSpeed,
        numActive,
        numStopped,
        numWaiting,
        numStoppedTotal
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        downloadSpeed = Int64(try values.decode(String.self, forKey: .downloadSpeed)) ?? 0
        uploadSpeed = Int64(try values.decode(String.self, forKey: .uploadSpeed)) ?? 0
        numActive = Int(try values.decode(String.self, forKey: .numActive)) ?? 0
        numStopped = Int(try values.decode(String.self, forKey: .numStopped)) ?? 0
        numWaiting = Int(try values.decode(String.self, forKey: .numWaiting)) ?? 0
        numStoppedTotal = Int(try values.decode(String.self, forKey: .numStoppedTotal)) ?? 0
    }
}

struct ErrorResult: Decodable {
	let code: Int
	let message: String
}


// getGlobalOption
public struct Aria2Version: Decodable {
	let enabledFeatures: [String]
	let version: String
}


struct OptionResult: Decodable {
	var result: [Aria2Option: String]
	private enum CodingKeys: String, CodingKey {
		case result
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		let dic = try values.decode([String: String].self, forKey: .result)
		result = dic.reduce([Aria2Option: String]()) { result, dic in
			var re = result
			re[Aria2Option(rawValue: dic.key)] = dic.value
			return re
		}
	}
}

@objc(Aria2Peer)
class Aria2Peer: NSObject, Decodable {
    @objc dynamic let peerId: String
    let ip: String
    let port: Int
    let amChoking: Bool
    let peerChoking: Bool
    @objc dynamic let downloadSpeed: Int64
    @objc dynamic let uploadSpeed: Int64
    let seeder: Bool
    
    @objc dynamic let ipWithPort: String
    
    private enum CodingKeys: String, CodingKey {
        case peerId,
        ip,
        port,
        amChoking,
        peerChoking,
        downloadSpeed,
        uploadSpeed,
        seeder
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        peerId = try values.decode(String.self, forKey: .peerId)
        ip = try values.decode(String.self, forKey: .ip)
        port = Int(try values.decode(String.self, forKey: .port)) ?? 0
        amChoking = try values.decode(String.self, forKey: .amChoking) == "true"
        peerChoking = try values.decode(String.self, forKey: .peerChoking) == "true"
        downloadSpeed = Int64(try values.decode(String.self, forKey: .downloadSpeed)) ?? 0
        uploadSpeed = Int64(try values.decode(String.self, forKey: .uploadSpeed)) ?? 0
        seeder = try values.decode(String.self, forKey: .seeder) == "true"
        ipWithPort = ip + ":" + "\(port)"
    }
}
