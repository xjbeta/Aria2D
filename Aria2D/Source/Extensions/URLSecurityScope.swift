//
//  URLSecurityScope.swift
//  Aria2D
//
//  Created by xjbeta on 2017/1/24.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation

// MARK: - Security-Scoped
extension URL {
	func addSecurityScope() -> URL? {
		var urlData = UserDefaults.standard.data(forKey: self.path)
		if urlData == nil {
			do {
				let data = try self.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
				UserDefaults.standard.set(data, forKey: self.path)
				urlData = data
			} catch {
				Log("creatBookmarkError:\(error)")
			}
		}
		if let data = urlData {
			do {
				var bool = false
                let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bool)
                let _ = url.startAccessingSecurityScopedResource()
                return url
			} catch {
				Log("resolveBookmarkError\(error)")
			}
		}
		return nil
	}
	
	func removeSecurityScope() {
		UserDefaults.standard.removeObject(forKey: self.path)
		self.stopAccessingSecurityScopedResource()
	}
}
