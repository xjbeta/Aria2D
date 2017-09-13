//
//  Log.swift
//  Aria2D
//
//  Created by xjbeta on 2016/12/25.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

public func Log<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
	#if DEBUG
		print("\(URL(fileURLWithPath: file).lastPathComponent)[\(line)], \(method): \(message)")
	#endif
}
