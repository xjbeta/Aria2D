//
//  DataManager.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class DataManager: NSObject {
	static let shared = DataManager()
	
	fileprivate override init() {
	}
	
    func deleteAllAria2Objects() {
        let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
        let fetch = try? context.fetch(fetchRequest)
        fetch?.forEach {
            context.delete($0)
        }
        saveContext()
    }
    
    func cleanUpLogs() {
        let fetchRequest: NSFetchRequest<WebSocketLog> = WebSocketLog.fetchRequest()
        let oneDayAgo = Int(Date().timeIntervalSince1970) - 60 * 60 * 8
        fetchRequest.predicate = NSPredicate(format: "date < %i", oneDayAgo)
        let fetch = try? context.fetch(fetchRequest)
        fetch?.forEach {
            context.delete($0)
        }
        saveContext()
    }
    
    let appDelegate = (NSApp.delegate as! AppDelegate)
    let context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var aria2List: Aria2List? = {
        do {
            return try requestAria2List().first
        } catch let error {
            Log(error)
            return nil
        }
    }()
    
    func initAria2List() throws {
        let re = try requestAria2List()
        if re.count > 1 {
            re.enumerated().reversed().forEach {
                if $0.offset != 0 {
                    context.delete($0.element)
                }
            }
        } else if re.count == 0 {
            _ = Aria2List(context: context)
        }
        saveContext()
    }
    
    func requestAria2List() throws -> [Aria2List] {
        let request: NSFetchRequest<Aria2List> = Aria2List.fetchRequest()
        return try context.fetch(request)
    }

    func deleteAria2Objects(_ gids: [String]) throws {
        let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "NOT (gid IN %@)", gids)
        let objects = try context.fetch(fetchRequest)
        objects.forEach {
            context.delete($0)
        }
    }
    
    func crateMissedObjects(_ gids: [String]) throws {
        let existenceGids = aria2Objects().compactMap {
            $0.gid
        }
        gids.filter {
            !existenceGids.contains($0)
            }.forEach {
                let object = Aria2Object(context: self.context)
                object.gid = $0
        }
    }
    
    func aria2Objects(_ gids: [String]) throws -> [Aria2Object] {
        let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "gid IN %@", gids)
        return try context.fetch(fetchRequest)
    }
    
    func aria2Objects() -> [Aria2Object] {
        let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func initAllObjects(_ objs: [Aria2Object]) throws {
        let gids = objs.compactMap({ $0.gid})
        try deleteAria2Objects(gids)

        let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "gid IN %@", gids)
        let needUpdateObjs = try context.fetch(fetchRequest)
        let needUpdateGids = needUpdateObjs.map { $0.gid }

        objs.forEach { obj in
            guard needUpdateGids.contains(obj.gid), let oldObj = needUpdateObjs.filter({
                $0.gid == obj.gid
            }).first else {
                context.insert(obj)
                if let b = obj.bittorrent {
                    context.insert(b)
                }
                (obj.files?.allObjects as? [Aria2File])?.forEach {
                    context.insert($0)
                }
                obj.list = aria2List
                return
            }
            oldObj.update(with: obj, context: context)
        }
        
        saveContext()
    }
    
    func initObject(_ obj: Aria2Object) throws {
        guard let oldObj = try aria2Objects([obj.gid]).first else {
            return
        }
        oldObj.update(with: obj, context: context)
    }
    
    func sortAllObjects(_ gidsDic: [[String: String]]) throws {
        let gids = gidsDic.compactMap({ $0["gid"]})
        try deleteAria2Objects(gids)
        try crateMissedObjects(gids)
        
        try gidsDic.forEach { dic in
            let obj = try aria2Objects(gids).filter {
                $0.gid == dic["gid"]
            }.first
            obj?.status = Status(dic["status"] ?? "")?.rawValue ?? 3
            obj?.sortValue = Double(Date().timeIntervalSince1970)
        }
        saveContext()
    }
    
    func updateStatus(_ results: [Aria2Status]) throws {
        let gids = results.map({ $0.gid })
        
        try crateMissedObjects(gids)
        
        try aria2Objects(gids).forEach { obj in
            guard let status = results.filter({
                $0.gid == obj.gid
            }).first else { return }
            obj.update(with: status)
        }
        saveContext()
    }
	
	func updateFiles(_ gid: String, files: [Aria2File]) throws {
        guard let obj = try aria2Objects([gid]).first else { return }
        files.forEach {
            $0.id = gid + "-files-\($0.index)"
        }
        obj.updateFiles(with: files, context: context)
        saveContext()
	}
    
	func activeCount() throws -> Int {
        let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status IN %@", [Status.active.rawValue])
        return try context.count(for: fetchRequest)
    }
    
    func activeBittorrentCount() throws -> Int {
        let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status IN %@ AND bittorrent != nil",
                                             [Status.active.rawValue])
        return try context.count(for: fetchRequest)
    }
    
    func deleteLogs() {
        let fetchRequest: NSFetchRequest<WebSocketLog> = WebSocketLog.fetchRequest()
        let fetch = try? context.fetch(fetchRequest)
        fetch?.forEach {
            context.delete($0)
        }
        saveContext()
    }
    
    func saveContext() {
        DispatchQueue.main.async {
            (NSApp.delegate as? AppDelegate)?.saveAction(nil)
        }
    }
}
