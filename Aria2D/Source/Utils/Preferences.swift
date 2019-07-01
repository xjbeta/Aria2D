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
        var downloadUrl = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        downloadUrl?.appendPathComponent("Aria2")
        
        guard let downloadPath = downloadUrl?.path else {
            defaultAria2cOptionsDic = [:]
            assert(false, "Unable to find download folder.")
            return
        }
        
        defaultAria2cOptionsDic = [
            Aria2Option.autoSaveInterval: "60",
            Aria2Option.saveSessionInterval: "60",
            
            Aria2Option.rpcListenAll: "false",
            Aria2Option.rpcListenPort: "2333",
//            Aria2Option.rpcSecret: "",
            
            Aria2Option.dir: downloadPath,
            Aria2Option.maxConcurrentDownloads: "3",
            Aria2Option.minSplitSize: "20M",
            Aria2Option.split: "16",
            Aria2Option.userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.3 Safari/605.1.15",
            
//            Aria2Option.btTracker: "",
            Aria2Option.peerAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.3 Safari/605.1.15",
            Aria2Option.seedRatio: "1.0",
            Aria2Option.seedTime: "120"]
	}

    let prefs = UserDefaults.standard

	let keys = PreferenceKeys.self
    
    let defaultAria2cOptionsDic: [Aria2Option: String]
	
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
    
    @objc var showAria2Features: Bool {
        get {
            return defaults(.showAria2Features) as? Bool ?? true
        }
        set {
            defaultsSet(newValue, forKey: .showAria2Features)
            NotificationCenter.default.post(name: .updateConnectStatus, object: nil)
        }
    }
    
    @objc var showGlobalSpeed: Bool {
        get {
            return defaults(.showGlobalSpeed) as? Bool ?? true
        }
        set {
            defaultsSet(newValue, forKey: .showGlobalSpeed)
            NotificationCenter.default.post(name: .updateGlobalStat, object: nil)
        }
    }
    
    @objc var openMagnetLink: Bool {
        get {
            return defaults(.openMagnetLink) as? Bool ?? true
        }
        set {
            defaultsSet(newValue, forKey: .openMagnetLink)
            setLaunchServer()
        }
    }
    
    func setLaunchServer() {
        guard openMagnetLink,
            let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        LSSetDefaultHandlerForURLScheme("magnet" as CFString, bundleIdentifier as CFString)
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
    
    var trackersUrlTypes: [String] {
        get {
            return defaults(.trackersUrlTypes) as? [String] ?? [Aria2cTrackerListViewController.TrackersUrlType.http,
            Aria2cTrackerListViewController.TrackersUrlType.https,
            Aria2cTrackerListViewController.TrackersUrlType.udp,
            Aria2cTrackerListViewController.TrackersUrlType.ws].map { $0.rawValue }
        }
        set {
            defaultsSet(newValue, forKey: .trackersUrlTypes)
        }
    }
    
    var trackersType: String {
        get {
            return defaults(.trackersType) as? String ?? Aria2cTrackerListViewController.TrackersType.domains.rawValue
        }
        set {
            defaultsSet(newValue, forKey: .trackersType)
        }
    }
    
    private let confLock = NSLock()
    
    var aria2Conf: [Aria2Option: String] {
        get {
            confLock.lock()
            let u = URL(fileURLWithPath: aria2cOptions.path(for: .aria2cConf))
            guard FileManager.default.fileExists(atPath: u.path),
                let confData = try? Data(contentsOf: u),
                let confStr = String(data: confData, encoding: .utf8) else {
                    print("Load Conf file from \(u) Error.")
                    confLock.unlock()
                    return [:]
            }
            
            let confs = confStr.split(separator: "\n").map(String.init).filter {
                !$0.starts(with: "#") && $0 != ""
            }
            
            var confsDic = [Aria2Option: String]()
            confs.forEach {
                let kv = $0.split(separator: "=", maxSplits: 1).map(String.init)
                guard kv.count == 2 else {
                    print("Unkown Key-value pair \(kv)")
                    return
                }
                confsDic[Aria2Option(rawValue: kv[0])] = kv[1]
            }
            confLock.unlock()
            return confsDic
        }
    }
    
    func updateConf(key: Aria2Option, with value: String) {
        confLock.lock()
        let u = URL(fileURLWithPath: aria2cOptions.path(for: .aria2cConf))
        guard FileManager.default.fileExists(atPath: u.path),
            let confData = try? Data(contentsOf: u),
            let confStr = String(data: confData, encoding: .utf8) else {
                print("Load Conf file from \(u) Error.")
                confLock.unlock()
                return
        }
        
        let keyStr = key.rawValue as String
        
        do {
            if confStr.contains(keyStr) {
                // edit value
                var updated = false
                var lines = confStr.split(separator: "\n", omittingEmptySubsequences: false)
                lines.enumerated().filter {
                    $0.element.contains(keyStr)
                    }.forEach {
                        guard $0.offset >= 0, $0.offset < lines.count else { return }
                        
                        if !updated {
                            lines[$0.offset] = "\(keyStr)=\(value)"
                            updated = true
                        } else if !lines[$0.offset].starts(with: "#") {
                            lines[$0.offset] = "# " + lines[$0.offset]
                        }
                }
                
                try lines.joined(separator: "\n").write(to: u, atomically: true, encoding: .utf8)
            } else {
                // add key and value
                let handle = try FileHandle(forWritingTo: u)
                handle.seekToEndOfFile()
                let kvStr = "\n\(keyStr)=\(value)"
                guard let d = kvStr.data(using: .utf8) else {
                    print("Init kv data error.")
                    handle.closeFile()
                    confLock.unlock()
                    return
                }
                handle.write(d)
                handle.closeFile()
            }
        } catch let error {
            print(error)
        }
        confLock.unlock()
    }

	func checkPlistFile() {
        // check userdefault plist r/w
		let key = "checkPlistFile"
		prefs.set(true, forKey: key)
		assert(prefs.value(forKey: key) != nil, "Unable to read and write plist file, try to restart your macOS.", file: "")
		prefs.removeObject(forKey: key)
        
        // check conf file and add missed options.
        defaultAria2cOptionsDic.forEach { kv in
            if !aria2Conf.contains(where: { $0.key == kv.key }) {
                updateConf(key: kv.key, with: "\(kv.value)")
            }
        }
        
        // remove droped keys
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
