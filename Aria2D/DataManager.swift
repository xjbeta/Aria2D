//
//  DataManager.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON

class DataManager: NSObject {
    

    
    var activeList      = [Data]()
    var waitingList     = [Data]()
    var pausedList      = [Data]()
    var errorList       = [Data]()
    var removedList     = [Data]()

    var completeList    = [Data]()
    var downloadingList = [Data]()
    
    
    
    
    var status = Status.initialize
    
    
    enum Status {
        case initialize, setData, update, reload
    }

    


    
    
    
}

extension DataManager {
    
    
    
    
    func setData(json: JSON) {
        
        resetData()
        status = .setData
        for result in json["result"][0][0].arrayValue {
            
            
            activeList.append(dataFormat(result))
        }
        
        downloadingList += activeList
        
        for result in json["result"][1][0].arrayValue {
            
            let status = result["status"].stringValue
            switch status {
            case "waiting":
                waitingList.append(dataFormat(result))
            case "paused":
                pausedList.append(dataFormat(result))
            default:
                break
            }
            
            
        }
        downloadingList += waitingList
        downloadingList += pausedList
        
        for result in json["result"][2][0].arrayValue {
            
            let status = result["status"].stringValue
            
            switch status {
            case "complete":
                completeList.append(dataFormat(result))
            case "error":
                errorList.append(dataFormat(result))
            case "remove":
                removedList.append(dataFormat(result))
            default:
                break
            }
        }
        downloadingList += errorList
        
        
        
        
    }
    
    
    func update(json: JSON) {
        
        
        
    
        
        guard json["result"].arrayValue.count == activeList.count else {
            return
        }
        status = .update
        
        for (index, value) in json["result"].arrayValue.enumerate() {
            let completedLength    = value["completedLength"]
            let totalLength        = value["totalLength"]
            let downloadSpeed      = value["downloadSpeed"]
            activeList[index].totalLength = byteConverter(totalLength.uIntValue)
            if totalLength.doubleValue == 0 {
                activeList[index].progressIndicator = 0
                activeList[index].percentage = "0.0%"
            } else {
                let per = completedLength.doubleValue/totalLength.doubleValue*100
                activeList[index].progressIndicator = per
                activeList[index].percentage = "\(strFormat(per))%"
            }
            
            
            activeList[index].time = timeFormat(totalLength.uIntValue - completedLength.uIntValue, speed: downloadSpeed.uIntValue)
            activeList[index].speed = "\(byteConverter(downloadSpeed.uIntValue))/s"
        }
        
        
    }
    
    
    
    
    

    

    
    
    func downloadStart(gid: String) {
    
        
    }
    func downloadPause(gid: String) {
        let index = indexOfDownloadingList(gid)
        guard index < downloadingList.count else { return }
        let object = downloadingList[index]
        object.time = ""
        object.status = "paused"
        pausedList.append(object)
    }
    
    
    func downloadStop(gid: String) {
        
        
    }
    func downloadComplete(gid: String) {
        
        
    }
    func downloadError(gid: String) {
        
        
    }
    func btDownloadComplete(gid: String) {
        
        
    }
    
    
    
    func activeCount() -> Int {
        return activeList.count
    }
    
    
    
    func resetData() {
        activeList.removeAll()
        waitingList.removeAll()
        pausedList.removeAll()
        errorList.removeAll()
        removedList.removeAll()
        completeList.removeAll()
        downloadingList.removeAll()
    }
    
    
    
}






private extension DataManager {
    
    
    func indexOfDownloadingList(gid: String) -> Int {
        if let i = downloadingList.indexOf({$0.gid == gid}) {
            return i
        } else {
            return -1
        }
    }
    
    
    func indexOfCompleteList(gid: String) -> Int {
        if let i = downloadingList.indexOf({$0.gid == gid}) {
            return i
        } else {
            return -1
        }
    }
    
    
    
    
    

    
    
    
    
    func dataFormat(json: JSON) -> Data {
        
        
        var gid: String
        var name: String
        var totalLength: String
        var fileType: String
        var status: String
        var percentage: String
        var progressIndicator: Double
        var time: String
        var speed: String
        
        
        let dir             = json["dir"].stringValue
        let path            = json["files"][0]["path"].stringValue
        let completedLength = json["completedLength"]
        let totalLengthByte = json["totalLength"]
        let downloadSpeed   = json["downloadSpeed"]
        
        
        if json["bittorrent"] != nil {
            print("bittorrent")
        }
        
        
        
        
        totalLength = byteConverter(totalLengthByte.uIntValue)
        gid = json["gid"].stringValue
        name = downloadTaskNameConverter(dir, path: path)
        fileType = (path as NSString).pathExtension
        
        
        if totalLengthByte.doubleValue == 0 {
            progressIndicator = 0
            percentage = "0.0%"
        } else {
            let per = completedLength.doubleValue/totalLengthByte.doubleValue*100
            progressIndicator = per
            percentage = "\(strFormat(per))%"
        }
        
        if json["status"].stringValue == "active" {
            status = "active"
            speed = "\(byteConverter(downloadSpeed.uIntValue))/s"
        } else {
            status = json["status"].stringValue
            speed = ""
        }
        
        
        if json["bittorrent"] != nil {
            
            
            
        }
        
        
        

        
        time = timeFormat(totalLengthByte.uIntValue - completedLength.uIntValue, speed: downloadSpeed.uIntValue)
        
        return Data(gid: gid,
                    name: name,
                    totalLength: totalLength,
                    fileType: fileType,
                    status: status,
                    percentage: percentage,
                    progressIndicator: progressIndicator,
                    time: time,
                    speed: speed)
        
        
    }
    
    


    
    
    
    
    func byteConverter(byte:UInt) -> String {
        switch Double(byte) {
        case 0..<1e3:
            return "\(byte) 字节"
        case 1e3..<1e6:
            return "\(strFormat(Double(byte) * 1e-3)) KB"
        case 1e6..<1e9:
            return "\(strFormat(Double(byte) * 1e-6)) MB"
        case 1e9..<1e12:
            return "\(strFormat(Double(byte) * 1e-9)) GB"
        case 1e12..<1e15:
            return "\(strFormat(Double(byte) * 1e-12)) TB"
        case 1e15...1e18:
            return "\(strFormat(Double(byte) * 1e-15)) PB"
        default:
            return ""
            
        }
    }
    
    
    
    func strFormat(double: Double) -> String {
        var str = String(format: "%.1f", Float(double))
        if str.hasSuffix(".0") {
            let range = str.endIndex.advancedBy(-2)..<str.endIndex
            str.removeRange(range)
        }
        return str
    }
    
    
    
    func downloadTaskNameConverter(dir: String, path: String) -> String {
        var str = path.stringByReplacingOccurrencesOfString(dir, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        if str != "" {
            str.removeAtIndex(str.startIndex)
        }
        return str
    }
    
    
    func timeFormat(length: UInt, speed: UInt) -> String {
        guard speed != 0 else {
            return "INF"
        }
        
        let time = length / speed
        let sec  = time % 60
        let min  = (time - sec) / 60 % 60
        let hour = ((time - sec) / 60 - min) / 60 % 24
        let day  = (((time - sec) / 60 - min) / 60 - hour) / 24
        var str  = ""
        var count = 0
        
        if day != 0 {
            str += "\(day)d"
            count += 1
        }
        if hour != 0 && count < 2 {
            str += "\(hour)h"
            count += 1
        } else if count != 0 {
            return str
        }
        if min != 0 && count < 2 {
            str += "\(min)m"
            count += 1
        } else if count != 0 {
            return str
        }
        if sec != 0 && count < 2 {
            str += "\(sec)s"
        }
        
        if sec == 0 && count == 0 {
            return "0s"
        }
        
        return str
    }
    
}






