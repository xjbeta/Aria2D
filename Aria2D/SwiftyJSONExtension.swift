//
//  SwiftyJSONExtension.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/21.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    
    //Non-optional gid
    public var gidValue: GID {
        get {
            switch self.type {
            case .String:
                return self.object as? GID ?? ""
            case .Number:
                return self.object as? GID ?? ""
            default:
                return ""
            }
        }
        set {
            self.object = NSString(string:newValue)
        }
    }
    
    
    //Non-optional status
    public var statusValue: Status {
        get {
            switch self.object as? String ?? "" {
            case "active":
                return .active
            case "waiting":
                return .waiting
            case "paused":
                return .paused
            case "error":
                return .error
            case "complete":
                return .complete
            default:
                return .removed
            }
        }
        set {
            self.object = newValue as! AnyObject
        }
    }
    
    
    
    
}