//
//  Aria2OptionTooltip.swift
//  Aria2D
//
//  Created by xjbeta on 2018/8/18.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

extension Aria2Option {
    func toolTisString() -> String {
        switch valueType {
        case .bool(let bool):
            let objs = bool.map { $0.rawValue }
            return objs.joined(separator: "| ")
        case .parameter(let p):
            let objs = p.map { $0.rawValue }
            return objs.joined(separator: "| ")
        case .number(let min, let max):
            if max != -1 {
                return "\(min) - \(max)"
            } else {
                return "min: \(min)"
            }
        case .unitNumber(let min, let max):
            let str = "      1| 1K| 1M"
            if max.rawValue != 0 {
                return "\(min.stringValue) - \(max.stringValue)\(str)"
            } else {
                return "min: \(min.stringValue)\(str)"
            }
        case .localFilePath:
            return "Local file path"
        case .hostPort:
            return "Host port"
        case .httpProxy:
            return "Proxy"
        case .optimizeConcurrentDownloads:
            return "true| false| A:B"
        case .integerRange(let min, let max):
            if self == .selectFile {
                return "1-5,8,9, min: \(min), max: \(max)"
            } else {
                return "6881-6999, min: \(min), max: \(max)"
            }
        case .string(str: let str):
            return str
        default:
            break
        }
        return ""
    }
    
    func usageString() {
        
        
        
        
        
        
    }
}
