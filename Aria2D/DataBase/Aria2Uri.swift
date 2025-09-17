//
//  Aria2Uri.swift
//  Aria2D
//
//  Created by Copilot on 2025/05/27.
//  Copyright © 2025 xjbeta. All rights reserved.
//

import Foundation
import WCDBSwift

@objc(Aria2Uri)
final class Aria2Uri: NSObject, TableCodable {
    
    var status: String
    var uri: String
    var id: String
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Aria2Uri

        case status,
             uri,
             id
        
        nonisolated(unsafe) static let objectRelationalMapping = TableBinding(CodingKeys.self)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        uri = try values.decodeIfPresent(String.self, forKey: .uri) ?? ""
        let _ = try? values.decodeIfPresent(String.self, forKey: .id)
        id = ""
    }
}
