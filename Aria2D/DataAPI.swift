//
//  DataAPI.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/4.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON

class DataAPI: NSObject {
    static let sharedInstance = DataAPI()
    
    private override init() {
        
    }
    
    private let dataManager = DataManager()
    
    
    func status() -> DataManager.Status {
        return dataManager.status
    }
    
    
    
    func setData(json: JSON) {
        dataManager.setData(json)
        
    }
    
    func update(json: JSON) {
        dataManager.update(json)
    }
    
    
    func activeCount() -> Int {
        return dataManager.activeCount()
    }
    
    
    
    func data() -> [Data] {
        if BackgroundTask.sharedInstance.selectedRow == 1 {
            return dataManager.downloadingList
        } else if BackgroundTask.sharedInstance.selectedRow == 2 {
            return dataManager.completeList
        }
        return []
    }
    
    func resetData() {
        dataManager.resetData()
    }
    
    
    func downloadStart(gid: String) {
        dataManager.downloadStart(gid)
    }
    
    func downloadPause(gid: String) {
        dataManager.downloadPause(gid)
    }
    
    func downloadStop(gid: String) {
        dataManager.downloadStop(gid)
    }
    
    func downloadComplete(gid: String) {
        dataManager.downloadComplete(gid)
    }
    
    func downloadError(gid: String) {
        dataManager.downloadError(gid)
    }
    
    func btDownloadComplete(gid: String) {
        dataManager.btDownloadComplete(gid)
    }
    
}


