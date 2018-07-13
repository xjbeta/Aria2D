//
//  Transformer.swift
//  Aria2D
//
//  Created by xjbeta on 2016/12/31.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation
import JavaScriptCore

// Int <-> NsNumber
@objc(IntToNumberTransformer)
class IntToNumberTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		if let i = value as? Int {
			return NSNumber(value: i)
		} else {
			return nil
		}
	}
	override func reverseTransformedValue(_ value: Any?) -> Any? {
		if let i = value as? NSNumber {
			return Int(exactly: i)
		} else {
			return nil
		}
	}
}

@objc(StringToNSStringTransformer)
class StringToNSStringTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		return value as? NSString ?? ""
	}
	override func reverseTransformedValue(_ value: Any?) -> Any? {
		return value as? String ?? ""
	}
}

@objc(Int64ToByteSpeedTransformer)
class Int64ToByteSpeedTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        if let value = value as? Int64 {
            return "\(value.ByteFileFormatter())/s"
        }
        return ""
    }
}

@objc(PeerIDDecode)
class PeerIDDecode: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        if let value = value as? String {
            if let context = JSContext() {
                context.evaluateScript("var str = unescape('\(value)')")
                return context.evaluateScript("str").toString()
            }
        }
        return ""
    }
}


