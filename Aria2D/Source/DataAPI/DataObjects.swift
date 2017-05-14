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
public typealias Status = String
public typealias Percentage = String
public typealias ProgressIndicator = Double
public typealias Time = String
public typealias Speed = String

class TaskObject: Object {
	
    dynamic var gid: GID = ""
    dynamic var path: Path = ""
    dynamic var totalLength: TotalLength = 0
    dynamic var status: Status = ""
    dynamic var percentage: Percentage = ""
    dynamic var progressIndicator: ProgressIndicator = 0
    dynamic var time: Time = ""
    dynamic var speed: Speed = ""
    dynamic var date: Double = 0
    dynamic var sortInt: Int = -1
    dynamic var connections: Int = -1
	dynamic var isBitTorrent = false
    
	convenience init(gid: GID,
	                 path: Path,
	                 totalLength: TotalLength,
	                 status: Status,
	                 percentage: Percentage,
	                 progressIndicator: ProgressIndicator,
	                 time: Time,
	                 speed: Speed,
	                 date: Double,
	                 sortInt: Int,
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
        self.sortInt = sortInt
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
	
	dynamic var path = ""
	dynamic var size = 0
	dynamic var isDir = false
	dynamic var server_mtime = 0.0
	dynamic var fs_id = -1
	dynamic var md5 = ""
	dynamic var displayDir = ""
	
	dynamic var backParentDir = ""
	dynamic var isBackButton = false
	
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
