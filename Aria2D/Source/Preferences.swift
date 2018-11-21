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

	
	let keys = PreferenceKeys.self
	
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
    
    var hideActiveLog: Bool {
        get {
            return defaults(.hideActiveLog) as? Bool ?? true
        }
        set {
            defaultsSet(newValue, forKey: .hideActiveLog)
        }
    }
	
	
	@objc var developerMode: Bool {
		get {
			return defaults(.developerMode) as? Bool ?? false
		}
		set {
			defaultsSet(newValue, forKey: .developerMode)
			NotificationCenter.default.post(name: .developerModeChanged, object: nil)
		}
	}
	
	
	@objc var useForce: Bool {
		get {
			return defaults(.useForce) as? Bool ?? true
		}
		set {
			defaultsSet(newValue, forKey: .useForce)
		}
	}
	@objc var completeNotice: Bool {
		get {
			return defaults(.completeNotice) as? Bool ?? true
		}
		set {
			defaultsSet(newValue, forKey: .completeNotice)
		}
	}
	
// MARK: - Aria2c Options
	var autoStartAria2c: Bool {
		get {
			return defaults(.autoStartAria2c) as? Bool ?? true
		}
		set {
			defaultsSet(newValue, forKey: .autoStartAria2c)
		}
	}
	var restartAria2c: Bool {
		get {
			return defaults(.restartAria2c) as? Bool ?? false
		}
		set {
			defaultsSet(newValue, forKey: .restartAria2c)
		}
	}
	
	

	private lazy var defaultAria2cOptions: Aria2cOptions = {
		let s = Aria2cOptions()
		Preferences.shared.aria2cOptions = s
		return s
	}()
	
	
	var aria2cOptions: Aria2cOptions {
		get {
			if let data = defaults(.aria2cOptions) as? Data,
				let aria2cOptions = Aria2cOptions(data: data) {
				return aria2cOptions
			} else {
				return Aria2cOptions()
			}
		}
		set {
			defaultsSet(newValue.encode(), forKey: .aria2cOptions)
		}
	}

	func checkPlistFile() {
		let key = "checkPlistFile"
		prefs.set(true, forKey: key)
		assert(prefs.value(forKey: key) != nil, "Can't save value to preference, try to restart your macOS.", file: "124")
		prefs.removeObject(forKey: key)
        
        let dropedKeys = ["baidu_token", "baidu_folder", "baidu_APIKey", "baidu_SecretKey", "app_baidu_ascending", "app_baidu_sortValue"]
        dropedKeys.forEach {
            prefs.removeObject(forKey: $0)
        }
	}
	
}

private extension Preferences {
	
	func defaults(_ key: PreferenceKeys) -> Any? {
		return prefs.value(forKey: key.rawValue) as Any?
	}
	
	func defaultsSet(_ value: Any, forKey key: PreferenceKeys) {
		prefs.setValue(value, forKey: key.rawValue)
	}
}
