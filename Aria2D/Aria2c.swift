//
//  Aria2c.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/9.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa


class Aria2c: NSObject {
    
    static let sharedInstance = Aria2c()
    
    private override init() {
        
    }
    
    func startAria2c() {
        shellTask("SessionFile")
        shellTask("StartAria2c")
        
//        print()
        
    }

    
    
    
    
    private func shellTask(shellFileName: String) {
        let task        = NSTask()
        let path        = NSBundle.mainBundle().pathForResource(shellFileName, ofType: "sh")
        
        
        task.launchPath = "/bin/sh"
        task.arguments  = [path!]
        task.launch()
    }


}
