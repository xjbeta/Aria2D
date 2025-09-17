//
//  DataManager.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import WCDBSwift

public enum DBTableNames: String, Sendable {
    case aria2Object = "Aria2ObjectTable"
    case aria2Bittorrent = "Aria2BittorrentTable"
    case aria2File = "Aria2FileTable"
    case aria2Uri = "Aria2UriTable"
    case aria2Log = "Aria2LogTable"
}

@MainActor
final class DataManager: NSObject, Sendable {
    static let shared = DataManager()
    
    private let database: Database
    private let aria2ObjectTable: Table<Aria2Object>
    private let aria2BittorrentTable: Table<Aria2Bittorrent>
    private let aria2FileTable: Table<Aria2File>
    private let aria2UriTable: Table<Aria2Uri>
    private let aria2LogTable: Table<Aria2Log>
    
    @MainActor
    private let observerManager = ObserverManager()
    
    fileprivate override init() {
        let dbName = "/DataBase/Aria2D-WCDB.db"
        if let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.path,
           let identifier = Bundle.main.bundleIdentifier {
            database = Database(at: path + "/\(identifier)" + dbName)
        } else {
            database = Database(at: FileManager.default.temporaryDirectory.path + dbName)
        }
        
        Log("WCDB path: \(database.path)")
        
        do {
            try database.create(table: DBTableNames.aria2Object.rawValue, of: Aria2Object.self)
            try database.create(table: DBTableNames.aria2Bittorrent.rawValue, of: Aria2Bittorrent.self)
            try database.create(table: DBTableNames.aria2File.rawValue, of: Aria2File.self)
            try database.create(table: DBTableNames.aria2Uri.rawValue, of: Aria2Uri.self)
            try database.create(table: DBTableNames.aria2Log.rawValue, of: Aria2Log.self)
        } catch {
            assert(false, "Init database failed: \(error)")
        }
        aria2ObjectTable = database.getTable(named: DBTableNames.aria2Object.rawValue)
        aria2BittorrentTable = database.getTable(named: DBTableNames.aria2Bittorrent.rawValue)
        aria2FileTable = database.getTable(named: DBTableNames.aria2File.rawValue)
        aria2UriTable = database.getTable(named: DBTableNames.aria2Uri.rawValue)
        aria2LogTable = database.getTable(named: DBTableNames.aria2Log.rawValue)
        super.init()
    }
    
// MARK: - Data Retrieval
    
    func aria2Object(_ gid: String, deep: Bool = false) throws -> Aria2Object? {
        let obj = try aria2ObjectTable.getObject(where: Aria2Object.Properties.gid == gid)
        guard deep else { return obj }
        obj?.bittorrent = try DataManager.shared.aria2Bittorrent(gid)
        obj?.files = try DataManager.shared.aria2Files(gid)
        return obj
    }
    
    func getAria2Objects() throws -> [Aria2Object] {
        try aria2ObjectTable.getObjects()
    }
    
    func getAria2Objects(_ gids: [String]) throws -> [Aria2Object] {
        try aria2ObjectTable.getObjects(where: Aria2Object.Properties.gid.in(gids))
    }
    
    #warning("This function is not being used in the codebase")
    func aria2Bittorrent(_ gid: String) throws -> Aria2Bittorrent? {
        try aria2BittorrentTable.getObject(where: Aria2Bittorrent.Properties.id == Aria2Bittorrent.id(gid))
    }
    
    func aria2Files(_ gid: String) throws -> [Aria2File] {
        let fid = Aria2File.fid(gid)
        return try aria2FileTable.getObjects(where: Aria2File.Properties.id.like("\(fid)%"))
    }
    
    func activeCount() throws -> Int {
        try aria2ObjectTable.getColumn(
            on: Aria2Object.Properties.gid,
            where: Aria2Object.Properties.status.in([Status.active.rawValue]))
        .count
    }
    
    func activeBittorrentCount() throws -> Int {
        let gids = try aria2ObjectTable.getColumn(
            on: Aria2Object.Properties.gid,
            where: Aria2Object.Properties.status.in([Status.active.rawValue]))
        let bids = gids.compactMap(String.init).map(Aria2Bittorrent.id)
        
        return try aria2BittorrentTable.getColumn(
            on: Aria2Bittorrent.Properties.id,
            where: Aria2Bittorrent.Properties.id.in(bids)).count
    }
    
    
    
// MARK: - Database Modification
    
    func deleteAllAria2Objects() throws {
        try database.run(transaction: { _ in
            try self.aria2ObjectTable.delete()
            try self.aria2FileTable.delete()
            try self.aria2BittorrentTable.delete()
            try self.aria2UriTable.delete()
        })
        
        notifyRelatedTables(for: [], changeType: .reload)
    }
    
    func deleteMissingAria2Objects(_ gids: [String]) throws {
        let gids = try aria2ObjectTable.getColumn(on: Aria2Object.Properties.gid, where: Aria2Object.Properties.gid.notIn(gids)).compactMap(String.init)
        let bids = gids.map(Aria2Bittorrent.id)
        let fids = gids.map(Aria2File.fid)
        
        try database.run(transaction: { _ in
            try self.aria2ObjectTable.delete(where: Aria2Object.Properties.gid.in(gids))
            try self.aria2BittorrentTable.delete(where: Aria2Bittorrent.Properties.id.in(bids))
            try fids.forEach {
                try self.aria2FileTable.delete(where: Aria2File.Properties.id.like("\($0)%"))
            }
        })
        
        notifyRelatedTables(for: gids, changeType: .delete(gids))
    }
    
    func addMissingObjects(_ gids: [String]) {
        Task {
            do {
                let oldGids = try aria2ObjectTable.getColumn(on: Aria2Object.Properties.gid).compactMap(String.init)
                let missingGids = Array(Set(gids).subtracting(Set(oldGids)))
                guard missingGids.count > 0 else { return }
                try await Aria2.shared.reloadData(missingGids)
            } catch {
                await Aria2.shared.reloadAll.debounce()
            }
        }
    }
    
    func reloadAllObjects(_ objs: [Aria2Object]) throws {
        let gids = objs.compactMap({ $0.gid})
        try deleteMissingAria2Objects(gids)
        try insertAria2Objects(objs)
        
        notifyRelatedTables(for: [], changeType: .reload)
    }
    
    func reloadObjects(_ objs: [Aria2Object]) throws {
        let gids = objs.map { $0.gid }
        let updateGids = try aria2ObjectTable.getColumn(on: Aria2Object.Properties.gid, where: Aria2Object.Properties.gid.in(gids)).compactMap(String.init)
        let newGids = Array(Set(gids).subtracting(Set(updateGids)))
        
        try insertAria2Objects(objs)
        
        notifyRelatedTables(for: updateGids, changeType: .update([]))
        notifyRelatedTables(for: newGids, changeType: .insert([]))
    }
    
    private func insertAria2Objects(_ objs: [Aria2Object]) throws {
        try database.run(transaction: { _ in
            try self.aria2ObjectTable.insertOrReplace(objs)
            try objs.forEach {
                try self.aria2FileTable.insertOrReplace($0.files)
                if let b = $0.bittorrent {
                    try self.aria2BittorrentTable.insertOrReplace(b)
                }
            }
        })
    }
    
    func sortAllObjects(_ gidsDic: [[String: String]]) throws {
        let gids = gidsDic.compactMap({ $0["gid"]})
        try deleteMissingAria2Objects(gids)
        addMissingObjects(gids)
        
        try database.run(transaction: { _ in
            try gidsDic.forEach { dic in
                guard let gid = dic["gid"] else { return }
                try self.aria2ObjectTable.update(on: [
                    Aria2Object.Properties.status,
                    Aria2Object.Properties.sortDate
                ], with: [
                    dic["status"] ?? Status.error.rawValue,
                    Double(Date().timeIntervalSince1970)
                ], where: Aria2Object.Properties.gid == gid)
            }
        })
        
        notifyObservers(.init(tableName: .aria2Object, changeType: .update(gids)))
    }
    
    func updateStatus(_ results: [Aria2Status]) throws {
        let gids = results.map({ $0.gid })
        addMissingObjects(gids)
        
        try database.run(transaction: { _ in
            try results.forEach { s in
                try self.aria2ObjectTable.update(on: [
                    Aria2Object.Properties.status,
                    Aria2Object.Properties.totalLength,
                    Aria2Object.Properties.completedLength,
                    Aria2Object.Properties.uploadLength,
                    Aria2Object.Properties.downloadSpeed,
                    Aria2Object.Properties.uploadSpeed,
                    Aria2Object.Properties.connections,
                    Aria2Object.Properties.dir
                    
                    //                    Aria2Object.Properties.bittorrent
                ], with: [
                    s.status,
                    s.totalLength,
                    s.completedLength,
                    s.uploadLength,
                    s.downloadSpeed,
                    s.uploadSpeed,
                    Int64(s.connections),
                    s.dir
                ], where: Aria2Object.Properties.gid == s.gid)
            }
        })
        
        notifyObservers(.init(tableName: .aria2Object, changeType: .update(gids)))
    }
    
    func updateFiles(_ gid: String, files: [Aria2File]) throws {
        files.forEach {
            $0.id = Aria2File.id(gid, index: $0.index)
        }
        try aria2FileTable.insertOrReplace(files)
        let fid = Aria2File.fid(gid)
        notifyObservers(.init(tableName: .aria2File, changeType: .update([fid])))
    }
    
    
// MARK: - Log Management
    
    func getLogs() throws -> [Aria2Log] {
        try aria2LogTable.getObjects(orderBy: [Aria2Log.Properties.date.asOrder()])
    }
    
    func getLogs(_ ids: [String]) throws -> [Aria2Log] {
        try aria2LogTable.getObjects(where: Aria2Log.Properties.date.in(ids))
    }
    
    func insertLog(_ log: Aria2Log) throws {
        try aria2LogTable.insert([log])
        notifyObservers(.init(tableName: .aria2Log, changeType: .insert([log.date])))
    }
    
    func cleanUpExpiredLogs() throws {
        let oneDayAgo = Int(Date().timeIntervalSince1970) - 60 * 60 * 8
        try aria2LogTable.delete(where: Aria2Log.Properties.date < oneDayAgo)
        notifyObservers(.init(tableName: .aria2Log, changeType: .reload))
    }
    
    func clearAllLogs() throws {
        try aria2LogTable.delete()
        notifyObservers(.init(tableName: .aria2Log, changeType: .reload))
    }
    
// MARK: - Observer Management
    
    public func addObserver(_ observer: DatabaseChangeObserver, forTable tableName: DBTableNames? = nil) async {
        await observerManager.addObserver(observer, forTable: tableName)
    }
    
    #warning("This function is not being used in the codebase")
    public func removeObserver(_ observer: DatabaseChangeObserver) async {
        await observerManager.removeObserver(observer)
    }
    
    private func notifyObservers(_ notification: DatabaseChangeNotification) {
        Task { @MainActor in
            await observerManager.notifyObservers(notification)
        }
    }
    
    private func notifyObserversSync(_ notification: DatabaseChangeNotification) async {
        await observerManager.notifyObservers(notification)
    }
    
    private func notifyRelatedTables(for gids: [String], changeType: DatabaseChangeType) {
        let bids = gids.map(Aria2Bittorrent.id)
        let fids = gids.map(Aria2File.fid)
        
        let objectChangeType: DatabaseChangeType
        let bittorrentChangeType: DatabaseChangeType
        let fileChangeType: DatabaseChangeType
        
        switch changeType {
        case .insert where !gids.isEmpty:
            objectChangeType = .insert(gids)
            bittorrentChangeType = .insert(bids)
            fileChangeType = .insert(fids)
        case .update where !gids.isEmpty:
            objectChangeType = .update(gids)
            bittorrentChangeType = .update(bids)
            fileChangeType = .update(fids)
        case .delete where !gids.isEmpty:
            objectChangeType = .delete(gids)
            bittorrentChangeType = .delete(bids)
            fileChangeType = .delete(fids)
        case .reload:
            objectChangeType = .reload
            bittorrentChangeType = .reload
            fileChangeType = .reload
        default:
            return
        }
        notifyObservers(.init(tableName: .aria2Object, changeType: objectChangeType))
        notifyObservers(.init(tableName: .aria2Bittorrent, changeType: bittorrentChangeType))
        notifyObservers(.init(tableName: .aria2File, changeType: fileChangeType))
    }
}

private actor ObserverManager {
    private var globalObservers: [ObjectIdentifier: any DatabaseChangeObserver] = [:]
    private var tableObservers: [DBTableNames: [ObjectIdentifier: any DatabaseChangeObserver]] = [:]
    
    func addObserver(_ observer: any DatabaseChangeObserver, forTable tableName: DBTableNames? = nil) {
        let id = ObjectIdentifier(observer as AnyObject)
        if let tableName = tableName {
            if tableObservers[tableName] == nil {
                tableObservers[tableName] = [:]
            }
            tableObservers[tableName]?[id] = observer
        } else {
            globalObservers[id] = observer
        }
    }
    
    func removeObserver(_ observer: any DatabaseChangeObserver) {
        let id = ObjectIdentifier(observer as AnyObject)
        globalObservers.removeValue(forKey: id)
        for tableName in tableObservers.keys {
            tableObservers[tableName]?.removeValue(forKey: id)
            if tableObservers[tableName]?.isEmpty == true {
                tableObservers.removeValue(forKey: tableName)
            }
        }
    }
    
    func notifyObservers(_ notification: DatabaseChangeNotification) async {
        await withTaskGroup(of: Void.self) { group in
            // Notify global observers
            for observer in globalObservers.values {
                group.addTask {
                    await observer.databaseDidChange(notification: notification)
                }
            }
            
            if let observers = tableObservers[notification.tableName] {
                for observer in observers.values {
                    group.addTask {
                        await observer.databaseDidChange(notification: notification)
                    }
                }
            }
            
            await group.waitForAll()
        }
    }
}
