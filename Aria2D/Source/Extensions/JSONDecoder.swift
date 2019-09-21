//
//  JSONDecoder.swift
//  Aria2D
//
//  Created by xjbeta on 2017/7/27.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation
import CoreData

extension Data {
	func decode<T>(_ type: T.Type,
//	               from data: Data,
	_ methodName: String = #function) -> T? where T: Decodable {
		do {
			let re = try JSONDecoder().decode(T.self, from: self)
			return re
		} catch let error {
			Log(methodName)
			Log(error)
            
            Log(String(data: Aria2Websocket.shared.clearUrls(String(data: self, encoding: .utf8) ?? "") ?? Data() , encoding: .utf8))
			return nil
		}
	}
}


extension CodingUserInfoKey {
    /// Required. Must be an NSManagedObjectContext.
    static let context = CodingUserInfoKey(rawValue: "context")!
    /// Optional. Boolean. If present and true, newly created objects are not inserted into the context.
    static let deferInsertion = CodingUserInfoKey(rawValue: "deferInsertion")!
}

protocol MODecoder: class {
    var userInfo: [CodingUserInfoKey : Any] { get  set }
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
    func decode<T: Decodable>(_ type: T.Type, data: Data, in context: NSManagedObjectContext, deferInsertion: Bool) throws -> T
}

extension JSONDecoder: MODecoder { }
extension PropertyListDecoder: MODecoder {}

extension MODecoder {
    func decode<T: Decodable>(_ type: T.Type, data: Data, in context: NSManagedObjectContext, deferInsertion: Bool = false) throws -> T {
        
        userInfo[.context] = context
        userInfo[.deferInsertion] = deferInsertion
        defer {
            userInfo[.context] = nil
            userInfo[.deferInsertion] = nil
        }
        return try self.decode(type, from: data)
    }
}
