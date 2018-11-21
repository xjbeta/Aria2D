//
//  Aria2Bittorrent+CoreDataClass.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Aria2Bittorrent)
public class Aria2Bittorrent: NSManagedObject, Decodable {
    
    enum FileMode: Int16, Decodable {
        case multi, single, error
        init?(_ str: String) {
            switch str {
            case "multi": self.init(rawValue: 0)
            case "single": self.init(rawValue: 1)
            default:
                self.init(rawValue: 2)
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case name = "info",
        mode,
        announceList
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Aria2Bittorrent", in: context)  else {
                fatalError("Failed to decode Core Data object")
        }
        self.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let dic = try values.decodeIfPresent([String: String].self, forKey: .name) {
            name = dic["name"]
        }
        if let str = try values.decodeIfPresent(String.self, forKey: .mode) {
            let m = FileMode(str) ?? .error
            mode = m.rawValue
        }
        if let str = try values.decodeIfPresent([[String]].self, forKey: .announceList) {
            announceList = str.flatMap { $0 }
        }
    }
    
    func update(with bittorrent: Aria2Bittorrent?) {
        guard let bittorrent = bittorrent else { return }
        announceList = bittorrent.announceList
        name = bittorrent.name
        mode = bittorrent.mode
    }
}
