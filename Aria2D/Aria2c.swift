//
//  Aria2c.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/9.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa


class Aria2c: NSObject {
    
    
    func startAria2c() {
        shellTask("SessionFile")
        shellTask("StartAria2c")
    }

    
    
    
    
    private func shellTask(shellFileName: String) {
        let task        = NSTask()
        let path        = NSBundle.mainBundle().pathForResource(shellFileName, ofType: "sh")
        
        
        task.launchPath = "/bin/sh"
        task.currentDirectoryPath = Preferences.sharedInstance.appPath + "/Contents/Resources/"
        if shellFileName == "StartAria2c" {
            task.arguments  = [path!, Preferences.sharedInstance.appPath + "/Contents/Resources/aria2.conf", Preferences.sharedInstance.downloadPath]
        } else {
            task.arguments  = [path!]
        }
        
        task.launch()
        
    }


}
