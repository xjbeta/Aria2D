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
        
    }
    
    func updateStatus(_ results: [Aria2Status]) throws {
        let gids = results.map({ $0.gid })
        
        try crateMissedObjects(gids)
        
        try aria2Objects(gids).forEach { obj in
            guard let status = results.filter({
                $0.gid == obj.gid
            }).first else { return }
            
            obj.status = status.status.rawValue
            obj.totalLength = status.totalLength
            obj.completedLength = status.completedLength
            obj.uploadLength = status.uploadLength
            obj.downloadSpeed = status.downloadSpeed
            obj.connections = Int64(status.connections)
//            obj.bittorrent = status.bittorrent
            obj.dir = status.dir
        }
    }
	
	func updateFiles(_ gid: String, files: [Aria2File]) throws {
        guard let obj = try aria2Objects([gid]).first else { return }
        files.forEach {
            $0.id = gid + "-files-\($0.index)"
            $0.object = obj
        }
        
        (obj.files?.allObjects as? [Aria2File])?.filter {
            !files.map({ $0.id }).contains($0.id)
        }.forEach {
            context.delete($0)
        }
	}
    
	func activeCount() throws -> Int {
        let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status IN %@", [Status.active.rawValue])
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
        context.perform {
            (NSApp.delegate as! AppDelegate).saveAction(nil)
        }
    }
}
