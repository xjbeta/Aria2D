//
//  EquatableExtensions.swift
//  Aria2D
//
//  Created by xjbeta on 2025/6/11.
//  Copyright © 2025 xjbeta. All rights reserved.
//

import Foundation

private extension Equatable {
    func isEqual(to value: Any) -> Bool {
        guard let other = value as? Self else {
            return false
        }

        return self == other
    }
}

extension Optional where Wrapped == Any {
    func isEqualValue(to rhs: Any?) -> Bool {
        guard let lhs = self, let rhs else {
            return self == nil && rhs == nil
        }
        
        if let isEqual = (lhs as? any Equatable)?.isEqual {
            return isEqual(rhs)
        }
        else if let lhs = lhs as? [Any], let rhs = rhs as? [Any], lhs.count == rhs.count {
            return lhs.elementsEqual(rhs) { Optional.some($0).isEqualValue(to: $1) }
        }
        else if let lhs = lhs as? [AnyHashable: Any], let rhs = rhs as? [AnyHashable: Any], lhs.count == rhs.count {
            return lhs.allSatisfy { Optional.some($1).isEqualValue(to: rhs[$0]) }
        }

        return false
    }
}
