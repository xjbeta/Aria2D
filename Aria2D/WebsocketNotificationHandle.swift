//
//  WebsocketNotificationHandle.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/13.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON

class WebsocketNotificationHandle: NSObject {

    

    func handle(text: String) {
        
        
        if let dataFromString = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            
            handleNotification(json)
            
            NSNotificationCenter.defaultCenter().postNotificationName("updateDownloadList", object: self, userInfo: nil)
            
            
            

        }
    }
    
    
    private func test(json:JSON) {
        
        switch json["id"].stringValue {
        case "aria2tellStatus":
            DataAPI.sharedInstance.setData(json)
        case "aria2tellUpdate":
            DataAPI.sharedInstance.update(json)
            
        case "aria2removeDownloadResult":
            if json["result"].stringValue == "OK" {
                print("aria2removeDownloadResult  GID#\(json)")
            } else {
                print(json)
            }
            Aria2cAPI.sharedInstance.tellStatus()
            
        case "aria2addUri":
            print(json)
             Aria2cAPI.sharedInstance.tellStatus()
        case "aria2remove":
            Aria2cAPI.sharedInstance.removeDownloadResult(json["result"].stringValue)
             Aria2cAPI.sharedInstance.tellStatus()
            
        default:
            Aria2cAPI.sharedInstance.tellStatus()
        }
        
    }
    
    
    
    private func handleNotification(json:JSON) {
        switch json["id"].stringValue {
        case "aria2tellStatus":
            DataAPI.sharedInstance.setData(json)
        case "aria2tellUpdate":
            DataAPI.sharedInstance.update(json)
            
        case "aria2addTorrent":
            print("aria2addTorrent  GID#\(json["result"])")
            
            
        case "aria2removeDownloadResult":
            if json["result"].stringValue == "OK" {
                print("aria2removeDownloadResult  GID#\(json)")
            } else {
                print(json)
            }
            Aria2cAPI.sharedInstance.tellStatus()
            
        case "aria2addUri":
            print(json)
            
        case "aria2remove":
//            (json["result"].stringValue as GID).removeDownloadResult()
            json["result"].gidValue.removeDownloadResult()
            break
            
            
        case "aria2unpause":
            print("aria2unpause  \(json)")
        case "aria2pause":
            print("aria2pause  \(json)")
            
        case "aria2unpauseAll":
            print("aria2unpauseAll\(json["result"].stringValue)")
        case "aria2pauseAll":
            print("aria2unpauseAll\(json["result"].stringValue)")
            
            
            
        default:
            
            
            switch json["method"].stringValue {
            case "aria2.onDownloadStart":
                print("onDownloadStart  \(json["params"][0]["gid"])")
            case "aria2.onDownloadPause":
                print("onDownloadPause  \(json["params"][0]["gid"])")
            case "aria2.onDownloadStop":
                print("onDownloadStop  \(json["params"][0]["gid"])")
            case "aria2.onDownloadComplete":
                print("onDownloadComplete  \(json["params"][0]["gid"])")
            case "aria2.onDownloadError":
                print("onDownloadError  \(json["params"][0]["gid"])")
            case "aria2.onBtDownloadComplete":
                print("onBtDownloadComplete  \(json["params"][0]["gid"])")
                
                
                
            default:
                
                print(json)
                assert(false, "未识别JSON数据")
            }
            
        }

    }
   
    


}
