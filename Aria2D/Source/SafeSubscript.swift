//
//  SafeSubscript.swift
//  Aria2D
//
//  Created by xjbeta on 2017/2/3.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation

extension Collection {
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
