//
//  Aria2Uri+CoreDataProperties.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData


extension Aria2Uri {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aria2Uri> {
        return NSFetchRequest<Aria2Uri>(entityName: "Aria2Uri")
    }

    @NSManaged public var status: String?
    @NSManaged public var uri: String?
    @NSManaged public var id: String?
    @NSManaged public var file: Aria2File?

}
