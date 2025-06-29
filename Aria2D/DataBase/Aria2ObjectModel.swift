//
//  Aria2Object.swift
//  Aria2D
//
//  Created by Copilot on 2025/05/27.
//  Copyright © 2025 xjbeta. All rights reserved.
//

import Foundation

// Check if there's already a non-CoreData Aria2Object defined elsewhere
public class Aria2Object: Decodable {
    // Core properties
    public var gid: String
    public var status: Int16
    public var totalLength: Int64
    public var completedLength: Int64
    public var uploadLength: Int64
    public var downloadSpeed: Int64
    public var uploadSpeed: Int64
    public var connections: Int64
    public var dir: String?
    
    // Additional properties
    public var belongsTo: String?
    public var bitfield: String?
    public var errorCode: Int16
    public var errorMessage: String?
    public var followedBy: String?
    public var following: String?
    public var infoHash: String?
    public var numPieces: String?
    public var numSeeders: String?
    public var pieceLength: Int64
    public var seeder: Bool
    public var verifiedLength: String?
    public var verifyIntegrityPending: String?
    
    // References to other objects
    public var bittorrent: Aria2Bittorrent?
    public var files: [Aria2File] = []
    
    // Sorting
    public var sortValue: Double
    
    // Custom properties
    private var nameSaved: String?
    
    private enum CodingKeys: String, CodingKey {
        case files
        case gid
        case status
        case totalLength
        case completedLength
        case uploadLength
        case downloadSpeed
        case uploadSpeed
        case pieceLength
        case connections
        case dir
        case bittorrent
        case bitfield
        case numPieces
        case errorCode
        case errorMessage
    }
    
    // Default initializer with minimal required properties
    public init(gid: String, status: Int16 = 0) {
        self.gid = gid
        self.status = status
        self.totalLength = 0
        self.completedLength = 0
        self.uploadLength = 0
        self.downloadSpeed = 0
        self.uploadSpeed = 0
        self.connections = 0
        self.pieceLength = 0
        self.seeder = false
        self.errorCode = 0
        self.sortValue = Double(Date().timeIntervalSince1970)
    }
    
    // Decodable implementation would be more complex and require additional models
    // This is just a placeholder
    public required init(from decoder: Decoder) throws {
        // Implementation would decode from JSON response
        // For now just initialize with defaults
        self.gid = ""
        self.status = 0
        self.totalLength = 0
        self.completedLength = 0
        self.uploadLength = 0
        self.downloadSpeed = 0
        self.uploadSpeed = 0
        self.connections = 0
        self.pieceLength = 0
        self.seeder = false
        self.errorCode = 0
        self.sortValue = Double(Date().timeIntervalSince1970)
        
        // Would actually implement full decoding here
    }
    
    // Computed property that was previously an @objc dynamic var
    public var name: String {
        if let name = nameSaved {
            return name
        } else if let name = bittorrent?.name,
            name != "" {
            nameSaved = name
            return name
        } else if let file = files.first, let path = file.path, path != "" {
            let name = URL(fileURLWithPath: path).lastPathComponent
            nameSaved = name
            return name
        } else {
            return "unknown"
        }
    }
}
