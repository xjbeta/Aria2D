//
//  Data.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON



class Data: NSObject {
    
    var gid: GID
    var name: Name
    var totalLength: TotalLength
    var fileType: FileType
    var status: Status
    var percentage: Percentage
    var progressIndicator: ProgressIndicator
    var time: Time
    var speed: Speed
    
    init(gid: GID, name: Name, totalLength: TotalLength, fileType: FileType, status: Status, percentage: Percentage, progressIndicator: ProgressIndicator, time: Time, speed: Speed) {

        self.gid = gid
        self.name = name
        self.totalLength = totalLength
        self.fileType = fileType
        self.status = status
        self.percentage = percentage
        self.progressIndicator = progressIndicator
        self.time = time
        self.speed = speed
    }
    
    func statusValue() -> String {
        switch status {
        case .active:
            return "active"
        case .complete:
            return "complete"
        case .error:
            return "error"
        case .paused:
            return "paused"
        case .removed:
            return "removed"
        case .waiting:
            return "waiting"
        }
    }
    
}






