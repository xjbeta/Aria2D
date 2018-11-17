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

    @objc dynamic var name: String {
        if let name = bittorrent?.name,
            name != "" {
            return name
        } else if let files = files?.allObjects as? [Aria2File],
            files.count == 1, let path = files.first?.path, path != "" {
            return URL(fileURLWithPath: path).lastPathComponent
        } else {
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
    
    @objc dynamic var statusList: [StatusObject] {
        var list = [StatusObject(.gid, value: gid),
//                           StatusObject(.bitfield, value: obj.bitfield),
                    StatusObject(.status, value: Status(raw: status)?.string()),
                    StatusObject(.connections, value: "\(connections)"),
                    StatusObject(.numPieces, value: numPieces),
                    StatusObject(.pieceLength, value: pieceLength.ByteFileFormatter()),
                    StatusObject(.space, value: ""),
                    StatusObject(.totalLength, value: totalLength.ByteFileFormatter()),
                    StatusObject(.completedLength, value: completedLength.ByteFileFormatter()),
                    StatusObject(.uploadLength, value: uploadLength.ByteFileFormatter())]
        
        if errorCode != 0 {
            list.append(contentsOf: [
                StatusObject(.space, value: ""),
                StatusObject(.errorCode, value: "\(errorCode)"),
                StatusObject(.errorMessage, value: errorMessage)])
        }
        return list
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
    
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        switch key {
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
        case "statusList":
            return Set(["gid", "status", "connections", "numPieces", "pieceLength", "totalLength", "completedLength", "uploadLength", "errorCode", "errorMessage"])
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
        guard let managedObjectContext = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Aria2Object", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.init(entity: entity, insertInto: managedObjectContext)
        
        
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
        
        list = DataManager.shared.aria2List
        if let gid = gid {
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
        }
        
        sortValue = Double(Date().timeIntervalSince1970)
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
