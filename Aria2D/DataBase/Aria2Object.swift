//
//  Aria2Object+CoreDataClass.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import Cocoa
import WCDBSwift

@objc(Aria2Object)
final class Aria2Object: NSObject, TableCodable {

    @objc dynamic var gid: String
    @objc dynamic var status: String
    
    @objc dynamic var totalLength: Int64
    @objc dynamic var completedLength: Int64
    @objc dynamic var uploadLength: Int64
    @objc dynamic var downloadSpeed: Int64
    @objc dynamic var uploadSpeed: Int64
    @objc dynamic var pieceLength: Int64
    
    @objc dynamic var connections: Int64
    @objc dynamic var dir: String
    @objc dynamic var bitfield: String
    @objc dynamic var numPieces: String
    @objc dynamic var errorCode: Int16
    @objc dynamic var errorMessage: String
    
    @objc dynamic var sortDate: Date
    @objc dynamic var name: String
    @objc dynamic var useFolderIcon: Bool
    
    // Non-CodingKeys properties
    var belongsTo: String
    var followedBy: String
    var following: String
    var infoHash: String
    var numSeeders: String
    var seeder: Bool
    var verifiedLength: String
    var verifyIntegrityPending: String
    
    @objc dynamic var bittorrent: Aria2Bittorrent?
    @objc dynamic var files: [Aria2File] = []
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Aria2Object

        case gid,
             status,
             totalLength,
             completedLength,
             uploadLength,
             downloadSpeed,
             uploadSpeed,
             pieceLength,
             connections,
             dir,
             bitfield,
             numPieces,
             errorCode,
             errorMessage,
             sortDate,
             name,
             useFolderIcon
        
        nonisolated(unsafe) static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(gid, isPrimary: true, onConflict: .Replace)
        }
        
    }
    
    enum SubCodingKeys: String, CodingKey {
        case files,
             bittorrent
    }
    
    
    @objc dynamic var icon: NSImage {
        if useFolderIcon {
            NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
        } else {
            NSWorkspace.shared.icon(forFileType: URL(fileURLWithPath: name).pathExtension)
        }
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
        guard let s = Status(rawValue: status) else { return status }
        
        switch s {
        case .active:
            if bittorrent != nil, totalLength == completedLength, totalLength != 0 {
                return "⬆︎ \(uploadSpeed.ByteFileFormatter())/s"
            } else {
                return "\(downloadSpeed.ByteFileFormatter())/s"
            }
        default:
            return status
        }
    }
    
    // MARK : Info View
    @objc dynamic var downloadSpeedForInfo: String {
        guard let s = Status(rawValue: status) else { return "" }
        switch s {
        case .active:
            return "⬇︎ \(downloadSpeed.ByteFileFormatter())/s"
        case .complete, .waiting, .paused, .error, .removed:
            return s.rawValue
        }
    }
    
    @objc dynamic var uploadSpeedForInfo: String {
        guard let s = Status(rawValue: status) else { return "" }
        switch s {
        case .active:
            return bittorrent == nil ? "" : "⬆︎ \(uploadSpeed.ByteFileFormatter())/s"
        case .complete, .waiting, .paused, .error, .removed:
            return ""
        }
    }
    
    @objc dynamic var hideErrorInfo: Bool {
        return errorCode == 0
    }
    
    @MainActor
    func path() -> URL? {
        if let bittorrent = try? DataManager.shared.aria2Bittorrent(gid),
           dir != "",
           bittorrent.name != "" {
            return URL(fileURLWithPath: dir).appendingPathComponent(bittorrent.name)
        }
        
        if let files = try? DataManager.shared.aria2Files(gid),
           files.count == 1,
           let path = files.first?.path,
           path != "" {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        switch key {
        case "hideErrorInfo":
            return Set(["errorCode"])
        case "statusValue":
            return Set(["status", "bittorrent", "completedLength", "totalLength", "downloadSpeed", "uploadSpeed"])
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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gid = try values.decode(String.self, forKey: .gid)
        status = try values.decode(String.self, forKey: .status)
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
        
        // Initialize non-CodingKeys properties
        belongsTo = ""
        followedBy = ""
        following = ""
        infoHash = ""
        numSeeders = ""
        seeder = false
        verifiedLength = ""
        verifyIntegrityPending = ""
        
        
        useFolderIcon = (try? values.decodeIfPresent(Bool.self, forKey: .useFolderIcon)) ?? false
        name = (try? values.decodeIfPresent(String.self, forKey: .name)) ?? ""
        
        if let date = try? values.decodeIfPresent(Date.self, forKey: .sortDate) {
            sortDate = date
            bittorrent = nil
            files = []
            return
        } else {
            sortDate = Date()
        }
        
        let subValues = try decoder.container(keyedBy: SubCodingKeys.self)
        
        if let bittorrent = try subValues.decodeIfPresent(Aria2Bittorrent.self, forKey: .bittorrent) {
            bittorrent.id = Aria2Bittorrent.id(gid)
            self.bittorrent = bittorrent
        }
        
        if let files = try subValues.decodeIfPresent([Aria2File].self, forKey: .files) {
            let gid = self.gid
            files.forEach {
                $0.id = Aria2File.id(gid, index: $0.index)
            }
            self.files = files
        }
        
        if let n = bittorrent?.name,
            n != "" {
            name = n
        } else if files.count == 1, let path = files.first?.path, path != "" {
            name = URL(fileURLWithPath: path).lastPathComponent
        } else {
            #warning("name from uris")
            name = "unknown"
        }
        
        useFolderIcon = files.count > 1 || bittorrent?.mode == Aria2Bittorrent.FileMode.multi.rawValue
    }
    
    func update(_ obj: Aria2Object) {
        guard obj.gid == gid else { return }
        CodingKeys.all.forEach {
            let key = $0.name
            let new = obj.value(forKey: key)
            guard key != CodingKeys.gid.rawValue else { return }
            if value(forKey: key) == new {
                
            } else {
                setValue(new, forKey: key)
            }
        }
    }
    
    @MainActor
    func updateUnknownTaskName() {
        guard name == "unknown", status == Status.active.rawValue else { return }
        Task {
            let _ = try await Aria2.shared.reloadData([gid])
        }
    }
    
    
    func timeFormat(_ length: Int64, speed: Int64) -> String {
        if speed == 0 || length <= 0 { return "INF" }
        
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
