//
//  DatabaseObserver.swift
//  Aria2D
//
//  Created by xjbeta on 2025/5/31.
//  Copyright © 2025 xjbeta. All rights reserved.
//

import Foundation

public enum DatabaseChangeType: Sendable {
    case insert([String])
    case update([String])
    case delete([String])
    case reload
}

public struct DatabaseChangeNotification: Sendable {
    public let tableName: DBTableNames
    public let changeType: DatabaseChangeType
    public let timestamp: Date
    
    public init(tableName: DBTableNames, changeType: DatabaseChangeType) {
        self.tableName = tableName
        self.changeType = changeType
        self.timestamp = Date()
    }
}

public protocol DatabaseChangeObserver: Sendable {
    func databaseDidChange(notification: DatabaseChangeNotification) async
}


