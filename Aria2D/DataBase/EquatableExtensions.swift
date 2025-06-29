//
//  EquatableExtensions.swift
//  Aria2D
//
//  Created by xjbeta on 2025/6/11.
//  Copyright © 2025 xjbeta. All rights reserved.
//

import Foundation

extension Equatable {
    func isEqual(to: Any) -> Bool {
        self == to as? Self
    }
}

func ==<T>(lhs: T?, rhs: T?) -> Bool where T: Any {
    guard let lhs, let rhs else {
        return lhs == nil && rhs == nil
    }
    
    if let isEqual = (lhs as? any Equatable)?.isEqual {
        return isEqual(rhs)
    }
    else if let lhs = lhs as? [Any], let rhs = rhs as? [Any], lhs.count == rhs.count {
        return lhs.elementsEqual(rhs, by: ==)
    }
    else if let lhs = lhs as? [AnyHashable: Any], let rhs = rhs as? [AnyHashable: Any], lhs.count == rhs.count {
        return lhs.allSatisfy { $1 == rhs[$0] }
    }
    return false
}
