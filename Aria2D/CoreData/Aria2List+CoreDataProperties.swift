//
//  Aria2List+CoreDataProperties.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData


extension Aria2List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aria2List> {
        return NSFetchRequest<Aria2List>(entityName: "Aria2List")
    }

    @NSManaged public var objects: NSOrderedSet?

}

// MARK: Generated accessors for objects
extension Aria2List {

    @objc(insertObject:inObjectsAtIndex:)
    @NSManaged public func insertIntoObjects(_ value: Aria2Object, at idx: Int)

    @objc(removeObjectFromObjectsAtIndex:)
    @NSManaged public func removeFromObjects(at idx: Int)

    @objc(insertObjects:atIndexes:)
    @NSManaged public func insertIntoObjects(_ values: [Aria2Object], at indexes: NSIndexSet)

    @objc(removeObjectsAtIndexes:)
    @NSManaged public func removeFromObjects(at indexes: NSIndexSet)

    @objc(replaceObjectInObjectsAtIndex:withObject:)
    @NSManaged public func replaceObjects(at idx: Int, with value: Aria2Object)

    @objc(replaceObjectsAtIndexes:withObjects:)
    @NSManaged public func replaceObjects(at indexes: NSIndexSet, with values: [Aria2Object])

    @objc(addObjectsObject:)
    @NSManaged public func addToObjects(_ value: Aria2Object)

    @objc(removeObjectsObject:)
    @NSManaged public func removeFromObjects(_ value: Aria2Object)

    @objc(addObjects:)
    @NSManaged public func addToObjects(_ values: NSOrderedSet)

    @objc(removeObjects:)
    @NSManaged public func removeFromObjects(_ values: NSOrderedSet)

}
