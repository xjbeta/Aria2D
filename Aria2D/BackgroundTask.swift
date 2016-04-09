//
//  BackgroundTask.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Foundation
class BackgroundTask: NSObject {

    static let sharedInstance = BackgroundTask()
    
    private override init() {
        super.init()
        self.selectedRow = 1
        self.isSuspend = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BackgroundTask.setSelectRow(_:)), name: "LeftSourceListSelection", object: nil)
    }
    
    
    func setSelectRow(notification: NSNotification) {
        let row = notification.userInfo!["selectedRow"] as? Int
        self.selectedRow = row!
        
    }
    
    // LeftSourceList
    var selectedRow = Int()
    // DownloadList
    var selectedIndexs = NSIndexSet()
    
    
    private var isSuspend = Bool()
    
    private let counter = Counter()
    
    private var timer = dispatch_source_t!(nil)
    
    
    private let backgroundQueue = dispatch_queue_create("com.vluxe.Aria2D.connectWebSocketQueue", nil)
    private func startTimer() {
        /*
        指定 DISPATCH_SOURCE_TYPE_TIMER ，做成 dispatch_source
        
        在定时器经过指定时间时设定 queue 为追加处理的 Dispatch Queue
        */
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, backgroundQueue)
        
        /*
        将定时器设定为马上执行
        每秒重复一次
        不允许延迟
        */
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 0)
        
        /*
        指定定时器指定时间内执行的处理
        */
        dispatch_source_set_event_handler(timer) {
            self.action()
        }
        
        dispatch_resume(timer)
        isSuspend = false
        
    }
    
    
    private func action() {
        guard Aria2Websocket.sharedInstance.isConnected() || (counter.bool() == false) else {
            Aria2c.sharedInstance.startAria2c()
            Aria2Websocket.sharedInstance.connect()
            return
        }
        
        guard !(self.selectedRow == 1 && DataAPI.sharedInstance.activeCount() > 0) else {
            Aria2cMethods.sharedInstance.TellActiveSec()
            return
        }

        
        
        
    }
    
    
    
}


extension BackgroundTask {
    
    
    func suspend() {
        
        guard timer != nil else {
            self.startTimer()
//            print("startTimer")
            return
        }
        
        guard isSuspend else {
            dispatch_suspend(timer)
            isSuspend = true
            return
        }
    }
    
    func resume() {
        if isSuspend {
            dispatch_resume(timer)
            isSuspend = false
        }
    }
    
    
    func sendAction(action: () -> Void) {
        dispatch_async(backgroundQueue) {
            action()
        }
    }
  
    
}





private class Counter {
    var count = 0
    func bool() -> Bool {
        
        guard count != 0 else {
            count += 1
            return true
        }
        guard count < 4 else {
            count = 0
            return false
        }
        count += 1
        return false
    }
}






