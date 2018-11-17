//
//  Aria2Object+CoreDataProperties.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData


extension Aria2Object {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aria2Object> {
        return NSFetchRequest<Aria2Object>(entityName: "Aria2Object")
    }

    @NSManaged public var belongsTo: String?
    @NSManaged public var bitfield: String?
    @NSManaged public var completedLength: Int64
    @NSManaged public var connections: Int64
    @NSManaged public var dir: String?
    @NSManaged public var downloadSpeed: Int64
    @NSManaged public var errorCode: Int16
    @NSManaged public var errorMessage: String?
    @NSManaged public var followedBy: String?
    @NSManaged public var following: String?
    @NSManaged public var gid: String?
    @NSManaged public var infoHash: String?
    @NSManaged public var numPieces: String?
    @NSManaged public var numSeeders: String?
    @NSManaged public var pieceLength: Int64
    @NSManaged public var seeder: Bool
    @NSManaged public var status: Int16
    @NSManaged public var totalLength: Int64
    @NSManaged public var uploadLength: Int64
    @NSManaged public var uploadSpeed: Int64
    @NSManaged public var verifiedLength: String?
    @NSManaged public var verifyIntegrityPending: String?
    @NSManaged public var bittorrent: Aria2Bittorrent?
    @NSManaged public var files: NSSet?
    @NSManaged public var list: Aria2List?
    @NSManaged public var sortValue: Double
    

}

// MARK: Generated accessors for files
extension Aria2Object {

    @objc(addFilesObject:)
    @NSManaged public func addToFiles(_ value: Aria2File)

    @objc(removeFilesObject:)
    @NSManaged public func removeFromFiles(_ value: Aria2File)

    @objc(addFiles:)
    @NSManaged public func addToFiles(_ values: NSSet)

    @objc(removeFiles:)
    @NSManaged public func removeFromFiles(_ values: NSSet)

}
