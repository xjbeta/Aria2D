//
//  SafeSubscript.swift
//  Aria2D
//
//  Created by xjbeta on 2017/2/3.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
	// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Generator.Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
