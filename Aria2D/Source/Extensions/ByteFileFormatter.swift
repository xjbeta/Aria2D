//
//  ByteFileFormatter.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/11.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation

extension Int64 {
	func ByteFileFormatter() -> String {
		let formatter = ByteCountFormatter()
		formatter.countStyle = .file
		return formatter.string(fromByteCount: self)
	}
}


extension Double {
    func percentageFormat() -> String {
        var str = String(format: "%.1f", Float(self))
        if str.hasSuffix(".0") {
            let range = str.index(str.endIndex, offsetBy: -2)..<str.endIndex
            str.removeSubrange(range)
        }
        return str + "%"
    }
}
