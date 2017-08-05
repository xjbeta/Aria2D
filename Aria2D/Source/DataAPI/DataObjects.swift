//
//  TaskObject.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/13.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

final class Aria2Object: Object, Decodable {
	private let _files = List<Aria2File>()
	var files: [Aria2File] {
		get {
			return _files.map { $0 }
		}
		set {
			_files.removeAll()
			_files.append(objectsIn: newValue.map(Aria2File.init))
		}
	}
	
	
	@objc dynamic var gid: String = ""
	@objc dynamic var status: Status = .error
	@objc dynamic var totalLength: Int64 = 0
	@objc dynamic var completedLength: Int64 = 0 
	@objc dynamic var uploadLength: Int64 = 0
	@objc dynamic var downloadSpeed: Int64 = 0
	@objc dynamic var pieceLength: Int64 = 0
	@objc dynamic var connections: Int = 0
	@objc dynamic var dir: String = ""
	@objc dynamic var date: Double = 0

	
	//	let uploadSpeed: String
	//	let infoHash: String = ""
	//	let numSeeders: String
	//	let seeder: Bool
	//	let numPieces: String
	//	let errorCode: String
	//	let errorMessage: String
	//	let followedBy: String
	//	let following: String
	//	let belongsTo: String
	
	//	let verifiedLength: String
	//	let verifyIntegrityPending: String
	
	@objc dynamic var bittorrent: Bittorrent?
	
	private enum CodingKeys: String, CodingKey {
		case files,
		gid,
		status,
		totalLength,
		completedLength,
		uploadLength,
		downloadSpeed,
		pieceLength,
		connections,
		dir,
		bittorrent
	}
	
	
	required convenience init(from decoder: Decoder) throws {
		self.init()
		let values = try decoder.container(keyedBy: CodingKeys.self)
		files = try values.decode([Aria2File].self, forKey: .files)
		gid = try values.decode(String.self, forKey: .gid)
		status = Status(try values.decode(String.self, forKey: .status)) ?? .error
		totalLength = Int64(try values.decode(String.self, forKey: .totalLength)) ?? 0
		completedLength = Int64(try values.decode(String.self, forKey: .completedLength)) ?? 0
		uploadLength = Int64(try values.decode(String.self, forKey: .uploadLength)) ?? 0
		downloadSpeed = Int64(try values.decode(String.self, forKey: .downloadSpeed)) ?? 0
		pieceLength = Int64(try values.decode(String.self, forKey: .pieceLength)) ?? 0
		connections = Int(try values.decode(String.self, forKey: .connections)) ?? 0
		dir = try values.decode(String.self, forKey: .dir)
		bittorrent = try values.decodeIfPresent(Bittorrent.self, forKey: .bittorrent)
		date = Date().timeIntervalSince1970
	}

	func updateDate() {
		date = Date().timeIntervalSince1970
	}
	
	override class func primaryKey() -> String? {
		return "gid"
	}
	
	override static func indexedProperties() -> [String] {
		return ["gid"]
	}
}


class Aria2File: Object, Decodable {
	@objc dynamic var index: Int = -1
	@objc dynamic var path: String = ""
	@objc dynamic var length: Int64 = 0
	@objc dynamic var completedLength: Int64 = 0
	@objc dynamic var selected: Bool = false
	private let _uris = List<Aria2Uri>()
//	@objc dynamic var uris: [String] = []

	var uris: [Aria2Uri] {
		get {
			return _uris.map { $0 }
		}
		set {
			_uris.removeAll()
			_uris.append(objectsIn: newValue.map(Aria2Uri.init))
		}
	}


	
	private enum CodingKeys: String, CodingKey {
		case index,
		path,
		length,
		completedLength,
		selected,
		uris
	}
	
	required convenience init(from decoder: Decoder) throws {
		self.init()
		let values = try decoder.container(keyedBy: CodingKeys.self)
		index = Int(try values.decode(String.self, forKey: .index)) ?? -1
		path = try values.decode(String.self, forKey: .path)
		length = Int64(try values.decode(String.self, forKey: .length)) ?? 0
		completedLength = Int64(try values.decode(String.self, forKey: .completedLength)) ?? 0
		selected = try values.decode(String.self, forKey: .selected) == "true"

		uris = try values.decode([Aria2Uri].self, forKey: .uris)
//			.map { $0.uri }
	}
	
	func dic() -> [String: Any] {
		var dic: [String: Any] = [:]
		dic["index"] = index
		dic["path"] = path
		dic["length"] = length
		dic["completedLength"] = completedLength
		dic["selected"] = selected
		//		dic["index"] = index
		
		return dic
	}
}


class Aria2Uri: Object, Codable {
	@objc dynamic var status: String = ""
	@objc dynamic var uri: String = ""
	
	private enum CodingKeys: String, CodingKey {
		case status,
		uri
	}
	
	required convenience init(from decoder: Decoder) throws {
		self.init()
		let values = try decoder.container(keyedBy: CodingKeys.self)
		status = try values.decode(String.self, forKey: .status)
		uri = try values.decode(String.self, forKey: .uri)
	}
}




class Bittorrent: Object, Decodable {
//	class Info: Object, Decodable {
//		@objc dynamic var name: String = ""
//
//		private enum CodingKeys: String, CodingKey {
//			case name
//		}
//
//		required convenience init(from decoder: Decoder) throws {
//			self.init()
//			let values = try decoder.container(keyedBy: CodingKeys.self)
//			name = try values.decode(String.self, forKey: .name)
//		}
//	}


	@objc enum FileMode: Int, Decodable {
		case multi, single, error
		init?(_ str: String) {
			switch str {
			case "multi": self.init(rawValue: 0)
			case "single": self.init(rawValue: 1)
			default:
				self.init(rawValue: 2)
			}
		}
	}


	//	announceList
	@objc dynamic var name: String? = nil
	@objc dynamic var mode: FileMode = .error

	private enum CodingKeys: String, CodingKey {
		case name = "info",
		mode
	}

	required convenience init(from decoder: Decoder) throws {
		self.init()
		let values = try decoder.container(keyedBy: CodingKeys.self)
		if let dic = try values.decodeIfPresent([String: String].self, forKey: .name) {
			name = dic["name"]
		}
		if let str = try values.decodeIfPresent(String.self, forKey: .mode) {
			mode = FileMode(str) ?? .error
		}
	}
}





class PCSFile: Object, Decodable {
	
	@objc dynamic var fsID: Int = -1
	@objc dynamic var path: String = ""
	@objc dynamic var name: String = ""
	@objc dynamic var size: Int = 0
	@objc dynamic var isdir: Bool = false
	@objc dynamic var serverMtime: Date = Date()
	@objc dynamic var md5: String = ""
	
	@objc dynamic var displayDir: String = ""
	@objc dynamic var backParentDir: String = ""
	@objc dynamic var isBackButton = false
	
	override class func primaryKey() -> String? {
		return "fsID"
	}
	
	override static func indexedProperties() -> [String] {
		return ["fsID"]
	}
	
	private enum CodingKeys: String, CodingKey {
		case fsID = "fs_id",
		path,
		name = "server_filename",
		size,
		isdir,
		serverMtime = "server_mtime",
		md5
	}
	
	required convenience init(from decoder: Decoder) throws {
		self.init()
		let values = try decoder.container(keyedBy: CodingKeys.self)
		fsID = try values.decode(Int.self, forKey: .fsID)
		path = try values.decode(String.self, forKey: .path)
		name = try values.decode(String.self, forKey: .name)
		size = try values.decode(Int.self, forKey: .size)
		isdir = try values.decode(Int.self, forKey: .isdir) == 1
		serverMtime = Date(timeIntervalSince1970: try values.decode(Double.self, forKey: .serverMtime))
		md5 = try values.decodeIfPresent(String.self, forKey: .md5) ?? ""


		displayDir = ""
		backParentDir = ""
		isBackButton = false
	}
}
