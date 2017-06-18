//
//  EnumList.swift
//  Aria2D
//
//  Created by xjbeta on 16/5/22.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation



enum preferenceKeys: String {
	case isFirstLaunch = "app_isFirstLaunch"
	case downloadDir = "app_downloadDir"
	case ascending = "app_baidu_ascending"
	case sortValue = "app_baidu_sortValue"
	case aria2ServersData = "app_aria2ServersData"
	case recordWebSocketLog = "app_recordWebSocketLog"
	
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
	
	case baiduToken = "baidu_token"
	case baiduFolder = "baidu_folder"
	case baiduAPIKey = "baidu_APIKey"
	case baiduSecretKey = "baidu_SecretKey"
	
	var keyValue: String {
		return self.rawValue.replacingOccurrences(of: "--", with: "")
	}
	
	init?(key: String) {
		self.init(rawValue: "--" + key)
	}
}





enum aria2Notice: String {
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


enum leftSourceListRow: String {
    case downloading
    case completed
    case baidu
	case removed
    case none
}

enum taskStatus: String {
	case active = "active"
	case waiting = "waiting"
	case paused = "paused"
	case error = "error"
	case complete = "complete"
	case removed = "removed"
	init?(raw: String) {
		self.init(rawValue: raw)
	}
	
}


