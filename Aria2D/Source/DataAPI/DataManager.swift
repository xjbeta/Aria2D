//
//  DataManager.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON
import RealmSwift

class DataManager: NSObject {
	static let shared = DataManager()
	
	fileprivate override init() {

	}

	
	fileprivate let realmConfiguration = Realm.Configuration(inMemoryIdentifier: "InMemoryRealm")
	fileprivate let realmQueue = DispatchQueue(label: "com.xjbeta.Aria2D.realmQueue")
	
	
// MARK: - Set Or Update Data For Download Task
    func setData(_ json: JSON) {
        writeToRealm { realm in
			var newObjects: [TaskObject] = []
            //activeList
            json["result"][0][0].arrayValue.forEach {
				newObjects.append(self.dataFormat($0))
            }
            
            // waitingList & pausedList
            json["result"][1][0].arrayValue.forEach {
                let status = $0["status"].stringValue
                switch status {
                case "waiting":
                    newObjects.append(self.dataFormat($0))
                case "paused":
                    newObjects.append(self.dataFormat($0))
                default:
                    break
                }
            }
            
            // completeList & errorList & removedList
            json["result"][2][0].arrayValue.forEach {
                let status = $0["status"].stringValue
                switch status {
                case "complete":
                    newObjects.append(self.dataFormat($0))
                case "error":
                    newObjects.append(self.dataFormat($0))
                case "removed":
                    newObjects.append(self.dataFormat($0))
                default:
                    break
                }
            }
			
			let deleteGids = Set(realm.objects(TaskObject.self).map { $0.gid }).subtracting(Set(newObjects.map { $0.gid }))
			let objs = realm.objects(TaskObject.self).filter {
				deleteGids.contains($0.gid)
			}
			realm.delete(objs)
			realm.add(newObjects, update: true)
        }
    }
	
	func deleteAllTaskObject() {
		writeToRealm { realm in
			realm.delete(realm.objects(TaskObject.self))
		}
	}
    
    func updateActive(_ json: JSON) {
        if json["result"].arrayValue.count == activeCount() {
            writeToRealm { realm in
                json["result"].forEach {
                    realm.create(TaskObject.self, value: self.dataFormatForUpdate($0.1), update: true)
                }
            }
        }
    }
    
    func updateStatus(_ json: JSON) {
		let objs = json["result"].filter {
			!$0.1["code"].exists()
			}.map {
				self.dataFormat($0.1[0])
		}
		var removes = [String]()
		json["result"].filter {
			$0.1["code"].exists()
			}.map {
				$0.1["message"].stringValue
			}.forEach {
				switch $0 {
				case _ where $0.contains("Invalid GID "):
					removes.append($0.subString(from: "Invalid GID "))
//				case _ where $0.contains(" is not unique"):
//					removes.append($0.subString(from: "GID ", to: " is not unique"))
				case _ where $0.contains(" is not found"):
					removes.append($0.subString(from: "GID ", to: " is not found"))
				default:
					break
				}
		}
		
		
        writeToRealm { realm in
			realm.delete(realm.objects(TaskObject.self).filter({removes.contains($0.gid)}))
			realm.add(objs, update: true)
        }
    }
    
	func updateFiles(_ gid: [GID], json: JSON) {
		writeToRealm { realm in
			json.enumerated().forEach {
				if let gid = gid[safe: $0.offset] {
					let path = $0.element.1[0][0]["path"].stringValue
					let length = $0.element.1[0][0]["length"].intValue
					realm.create(TaskObject.self,
					             value: ["gid": gid,
					                     "path": path,
					                     "totalLength": length],
					             update: true)
				}
			}
		}
	}
	
    
    
    func onDownloadStart(_ json: JSON) {
        writeToRealm { realm in
            realm.add(self.dataFormat(json), update: true)
        }
    }
    
    func onDownloadComplete(_ gids: [GID]) {
        updateStatus(gids, status: "complete")
    }
    
    func onDownloadPause(_ gids: [GID]) {
        updateStatus(gids, status: "paused")
    }
    
    func onDownloadRemove(_ gidList: [GID]) {
        writeToRealm { realm in
            gidList.forEach {
				if let obj = realm.objects(TaskObject.self).filter("gid == '\($0)'").first {
					realm.delete(obj)
				}
            }
        }
    }
    
    func onDownloadError(_ gids: [GID]) {
        updateStatus(gids, status: "error")
    }
	
	func deleteBaiduObject(_ path: String) {
		writeToRealm {
			if let obj = $0.objects(BaiduFileObject.self).filter("path == '\(path)'").first {
				$0.delete(obj)
			}
		}
	}
    
    
// MARK: - Set Or Update Data For Baidu Files
    func setData(forBaidu json: JSON, forPath path: String) {
        writeToRealm { realm in
			realm.delete(realm.objects(BaiduFileObject.self).filter({ $0.isBackButton }))
			var newObjects: [BaiduFileObject] = []
			// set the button back to parent directory
			if path != Baidu.shared.mainPath, let backParentDir = NSURL(fileURLWithPath: path).deletingLastPathComponent?.path {
				let object = BaiduFileObject()
				object.isBackButton = true
				object.displayDir = path
				object.fs_id = -2333
				object.backParentDir = backParentDir
				newObjects.append(object)
			}
			
			json["list"].arrayValue.forEach {
				newObjects.append(self.dataFormat(forBaidu: $0))
			}
			
			if let oldPath = realm.objects(BaiduFileObject.self).filter({ !$0.isBackButton }).first?.path,
				let oldParentDir = NSURL(fileURLWithPath: oldPath).deletingLastPathComponent?.path,
				oldParentDir == path {
					let deletePaths = Set(realm.objects(BaiduFileObject.self).map { $0.path }).subtracting(Set(newObjects.map { $0.path }))
					let objs = realm.objects(BaiduFileObject.self).filter {
						deletePaths.contains($0.path)
					}
					realm.delete(objs)
					realm.add(newObjects, update: true)
					return
			}
			realm.delete(realm.objects(BaiduFileObject.self))
			realm.add(newObjects, update: true)
        }
    }
    
    
    
 //MARK: - Get Data
    func data<T, R: Results<T>>(_ type: T.Type, path: String? = nil) -> R {
		let realm = try! Realm(configuration: realmConfiguration)
        switch ViewControllersManager.shared.selectedRow {
        case .downloading:
            return realm.objects(type).filter("status != 'complete'").filter("status != 'removed'").sorted(byKeyPath: "date").sorted(byKeyPath: "sortInt") as! R
        case .completed:
            return realm.objects(type).filter("status == 'complete'").sorted(byKeyPath: "date", ascending: false) as! R
		case .removed:
			return realm.objects(type).filter("status == 'removed'").sorted(byKeyPath: "date", ascending: false) as! R
        case .baidu:
			let ascending = Preferences.shared.ascending
			let sortValue = Preferences.shared.sortValue
			var sortDescriptors = [SortDescriptor(keyPath: "isBackButton", ascending: false),
			                       SortDescriptor(keyPath: "isDir", ascending: false),
			                       SortDescriptor(keyPath: sortValue, ascending: ascending)]
			if sortValue != "path" {
				sortDescriptors.append(SortDescriptor(keyPath: "path", ascending: true))
			}
			return realm.objects(type).sorted(by: sortDescriptors) as! R
        default:
            return realm.objects(type).filter("status == 'nil'") as! R
        }
    }
	
	
    func activeCount() -> Int {
		let realm = try! Realm(configuration: realmConfiguration)
        return realm.objects(TaskObject.self).filter("status == 'active'").count
    }
}



// MARK: - Private Function For TaskObject
private extension DataManager {
	
	func writeToRealm(block: @escaping (_ realm: Realm) -> Void) {
		realmQueue.async {
			autoreleasepool {
				let realm = try! Realm(configuration: self.realmConfiguration)
				try! realm.write{
					block(realm)
				}
			}
		}
	}
	
    
    func dataFormat(_ json: JSON) -> TaskObject {
		let completedLength = json["completedLength"]
		let totalLengthByte = json["totalLength"]
		let downloadSpeed = json["downloadSpeed"]
		
		
		let obj = TaskObject()
		obj.gid = json["gid"].stringValue
		obj.date = getDate()
		obj.isBitTorrent = json["bittorrent"].exists()
		obj.path = json["bittorrent"].exists() ?
			json["dir"].stringValue + "/" + json["bittorrent"]["info"]["name"].stringValue :
			json["files"][0]["path"].stringValue
		
		obj.totalLength = totalLengthByte.intValue
		obj.connections = json["connections"].intValue
		
		obj.percentage = {
			if totalLengthByte.doubleValue != 0 {
				let per = completedLength.doubleValue / totalLengthByte.doubleValue * 100
				obj.progressIndicator = per
				return "\(strFormat(per))%"
			} else {
				obj.progressIndicator = 0
				return "0.0%"
			}
		}()
		obj.status = json["status"].stringValue
		obj.speed = {
			if obj.status == "active" {
				return "\(downloadSpeed.int64Value.ByteFileFormatter())/s"
			} else {
				return ""
			}
		}()
		
		obj.time = timeFormat(totalLengthByte.int64Value - completedLength.int64Value, speed: downloadSpeed.int64Value)
		obj.sortInt = getSortInt(obj.status)
		
		return obj
    }
    
    
    
	func dataFormatForUpdate(_ json: JSON) -> [String: Any] {
        let completedLength = json["completedLength"]
        let totalLength = json["totalLength"]
        let downloadSpeed = json["downloadSpeed"]
        let gid = json["gid"].gidValue
		let connections = json["connections"].intValue
		
        var progressIndicator: Double = 0
		let percentage: String = {
			if totalLength.doubleValue != 0 {
				let per = completedLength.doubleValue/totalLength.doubleValue*100
				progressIndicator = per
				return "\(strFormat(per))%"
			} else {
				progressIndicator = 0
				return "0.0%"
			}
		}()
		
        let time = timeFormat(totalLength.int64Value - completedLength.int64Value, speed: downloadSpeed.int64Value)
        let speed = "\(downloadSpeed.int64Value.ByteFileFormatter())/s"
        
        return ["gid": gid,
                "progressIndicator": progressIndicator,
                "percentage": percentage,
                "time": time,
                "speed": speed,
                "totalLength": totalLength.intValue,
                "connections": connections]
        
    }
    
    
    
    func updateStatus(_ gids: [GID], status: Status) {
        writeToRealm { realm in
            gids.forEach {
				realm.create(TaskObject.self,
				             value: ["gid": $0,
				                     "status": status,
				                     "sortInt": self.getSortInt(status),
				                     "date": self.getDate()],
				             update: true)
            }
        }
    }



    
    
    
    func strFormat(_ double: Double) -> String {
        var str = String(format: "%.1f", Float(double))
        if str.hasSuffix(".0") {
            let range = str.characters.index(str.endIndex, offsetBy: -2)..<str.endIndex
            str.removeSubrange(range)
        }
        return str
    }
    
    
    
    func downloadTaskNameConverter(_ dir: String, path: String) -> String {
        var str = path.replacingOccurrences(of: dir, with: "", options: NSString.CompareOptions.literal, range: nil)
        if str != "" {
            str.remove(at: str.startIndex)
        }
        return str
    }
    
    
    func getDate() -> Double {
        return Date().timeIntervalSince1970
    }
    
    func getSortInt(_ status: String) -> Int {
        switch status {
        case "active":
            return 1
        case "waiting":
            return 2
        case "paused":
            return 3
        case "error":
            return 4
        default:
            return -1
        }
    }
    
    
    
    func timeFormat(_ length: Int64, speed: Int64) -> String {
		if speed == 0 { return "INF" }

        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .default
        formatter.allowedUnits = [.day, .hour, .minute, .second, .year]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .abbreviated
        formatter.calendar?.locale = Locale(identifier: "en_US")
        
        var component = DateComponents()
        component.second = Int(length / speed)
		
        if let str = formatter.string(for: component) {
            return str.replacingOccurrences(of: " ", with: "")
        } else {
            return "INF"
        }
    }
    

    func dataFormat(forBaidu json: JSON) -> BaiduFileObject {
        let path = json["path"].stringValue
        let isDir = json["isdir"].boolValue
        let server_mtime = json["server_mtime"].doubleValue
        let fs_id = json["fs_id"].intValue
		let size = isDir ? -1 : json["size"].intValue
		let md5 = isDir ? "" : json["md5"].stringValue
		let displayDir = URL(fileURLWithPath: path).deletingLastPathComponent().absoluteURL.path
        return BaiduFileObject(path: path,
                               size: size,
                               isDir: isDir,
                               server_mtime: server_mtime,
                               fs_id: fs_id,
                               md5: md5,
                               displayDir: displayDir)
    }
}

