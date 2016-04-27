//
//  Aria2cAPI.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/27.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class Aria2cAPI: NSObject {
    
    static let sharedInstance = Aria2cAPI()
    private override init() {
    }
    
    let aria2cMethods = Aria2cMethods()
    
    
    
    

}

//MARK: Aria2cMethods
extension Aria2cAPI {
    func tellStatus() {
        aria2cMethods.tellStatus()
    }
    
    func tellActiveSec() {
        aria2cMethods.tellActiveSec()
    }
    
    func shutdown() {
        aria2cMethods.shutdown()
    }
    
    func addUri(uri: String) {
        aria2cMethods.addUri(uri)
    }
    
    
    func addTorrent(path: String) {
        aria2cMethods.addTorrent(path)
    }
    
    
    
    func pause(gid: GID) {
        aria2cMethods.pause(gid)
    }
    
    
    func unpause(gid: GID) {
        aria2cMethods.unpause(gid)
    }
    
    
    func forcePause(gid: String) {
        aria2cMethods.forcePause(gid)
    }
    
    
    func removeDownloadResult(gid: String) {
        aria2cMethods.removeDownloadResult(gid)
    }
    
    
    func remove(gid: String) {
        aria2cMethods.remove(gid)
    }
    
    
    
    func pauseAll() {
        aria2cMethods.pauseAll()
    }
    
    func unPauseAll() {
        aria2cMethods.unPauseAll()
    }
    

}