//
//  DataObject.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/21.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation

public typealias GID = String
public typealias Name = String
public typealias TotalLength = String
public typealias FileType = String
//public typealias Status = String

public enum Status: String {
    case active, waiting, paused, error, complete, removed
}

public typealias Percentage = String
public typealias ProgressIndicator = Double
public typealias Time = String
public typealias Speed = String


extension GID {
    func pause() {
        Aria2cAPI.sharedInstance.pause(self)
    }
    
    func unpause() {
        Aria2cAPI.sharedInstance.unpause(self)
    }
    
    func forcePause() {
        Aria2cAPI.sharedInstance.forcePause(self)
    }
    
    func removeDownloadResult() {
        Aria2cAPI.sharedInstance.removeDownloadResult(self)
    }
    
    func remoce() {
        Aria2cAPI.sharedInstance.remove(self)
    }
}