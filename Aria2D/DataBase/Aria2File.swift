//
//  Aria2File.swift
//  Aria2D
//
//  Created by Copilot on 2025/05/27.
//  Copyright © 2025 xjbeta. All rights reserved.
//

import Foundation
import WCDBSwift

@objc(Aria2File)
final class Aria2File: NSObject, TableCodable {
    @objc dynamic var completedLength: Int64
    @objc dynamic var index: Int64
    @objc dynamic var length: Int64
    @objc dynamic var path: String
    @objc dynamic var selected: Bool
    @objc dynamic var id: String
    
    var uris: [Aria2Uri] = []
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Aria2File
        
        case index = "db_index",
             path,
             length,
             completedLength,
             selected,
             id
        
        nonisolated(unsafe) static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(id, isPrimary: true, onConflict: .Replace)
        }
    }
   
    enum SubCodingKeys: String, CodingKey {
        case uris,
        index
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let _ = try values.decodeIfPresent(String.self, forKey: .index)
        path = (try values.decode(String.self, forKey: .path)).standardizingPath
        length = Int64(try values.decode(String.self, forKey: .length)) ?? 0
        completedLength = Int64(try values.decode(String.self, forKey: .completedLength)) ?? 0
        
        
        if let id = try? values.decodeIfPresent(String.self, forKey: .id) {
            self.id = id
            index = try values.decode(Int64.self, forKey: .index)
            selected = try values.decode(Bool.self, forKey: .selected)
        } else {
            let subValues = try decoder.container(keyedBy: SubCodingKeys.self)
            index = Int64(try subValues.decode(String.self, forKey: .index)) ?? -1
            self.id = ""
            selected = try values.decode(String.self, forKey: .selected) == "true"
        }
        
        
        // uris = try values.decode([Aria2Uri].self, forKey: .uris)
//            .map { $0.uri }
    }
    
    static func fid(_ gid: String) -> String {
        gid + "-files"
    }
    
    static func id(_ gid: String, index: Int64) -> String {
        Aria2File.fid(gid) + "-\(index)"
    }
    
    func update(_ file: Aria2File) {
        guard file.id == id, file.index == index else { return }
        
        CodingKeys.all.forEach {
            let key = $0.name
            guard ![CodingKeys.id.rawValue, CodingKeys.index.rawValue].contains(key) else { return }
            
            let new = file.value(forKey: key)
            if value(forKey: key) == new {
                
            } else {
                setValue(new, forKey: key)
            }
        }
    }
}
