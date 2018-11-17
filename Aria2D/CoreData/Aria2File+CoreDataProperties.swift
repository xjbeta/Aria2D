//
//  Aria2File+CoreDataProperties.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData


extension Aria2File {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aria2File> {
        return NSFetchRequest<Aria2File>(entityName: "Aria2File")
    }

    @NSManaged public var completedLength: Int64
    @NSManaged public var id: String?
    @NSManaged public var index: Int64
    @NSManaged public var length: Int64
    @NSManaged public var path: String?
    @NSManaged public var selected: Bool
    @NSManaged public var object: Aria2Object?
    @NSManaged public var uris: NSSet?

}

// MARK: Generated accessors for uris
extension Aria2File {

    @objc(addUrisObject:)
    @NSManaged public func addToUris(_ value: Aria2Uri)

    @objc(removeUrisObject:)
    @NSManaged public func removeFromUris(_ value: Aria2Uri)

    @objc(addUris:)
    @NSManaged public func addToUris(_ values: NSSet)

    @objc(removeUris:)
    @NSManaged public func removeFromUris(_ values: NSSet)

}
