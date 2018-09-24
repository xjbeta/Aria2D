//
//  EnumList.swift
//  Aria2D
//
//  Created by xjbeta on 16/5/22.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation



enum PreferenceKeys: String {
	case isFirstLaunch = "app_isFirstLaunch"
	case downloadDir = "app_downloadDir"
	case ascending = "app_baidu_ascending"
	case sortValue = "app_baidu_sortValue"
	case aria2ServersData = "app_aria2ServersData"
	case recordWebSocketLog = "app_recordWebSocketLog"
    case hideActiveLog = "app_hideActiveLog"
	
	case developerMode = "app_developerMode"
	case useForce = "app_useForce"
	case completeNotice = "app_completeNotice"
	
	
	case autoStartAria2c = "aria2c_autoStartAria2c"
	case restartAria2c = "aria2c_restartAria2c"
	case aria2cOptions = "aria2c_options"
	
	case dir = "--dir"
	case maxConcurrentDownloads = "--max-concurrent-downloads"
	case checkIntegrity = "--check-integrity"
	case continueOfAria2 = "--continue"
	case maxOverallUploadLimit = "--max-overall-upload-limit"
	case maxOverallDownloadLimit = "--max-overall-download-limit"
	case maxConnectionPerServer = "--max-connection-per-server"
	case split = "--split"
	case optimizeConcurrentDownloads = "--optimize-concurrent-downloads"
	
	var keyValue: String {
		return self.rawValue.replacingOccurrences(of: "--", with: "")
	}
	
	init?(key: String) {
		self.init(rawValue: "--" + key)
	}
}





enum Aria2Notice: String, Codable {
    case onDownloadStart = "aria2.onDownloadStart"
    case onDownloadPause = "aria2.onDownloadPause"
    case onDownloadStop = "aria2.onDownloadStop"
    case onDownloadComplete = "aria2.onDownloadComplete"
    case onDownloadError = "aria2.onDownloadError"
    case onBtDownloadComplete = "aria2.onBtDownloadComplete"
    
    init?(raw: String) {
        self.init(rawValue: raw)
    }
    
    init?(aria2ID: String) {
        self.init(rawValue: "aria2.\(aria2ID)")
    }
}


enum SidebarItem: String {
    case downloading
    case completed
    case baidu
	case removed
    case none
}


@objc enum Status: Int, Codable {
	case active
	case waiting
	case paused
	case error
	case complete
	case removed
	
	init?(_ str: String) {
		switch str {
		case "active": self.init(rawValue: 0)
		case "waiting": self.init(rawValue: 1)
		case "paused": self.init(rawValue: 2)
		case "error": self.init(rawValue: 3)
		case "complete": self.init(rawValue: 4)
		case "removed": self.init(rawValue: 5)
		default:
			self.init(rawValue: -1)
		}
	}
	
	func string() -> String {
		switch self {
		case .active: return "active"
		case .waiting: return "waiting"
		case .paused: return "paused"
		case .error: return "error"
		case .complete: return "complete"
		case .removed: return "removed"
		}
	}
}

