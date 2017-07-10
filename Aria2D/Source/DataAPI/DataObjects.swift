//
//  TaskObject.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/13.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

public typealias GID = String
public typealias Path = String
public typealias TotalLength = Int
public typealias Percentage = String
public typealias ProgressIndicator = Double
public typealias Time = String
public typealias Speed = String
@objc enum status: Int {
	case active
	case waiting
	case paused
	case error
	case complete
	case removed
	
	init?(_ str: String) {
		switch str {
		case "active": self.init(rawValue: 0)
		case "waiting": self.init(rawValue: 1)
		case "paused": self.init(rawValue: 2)
		case "error": self.init(rawValue: 3)
		case "complete": self.init(rawValue: 4)
		case "removed": self.init(rawValue: 5)
		default:
			self.init(rawValue: -1)
		}
	}
	
	func string() -> String {
		switch self {
		case .active: return "active"
		case .waiting: return "waiting"
		case .paused: return "paused"
		case .error: return "error"
		case .complete: return "complete"
		case .removed: return "removed"
		}
	}
}

class TaskObject: Object {
	
    @objc dynamic var gid: GID = ""
    @objc dynamic var path: Path = ""
    @objc dynamic var totalLength: TotalLength = 0
    @objc dynamic var status: status = .removed
    @objc dynamic var percentage: Percentage = ""
    @objc dynamic var progressIndicator: ProgressIndicator = 0
    @objc dynamic var time: Time = ""
    @objc dynamic var speed: Speed = ""
    @objc dynamic var date: Double = 0
    @objc dynamic var connections: Int = -1
	@objc dynamic var isBitTorrent = false
    
	convenience init(gid: GID,
	                 path: Path,
	                 totalLength: TotalLength,
	                 status: status,
	                 percentage: Percentage,
	                 progressIndicator: ProgressIndicator,
	                 time: Time,
	                 speed: Speed,
	                 date: Double,
	                 connections: Int,
	                 isBitTorrent: Bool) {
        self.init()
        self.gid = gid
        self.path = path
        self.totalLength = totalLength
        self.status = status
        self.percentage = percentage
        self.progressIndicator = progressIndicator
        self.time = time
        self.speed = speed
        self.date = date
		self.connections = connections
		self.isBitTorrent = isBitTorrent
    }
    
    override class func primaryKey() -> String? {
        return "gid"
    }
    
    override static func indexedProperties() -> [String] {
        return ["gid"]
    }
}




class BaiduFileObject: Object {
	
	@objc dynamic var path = ""
	@objc dynamic var size = 0
	@objc dynamic var isDir = false
	@objc dynamic var server_mtime = 0.0
	@objc dynamic var fs_id = -1
	@objc dynamic var md5 = ""
	@objc dynamic var displayDir = ""
	
	@objc dynamic var backParentDir = ""
	@objc dynamic var isBackButton = false
	
	convenience init(path: String, size: Int, isDir: Bool, server_mtime: Double, fs_id: Int, md5: String, displayDir: String) {
		self.init()
		self.path = path
		self.size = size
		self.isDir = isDir
		self.server_mtime = server_mtime
		self.fs_id = fs_id
		self.md5 = md5
		self.displayDir = displayDir
	}
	
	
	override class func primaryKey() -> String? {
		return "fs_id"
	}
	
	override static func indexedProperties() -> [String] {
		return ["fs_id"]
	}
}

extension GID {
	func pause() {
		Aria2.shared.pause([self])
	}
	
	func unpause() {
		Aria2.shared.unpause([self])
	}
	
	func removeDownloadResult() {
		Aria2.shared.removeDownloadResult([self])
	}
	
	func remove() {
		Aria2.shared.remove([self])
	}
	
	func initData() {
		Aria2.shared.initData([self])
	}
	
	func onDownloadPause() {
		DataManager.shared.onDownloadPause([self])
	}
	func onDownloadComplete() {
		DataManager.shared.onDownloadComplete([self])
	}
	func onDownloadError() {
		DataManager.shared.onDownloadError([self])
	}
}


extension JSON {
    //Non-optional gid
    public var gidValue: GID {
        get {
            switch self.type {
            case .string:
                return self.object as? GID ?? ""
            case .number:
                return self.object as? GID ?? ""
            default:
                return ""
            }
        }
        set {
            self.object = NSString(string:newValue)
        }
    }
}
