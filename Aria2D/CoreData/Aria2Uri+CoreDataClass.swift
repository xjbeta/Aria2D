//
//  Aria2Uri+CoreDataClass.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Aria2Uri)
public class Aria2Uri: NSManagedObject, Decodable {
    private enum CodingKeys: String, CodingKey {
        case status,
        uri
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("Failed to decode Core Data object")
        }
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.init(context: context)

        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decode(String.self, forKey: .status)
        uri = try values.decode(String.self, forKey: .uri)
    }

}
