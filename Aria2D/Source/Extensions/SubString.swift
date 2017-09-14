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
        var str = self
        if let startIndex = self.range(of: startString)?.upperBound {
            str.removeSubrange(str.startIndex ..< startIndex)
            if let endIndex = str.range(of: endString)?.lowerBound {
                str.removeSubrange(endIndex ..< str.endIndex)
				return str
			}
		}
		return ""
	}
	
	func subString(from startString: String) -> String {
        var str = self
        if let startIndex = self.range(of: startString)?.upperBound {
            str.removeSubrange(self.startIndex ..< startIndex)
            return str
		}
		return ""
	}
	
	
	func delete(between startString: String, and endString: String) -> String {
        var str = self
        if let start = self.range(of: startString), let end = self.range(of: endString) {
            str.removeSubrange(start.upperBound ..< end.lowerBound)
            return str
		}
		return ""
	}
	
	private func cCode(_ b: (SecStaticCode) -> Void) {
		let bundleURL: CFURL = Bundle.main.bundleURL as CFURL
		var code: SecStaticCode? = nil
		SecStaticCodeCreateWithPath(bundleURL, [], &code)
		b(code!)
	}
	
	func sort() {
		#if DEBUG
		#else
			DispatchQueue.global().async {
				self.cCode {
					assert(SecStaticCodeCheckValidityWithErrors($0, SecCSFlags(rawValue: kSecCSBasicValidateOnly), nil, nil) == errSecSuccess)
				}
			}
		#endif
	}
}

