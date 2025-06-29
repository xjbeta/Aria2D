//
//  Aria2Bittorrent.swift
//  Aria2D
//
//  Created by Copilot on 2025/05/27.
//  Copyright © 2025 xjbeta. All rights reserved.
//

import Foundation
import WCDBSwift

@objc(Aria2Bittorrent)
final class Aria2Bittorrent: NSObject, TableCodable, ColumnJSONCodable {
    // Enum for file mode
    enum FileMode: Int16, CaseIterable {
        case multi = 0
        case single = 1
        case error = 2
        
        init?(_ str: String) {
            switch str {
            case "multi": self = .multi
            case "single": self = .single
            default: self = .error
            }
        }
    }
    
    var name: String
    var mode: Int16
    @objc dynamic var announceList: [String]
    var comment: String
    var creationDate: Int64
    var id: String
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Aria2Bittorrent
        
        case name = "info",
             mode,
             announceList,
             comment,
             creationDate,
             id
        
        nonisolated(unsafe) static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(id, isPrimary: true, onConflict: .Replace)
        }
    }
    
    // Decodable initializer
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = (try values.decodeIfPresent([String: String].self, forKey: .name))?["name"] ?? ""

        if let str = try values.decodeIfPresent(String.self, forKey: .mode) {
            let m = FileMode(str) ?? .error
            mode = m.rawValue
        } else {
            mode = 2
        }
        if let str = try values.decodeIfPresent([[String]].self, forKey: .announceList) {
            announceList = str.flatMap { $0 }
        } else {
            announceList = []
        }
        
        comment = try values.decodeIfPresent(String.self, forKey: .comment) ?? ""
        creationDate = Int64(try values.decodeIfPresent(Int.self, forKey: .creationDate) ?? 0)
        
        let _ = try? values.decodeIfPresent(String.self, forKey: .id)
        id = ""
    }
    
    static func id(_ gid: String) -> String {
        gid + "-bittorrent"
    }
    
    // Update method
    func update(with bittorrent: Aria2Bittorrent?) {
        guard let bittorrent = bittorrent else { return }
        announceList = bittorrent.announceList
        name = bittorrent.name
        mode = bittorrent.mode
    }
}
