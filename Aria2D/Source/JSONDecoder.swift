//
//  JSONDecoder.swift
//  Aria2D
//
//  Created by xjbeta on 2017/7/27.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation

extension Data {
	func decode<T>(_ type: T.Type,
//	               from data: Data,
	_ methodName: String = #function) -> T? where T: Decodable {
		do {
			let re = try JSONDecoder().decode(T.self, from: self)
			return re
		} catch let error {
			Log(methodName)
			Log(error)
			return nil
		}
	}
}
