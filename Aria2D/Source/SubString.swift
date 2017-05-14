//
//  SubString.swift
//  Aria2D
//
//  Created by xjbeta on 2016/12/17.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation

extension String {
	func subString(from startString: String, to endString: String) -> String {
		if let startIndex = self.range(of: startString) {
			var str = self.substring(from: startIndex.upperBound)
			if let endIndex = str.range(of: endString) {
				str = str.substring(to: endIndex.lowerBound)
				return str
			}
		}
		return ""
	}
	
	func subString(from startString: String) -> String {
		if let startIndex = self.range(of: startString) {
			return self.substring(from: startIndex.upperBound)
		}
		return ""
	}
	
	
	func delete(between startString: String, and endString: String) -> String {
		if let start = self.range(of: startString) {
			let str = self.substring(from: start.upperBound)
			if let end = str.range(of: endString) {
				return self.substring(to: start.lowerBound) + str.substring(from: end.upperBound)
			}
		}
		return ""
	}
}

