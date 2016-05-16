//
//  Setting.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/10.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class Preferences: NSObject {

    static let sharedInstance = Preferences()
    
    private override init() {
    }
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var appPath = NSBundle.mainBundle().bundlePath
    var confFilePath = false
    
    
    var downloadPath = NSSearchPathForDirectoriesInDomains(.DownloadsDirectory, .UserDomainMask, true)[0]
    
    var closeAria2cWhenExit = NSUserDefaults.standardUserDefaults().boolForKey("closeAria2cWhenExit")
    
    
    
    func test() {
        downloadPath = NSSearchPathForDirectoriesInDomains(.DownloadsDirectory, .UserDomainMask, true)[0]
        
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func firstLaunchSetting() {
        
//        when application is first launch   prefs.boolForKey("isFirstLaunch") == false
        if prefs.boolForKey("isFirstLaunch") == false {
//            isFirstLaunch
            prefs.setBool(true, forKey: "isFirstLaunch")

            

        } else {
//            isn't FirstLaunch
            
        }
        
    }

    
    
    

    
    
    
    
    
//    func downloadPath() -> String {
//        if let path = prefs.stringForKey("downloadPath"){
//            return path
//        }else{
//            return NSSearchPathForDirectoriesInDomains(.DownloadsDirectory, .UserDomainMask, true)[0]
//        }
//    }
    
    
    
}
