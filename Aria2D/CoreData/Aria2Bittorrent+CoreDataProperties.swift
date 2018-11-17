//
//  Aria2Bittorrent+CoreDataProperties.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData


extension Aria2Bittorrent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aria2Bittorrent> {
        return NSFetchRequest<Aria2Bittorrent>(entityName: "Aria2Bittorrent")
    }

    @NSManaged public var announceList: [String]?
    @NSManaged public var comment: String?
    @NSManaged public var creationDate: Int64
    @NSManaged public var mode: Int16
    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var object: Aria2Object?

}
