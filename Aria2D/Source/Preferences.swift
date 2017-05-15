//
//  Setting.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/10.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class Preferences: NSObject {
	
	static let shared = Preferences()
	
	private override init() {
	}

    let prefs = UserDefaults.standard

	
	let keys = preferenceKeys.self
	
	private lazy var defaultAria2Servers: Aria2Servers = {
		let s = Aria2Servers()
		Preferences.shared.aria2Servers = s
		return s
	}()
	
	var aria2Servers: Aria2Servers {
		get {
			if let data = defaults(.aria2ServersData) as? Data,
				let aria2Servers = Aria2Servers(data: data) {
				return aria2Servers
			} else {
				return defaultAria2Servers
			}
		}
		set {
			defaultsSet(newValue.encode(), forKey: .aria2ServersData)
		}
	}
	

	var recordWebSocketLog: Bool {
		get {
			return defaults(.recordWebSocketLog) as? Bool ?? false
		}
		set {
			defaultsSet(newValue, forKey: .recordWebSocketLog)
		}
	}
	
	
	var developerMode: Bool {
		get {
			return defaults(.developerMode) as? Bool ?? false
		}
		set {
			defaultsSet(newValue, forKey: .developerMode)
			NotificationCenter.default.post(name: .developerModeChanged, object: self)
		}
	}
	
	
	var useForce: Bool {
		get {
			return defaults(.useForce) as? Bool ?? true
		}
		set {
			defaultsSet(newValue, forKey: .useForce)
		}
	}
	var completeNotice: Bool {
		get {
			return defaults(.completeNotice) as? Bool ?? true
		}
		set {
			defaultsSet(newValue, forKey: .completeNotice)
		}
	}
	
	
	
//	var bookmarkUrl: URL
	
// MARK: - OtherPreferences
	var sortValue: String {
		get {
			return defaults(.sortValue) as? String ?? "path"
		}
		set {
			defaultsSet(newValue, forKey: .sortValue)
		}
	}
	
	var ascending: Bool {
		get {
			return defaults(.ascending) as? Bool ?? true
		}
		set {
			defaultsSet(newValue, forKey: .ascending)
		}
	}

	
// MARK: - Aria2Preferences
	
/*
	var options: [String] {
		return ["\(keys.dir.rawValue)=\(dir.path)",
				"\(keys.maxConcurrentDownloads.rawValue)=\(maxConcurrentDownloads)",
				"\(keys.checkIntegrity.rawValue)=\(checkIntegrity)",
				"\(keys.continueOfAria2.rawValue)=\(continueOfAria2)",
				"\(keys.maxOverallUploadLimit.rawValue)=\(maxOverallUploadLimit)",
				"\(keys.maxOverallDownloadLimit.rawValue)=\(maxOverallDownloadLimit)",
				"\(keys.maxConnectionPerServer.rawValue)=\(maxConnectionPerServer)",
				"\(keys.split.rawValue)=\(split)",
				"\(keys.optimizeConcurrentDownloads.rawValue)=\(optimizeConcurrentDownloads)"]
	}
	

	var dir: URL {
		get {
			if let pathStr = defaults(keys.downloadDir) as? String {
				let path = URL(fileURLWithPath: pathStr)
				var upperPath = path
				upperPath.deleteLastPathComponent()
				if FileManager.default.fileExists(atPath: upperPath.path), let path = path.addSecurityScope() {
					return path
				}
			}
			return defaultDownloadPath
		}
		set {
			let oldValue = dir
			oldValue.removeSecurityScope()
			if let url = newValue.addSecurityScope() {
				defaultsSet(url.path, forKey: .downloadDir)
			}
			
		}
	}
	
	var maxConcurrentDownloads: Int {
		get {
			return defaults(.maxConcurrentDownloads) as? Int ?? 3
		}
		set {
			Aria2.shared.changeGlobalOption(keys.maxConcurrentDownloads.keyValue, value: "\(newValue)")
		}
	}
	
	var checkIntegrity: Bool {
		get {
			return defaults(.checkIntegrity) as? Bool ?? false
		}
		set {
			defaultsSet(newValue, forKey: .checkIntegrity)
		}
	}
	
	
	var continueOfAria2: Bool {
		get {
			return defaults(.continueOfAria2) as? Bool ?? true
		}
		set {
			defaultsSet(newValue, forKey: .continueOfAria2)
		}
	}
	
	var maxOverallUploadLimit: Int {
		get {
			return (defaults(.maxOverallUploadLimit) as? Int ?? 0) / 1000
		}
		set {
			Aria2.shared.changeGlobalOption(keys.maxOverallUploadLimit.keyValue, value: "\(newValue * 1000)")
		}
	}
	
	
	var maxOverallDownloadLimit: Int {
		get {
			return (defaults(.maxOverallDownloadLimit) as? Int ?? 0) / 1000
		}
		set {
			Aria2.shared.changeGlobalOption(keys.maxOverallDownloadLimit.keyValue, value: "\(newValue * 1000)")
		}
	}
	
	var maxConnectionPerServer: Int {
		get {
			return defaults(.maxConnectionPerServer) as? Int ?? 1
		}
		set {
			defaultsSet(newValue, forKey: .maxConnectionPerServer)
		}
	}
	
	var split: Int {
		get {
			return defaults(.split) as? Int ?? 5
		}
		set {
			defaultsSet(newValue, forKey: .split)
		}
	}
	
	var optimizeConcurrentDownloads: Bool {
		get {
			return defaults(.optimizeConcurrentDownloads) as? Bool ?? false
		}
		set {
			Aria2.shared.changeGlobalOption(keys.optimizeConcurrentDownloads.keyValue, value: "\(newValue)")
		}
	}
	
// MARK: - Aria2c Connections

	var useInternalAria2c: Bool {
		get {
			return defaults(.useInternalAria2c) as? Bool ?? true
		}
		set {
			defaultsSet(newValue, forKey: .useInternalAria2c)
		}
	}
	
	var aria2cHost: String {
		get {
			return defaults(.aria2cHost) as? String ?? defaultValue.localHost.rawValue
		}
		set {
			defaultsSet(newValue, forKey: .aria2cHost)
		}
	}
	
	
	var aria2cPort: Int {
		get {
			return defaults(.aria2cPort) as? Int ?? Int(defaultValue.port.rawValue)!
		}
		set {
			defaultsSet(newValue, forKey: .aria2cPort)
		}
	}
*/
// MARK: - Baidu
	var baiduAPIKey: String {
		get {
			return defaults(.baiduAPIKey) as? String ?? ""
		}
		set {
			defaultsSet(newValue, forKey: .baiduAPIKey)
		}
	}
	
	var baiduSecretKey: String {
		get {
			return defaults(.baiduSecretKey) as? String ?? ""
		}
		set {
			defaultsSet(newValue, forKey: .baiduSecretKey)
		}
	}
	
	var baiduFolder: String {
		get {
			return defaults(.baiduFolder) as? String ?? ""
		}
		set {
			defaultsSet(newValue, forKey: .baiduFolder)
		}
	}
	
	var baiduToken: String {
		get {
			return defaults(.baiduToken) as? String ?? ""
		}
		set {
			defaultsSet(newValue, forKey: .baiduToken)
		}
	}
	

	func checkPlistFile() {
		let key = "checkPlistFile"
		prefs.set(true, forKey: key)
		assert(prefs.value(forKey: key) != nil, "Can't save value to preference, try to restart your macOS.", file: "124")
		prefs.removeObject(forKey: key)
	}
	
}

private extension Preferences {
	
	func defaults(_ key: preferenceKeys) -> Any? {
		return prefs.value(forKey: key.rawValue) as Any?
	}
	
	func defaultsSet(_ value: Any, forKey key: preferenceKeys) {
		prefs.setValue(value, forKey: key.rawValue)
	}
}
