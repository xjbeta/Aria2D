//
//  DataManager.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class DataManager: NSObject {
	static let shared = DataManager()
	
	fileprivate override init() {

	}
	
	fileprivate var realm: Realm {
		let realmConfiguration = Realm.Configuration(inMemoryIdentifier: "InMemoryRealm")
		return try! Realm(configuration: realmConfiguration)
	}
	
	
	func initAllObjects(_ objs: [Aria2Object]) {
		writeToRealm { realm in
			let deleteGids = Set(realm.objects(Aria2Object.self).map { $0.gid }).subtracting(Set(objs.map { $0.gid }))
			let deleteObjs = realm.objects(Aria2Object.self).filter {
				deleteGids.contains($0.gid)
			}
			realm.delete(deleteObjs)
			realm.add(objs, update: true)
		}
	}
	
	func sortAllObjects(_ gids: [String]) {
		writeToRealm { realm in
			let deleteGids = Set(realm.objects(Aria2Object.self).map { $0.gid }).subtracting(Set(gids))
			let deleteObjs = realm.objects(Aria2Object.self).filter {
				deleteGids.contains($0.gid)
			}
			realm.delete(deleteObjs)
			gids.forEach {
				realm.object(ofType: Aria2Object.self, forPrimaryKey: $0)?.updateDate()
			}
		}
	}
	
	
	func initObjects(_ objs: [Aria2Object]) {
		writeToRealm { realm in
			realm.add(objs, update: true)
		}
	}
	
	
	func deleteAllAria2Objects() {
		writeToRealm { realm in
			realm.delete(realm.objects(Aria2Object.self))
		}
	}
    
    func updateStatus(_ results: [Aria2Status]) {
		writeToRealm { realm in
			results.map { $0.dic() }.forEach {
				realm.create(Aria2Object.self, value: $0, update: true)
			}
		}
    }
	
	func updateError(_ results: [ErrorResult]) {
		results.forEach {
			switch $0.message {
			case let str where str.contains(" is not found"):
				let gid = str.subString(from: "GID ", to: " is not found")
				writeToRealm { realm in
					if let obj = realm.object(ofType: Aria2Object.self, forPrimaryKey: gid) {
						realm.delete(obj)
					}
				}
			case let str where str.contains("No such download for GID#"):
				let gid = str.subString(from: "No such download for GID#")
				writeToRealm { realm in
					if let obj = realm.object(ofType: Aria2Object.self, forPrimaryKey: gid) {
						realm.delete(obj)
					}
				}
				
				
				
			default:
				break
			}
		}
	}
	
    
	func updateFiles(_ gid: String, files: [Aria2File]) {
		writeToRealm { realm in
			if let obj = realm.object(ofType: Aria2Object.self, forPrimaryKey: gid) {
				obj.files = files
			}
		}
	}

	
    
    func onDownloadRemove(_ gidList: [String]) {
        writeToRealm { realm in
			let objs = gidList.flatMap {
				realm.object(ofType: Aria2Object.self, forPrimaryKey: $0)
			}
			realm.delete(objs)
        }
    }

	
    func deletePCSFile(_ path: String) {
		writeToRealm {
            if let obj = $0.objects(PCSFile.self).filter("path == '\(path)'").first {
                $0.delete(obj)
            }
		}
	}
    
    
// MARK: - Set Or Update Data For Baidu Files
    func setData(forBaidu files: [PCSFile], forPath path: String) {
		var fileObjects: [PCSFile] = files
		// set the button back to parent directory
		if path != Baidu.shared.mainPath {
			let object = PCSFile()
			object.isBackButton = true
			object.displayDir = path
			object.fsID = -2333
            object.backParentDir = (path as NSString).deletingLastPathComponent
			fileObjects.append(object)
		}

        writeToRealm { realm in
			realm.delete(realm.objects(PCSFile.self).filter({ $0.isBackButton }))
			if let oldPath = realm.objects(PCSFile.self).filter({ !$0.isBackButton }).first?.path,
				let oldParentDir = NSURL(fileURLWithPath: oldPath).deletingLastPathComponent?.path,
				oldParentDir == path {
				// path didn't changed
				let deletePaths = Set(realm.objects(PCSFile.self).map { $0.path }).subtracting(Set(fileObjects.map { $0.path }))
				let objs = realm.objects(PCSFile.self).filter {
					deletePaths.contains($0.path)
				}
				realm.delete(objs)
				realm.add(fileObjects, update: true)
			} else {
				// path changed
				realm.delete(realm.objects(PCSFile.self))
				realm.add(fileObjects, update: true)
			}
        }
    }
    
    
    
 //MARK: - Get Data
    func data<T: Object>(_ type: T.Type) -> Results<T> {
        switch ViewControllersManager.shared.selectedRow {
        case .downloading:
            return realm.objects(type)
				.filter("status != %@", Status.complete.rawValue)
				.filter("status != %@", Status.removed.rawValue)
				.sorted(byKeyPath: "date")
				.sorted(byKeyPath: "status")
        case .completed:
            return realm.objects(type)
				.filter("status == %@", Status.complete.rawValue)
				.sorted(byKeyPath:"date", ascending: false)
		case .removed:
			return realm.objects(type)
				.filter("status == %@", Status.removed.rawValue)
				.sorted(byKeyPath: "date")
        case .baidu:
			let ascending = Preferences.shared.ascending
			let sortValue = Preferences.shared.sortValue
			var re = realm.objects(type)
			if sortValue != "path" {
				re = re.sorted(byKeyPath: "path", ascending: true)
			}
			return re.sorted(byKeyPath: sortValue, ascending: ascending)
				.sorted(byKeyPath: "isdir", ascending: false)
				.sorted(byKeyPath: "isBackButton", ascending: false)
        default:
            return realm.objects(type).filter("status == -1")
        }
    }
	
	func activeCount() -> Int {
		return realm.objects(Aria2Object.self).filter("status == %@", Status.active.rawValue).count
    }
}



// MARK: - Private Function For TaskObject
private extension DataManager {
    
	func writeToRealm(block: @escaping (_ realm: Realm) -> Void) {
		DispatchQueue(label: "io.realm.realm.background").async {
			autoreleasepool {
				try? self.realm.write {
					block(self.realm)
				}
			}
		}
	}
}
