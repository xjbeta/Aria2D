//
//  WebSocketLog+CoreDataClass.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/17.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData

@objc(WebSocketLog)
public class WebSocketLog: NSManagedObject {

    @objc dynamic var time: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
    }
    
}
