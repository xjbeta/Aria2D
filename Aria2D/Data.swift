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
    
    var gid: String
    var name: String
    var totalLength: String
    var fileType: String
    var status: String
    var percentage: String
    var progressIndicator: Double
    var time: String
    var speed: String
    
    
    init(gid: String, name: String, totalLength: String, fileType: String, status: String, percentage: String, progressIndicator: Double, time: String, speed: String) {

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
    

    
}



