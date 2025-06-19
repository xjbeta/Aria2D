//
//  Aria2Log.swift
//  Aria2D
//
//  Created by xjbeta on 2018/11/17.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Foundation
import WCDBSwift

@objc(Aria2Log)
final class Aria2Log: NSObject, TableCodable {
    
    @objc var date: String
    @objc var method: String
    @objc var success: Bool
    @objc var sendJSON: String
    @objc var receivedJSON: String
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Aria2Log
        
        case date,
             method,
             success,
             sendJSON,
             receivedJSON
        
        nonisolated(unsafe) static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(date, isPrimary: true)
        }
    }
    
// MARK: - Initializers
    
    init(date: Double = Date().timeIntervalSince1970, 
         method: String, 
         success: Bool, 
         sendJSON: String, 
         receivedJSON: String) {
        self.date = "\(date)"
        self.method = method
        self.success = success
        self.sendJSON = sendJSON
        self.receivedJSON = receivedJSON
        super.init()
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decodeIfPresent(String.self, forKey: .date) ?? ""
        method = try values.decodeIfPresent(String.self, forKey: .method) ?? ""
        success = try values.decodeIfPresent(Bool.self, forKey: .success) ?? false
        sendJSON = try values.decodeIfPresent(String.self, forKey: .sendJSON) ?? ""
        receivedJSON = try values.decodeIfPresent(String.self, forKey: .receivedJSON) ?? ""
    }

    @objc dynamic var time: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        guard let time = TimeInterval(date) else { return "" }
        return formatter.string(from: Date(timeIntervalSince1970: time))
    }
    
}
