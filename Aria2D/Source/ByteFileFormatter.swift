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
