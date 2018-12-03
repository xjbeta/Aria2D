//
//  Aria2Object+CoreDataClass.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData


@objc(Aria2Object)
public class Aria2Object: NSManagedObject, Decodable {

    var waitTimer: WaitTimer?
    var timerLimit = 0
    
    @objc dynamic var name: String {
        if let name = bittorrent?.name,
            name != "" {
            return name
        } else if let files = files?.allObjects as? [Aria2File],
            files.count == 1, let path = files.first?.path, path != "" {
            return URL(fileURLWithPath: path).lastPathComponent
        } else {
            if waitTimer == nil {
                Log("Init file name timer for \(gid)")
                waitTimer = WaitTimer(timeOut: .seconds(1)) { [weak self] in
                    guard let name = self?.name,
                        let downloadSpeed = self?.downloadSpeed,
                        let gid = self?.gid else { return }
                    Log("Update file name for \(gid)")
                    if name != "unknown" || self?.timerLimit == 5 {
                        self?.waitTimer?.stop()
                        self?.waitTimer = nil
                    } else if downloadSpeed > 0,
                        name == "unknown" {
                        Aria2.shared.getFiles(gid)
                        self?.timerLimit += 1
                    }
                }
                waitTimer?.run()
            }
            return "unknown"
        }
    }
    
    @objc dynamic var icon: NSImage {
        var image = NSImage()
        if let files = files,
            files.count > 1 || bittorrent?.mode == Aria2Bittorrent.FileMode.multi.rawValue {
            image = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
        } else {
            image = NSWorkspace.shared.icon(forFileType: URL(fileURLWithPath: name).pathExtension)
        }
        return image
    }
    
    @objc dynamic var fileSize: String {
        return totalLength.ByteFileFormatter()
    }
    
    @objc dynamic var fileSizeForInfo: String {
        return "\(completedLength.ByteFileFormatter()) / \(totalLength.ByteFileFormatter())"
    }
    
    @objc dynamic var progressValue: Double {
        if totalLength == 0 {
            return 0
        } else {
            return Double(completedLength) / Double(totalLength) * 100
        }
    }
    
    @objc dynamic var remainingTime: String {
        if status == Status.active.rawValue {
            return timeFormat(totalLength - completedLength, speed: downloadSpeed)
        } else {
            return ""
        }
    }
    
    @objc dynamic var percentage: String {
        if status != Status.complete.rawValue, totalLength != 0 {
            return progressValue.percentageFormat()
        } else if status == Status.active.rawValue, totalLength == 0 || completedLength == 0 {
            return 0.percentageFormat()
        } else {
            return ""
        }
    }
    
    @objc dynamic var shouldHideProgress: Bool {
        if status != Status.complete.rawValue, totalLength != 0 {
            return false
        } else if status == Status.active.rawValue, totalLength == 0 || completedLength == 0 {
            return false
        } else {
            return true
        }
    }
    
    @objc dynamic var statusValue: String {
        if status == Status.active.rawValue {
            if bittorrent != nil, totalLength == completedLength, totalLength != 0 {
                return "⬆︎ \(uploadSpeed.ByteFileFormatter())/s"
            } else {
                return "\(downloadSpeed.ByteFileFormatter())/s"
            }
        } else {
            return Status(raw: status)?.string() ?? ""
        }
    }
    
    // MARK : Info View
    @objc dynamic var downloadSpeedForInfo: String {
        guard let s = Status(raw: status) else { return "" }
        switch s {
        case .active:
            return "⬇︎ \(downloadSpeed.ByteFileFormatter())/s"
        case .complete, .waiting, .paused, .error, .removed:
            return s.string()
        }
    }
    
    @objc dynamic var uploadSpeedForInfo: String {
        guard let s = Status(raw: status) else { return "" }
        switch s {
        case .active:
            return bittorrent == nil ? "" : "⬆︎ \(uploadSpeed.ByteFileFormatter())/s"
        case .complete, .waiting, .paused, .error, .removed:
            return ""
        }
    }
    
    @objc dynamic var statusStr: String {
        guard let s = Status(raw: status) else { return "" }
        return s.string()
    }
    
    @objc dynamic var hideErrorInfo: Bool {
        return errorCode == 0
    }
    
    func path() -> URL? {
        if let name = bittorrent?.name, let dir = dir, dir != "", name != "" {
            return URL(fileURLWithPath: dir).appendingPathComponent(name)
        }
        if let files = files?.allObjects as? [Aria2File],
            files.count == 1, let path = files.first?.path, path != "" {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    
    var filesObserve: (([Int], Bool) -> Void)?
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        switch key {
        case "hideErrorInfo":
            return Set(["errorCode"])
        case "statusStr":
            return Set(["status"])
        case "name", "icon" :
            return Set(["bittorrent", "files"])
        case "fileSize":
            return Set(["totalLength"])
        case "downloadSpeedForInfo":
            return Set(["status", "downloadSpeed"])
        case "uploadSpeedForInfo":
            return Set(["status", "uploadSpeed", "bittorrent"])
        case "progressValue", "fileSizeForInfo":
            return Set(["completedLength", "totalLength"])
        case "remainingTime", "percentage", "hidePercentage":
            return Set(["totalLength", "completedLength", "downloadSpeed", "status"])
        default :
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case files,
        gid,
        status,
        totalLength,
        completedLength,
        uploadLength,
        downloadSpeed,
        uploadSpeed,
        pieceLength,
        connections,
        dir,
        bittorrent,
        bitfield,
        numPieces,
        errorCode,
        errorMessage
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Aria2Object", in: context)  else {
            fatalError("Failed to decode Core Data object")
        }
        self.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gid = try values.decode(String.self, forKey: .gid)
        let s = Status(try values.decode(String.self, forKey: .status)) ?? .error
        status = s.rawValue
        totalLength = Int64(try values.decode(String.self, forKey: .totalLength)) ?? 0
        completedLength = Int64(try values.decode(String.self, forKey: .completedLength)) ?? 0
        uploadLength = Int64(try values.decode(String.self, forKey: .uploadLength)) ?? 0
        downloadSpeed = Int64(try values.decode(String.self, forKey: .downloadSpeed)) ?? 0
        uploadSpeed = Int64(try values.decode(String.self, forKey: .uploadSpeed)) ?? 0
        pieceLength = Int64(try values.decode(String.self, forKey: .pieceLength)) ?? 0
        connections = Int64(try values.decode(String.self, forKey: .connections)) ?? 0
        dir = (try values.decode(String.self, forKey: .dir)).standardizingPath
        bitfield = try values.decodeIfPresent(String.self, forKey: .bitfield) ?? ""
        numPieces = try values.decode(String.self, forKey: .numPieces)
        errorCode = Int16(try values.decodeIfPresent(String.self, forKey: .errorCode) ?? "") ?? 0
        errorMessage = try values.decodeIfPresent(String.self, forKey: .errorMessage) ?? ""
        
//        list = DataManager.shared.aria2List
        let b = try values.decodeIfPresent(Aria2Bittorrent.self, forKey: .bittorrent)
        b?.id = gid + "-bittorrent"
        b?.object = self
        bittorrent = b

        let f = try values.decodeIfPresent([Aria2File].self, forKey: .files) ?? []
        f.forEach {
            $0.id = gid + "-files-\($0.index)"
            $0.object = self
        }
        files = NSSet(array: f)
        
        sortValue = Double(Date().timeIntervalSince1970)
    }
    
    func update(with obj: Aria2Object, context: NSManagedObjectContext) {
        belongsTo = obj.belongsTo
        bitfield = obj.bitfield
        completedLength = obj.completedLength
        connections = obj.connections
        dir = obj.dir
        downloadSpeed = obj.downloadSpeed
        errorCode = obj.errorCode
        errorMessage = obj.errorMessage
        followedBy = obj.followedBy
        following = obj.following
        infoHash = obj.infoHash
        numPieces = obj.numPieces
        numSeeders = obj.numSeeders
        pieceLength = obj.pieceLength
        seeder = obj.seeder
        status = obj.status
        totalLength = obj.totalLength
        uploadLength = obj.uploadLength
        uploadSpeed = obj.uploadSpeed
        verifiedLength = obj.verifiedLength
        verifyIntegrityPending = obj.verifyIntegrityPending
        
        sortValue = obj.sortValue
        
        updateBittorrent(obj.bittorrent, context: context)
        
        if let newFiles = obj.files?.allObjects as? [Aria2File] {
            updateFiles(with: newFiles, context: context)
        }
    }
    
    func updateFiles(with newFiles: [Aria2File], context: NSManagedObjectContext) {
        var updatedIndexs: [Int] = []
        var shouldReload = false
        
        if let files = files?.allObjects as? [Aria2File] {
            let newIds = newFiles.map({ $0.id })
            let oldIds = files.map({ $0.id })
            
            let deleteFiles = files.filter {
                !newIds.contains($0.id)
            }
            
            deleteFiles.forEach {
                context.delete($0)
                shouldReload = true
            }
            
            newFiles.forEach { newFile in
                guard oldIds.contains(newFile.id),
                    let file = files.filter({ $0.id == newFile.id }).first else {
                        context.insert(newFile)
                        newFile.object = self
                        shouldReload = true
                        return
                }
                
                
                if newFile.path != file.path ||
                    newFile.length != file.length ||
                    newFile.completedLength != file.completedLength ||
                    newFile.selected != file.selected {
                    file.update(with: newFile)
                    
                    updatedIndexs.append(Int(file.index))
                }
            }
            
            filesObserve?(updatedIndexs, shouldReload)
        }
    }
    
    func updateBittorrent(_ new: Aria2Bittorrent?, context: NSManagedObjectContext) {
        if bittorrent == nil, new != nil {
            context.insert(new!)
            new!.object = self
        } else if bittorrent != nil, new == nil {
            context.delete(bittorrent!)
        } else {
            bittorrent?.update(with: new)
        }
    }
    
    func update(with status: Aria2Status) {
        if self.status != status.status.rawValue {
            self.status = status.status.rawValue
        }
        totalLength = status.totalLength
        completedLength = status.completedLength
        uploadLength = status.uploadLength
        downloadSpeed = status.downloadSpeed
        uploadSpeed = status.uploadSpeed
        connections = Int64(status.connections)
        dir = status.dir
        bittorrent?.update(with: status.bittorrent)
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
}
