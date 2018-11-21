//
//  WebSocketLog+CoreDataProperties.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/17.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData


extension WebSocketLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WebSocketLog> {
        return NSFetchRequest<WebSocketLog>(entityName: "WebSocketLog")
    }

    @NSManaged public var date: Double
    @NSManaged public var method: String?
    @NSManaged public var success: Bool
    @NSManaged public var sendJSON: String?
    @NSManaged public var receivedJSON: String?

}
