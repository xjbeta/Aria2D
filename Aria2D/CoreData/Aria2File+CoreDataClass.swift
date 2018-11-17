//
//  Aria2File+CoreDataClass.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Aria2File)
public class Aria2File: NSManagedObject, Decodable {

    private enum CodingKeys: String, CodingKey {
        case index,
        path,
        length,
        completedLength,
        selected,
        uris
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let managedObjectContext = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Aria2File", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        index = Int64(try values.decode(String.self, forKey: .index)) ?? -1
        path = try values.decode(String.self, forKey: .path).standardizingPath
        length = Int64(try values.decode(String.self, forKey: .length)) ?? 0
        completedLength = Int64(try values.decode(String.self, forKey: .completedLength)) ?? 0
        selected = try values.decode(String.self, forKey: .selected) == "true"
//        uris = try values.decode([Aria2Uri].self, forKey: .uris)
//            .map { $0.uri }
    }
}
