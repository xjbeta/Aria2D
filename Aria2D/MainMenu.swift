//
//  MainMenu.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainMenu: NSViewController {

    @IBAction func about(sender: AnyObject) {
    }
    
    @IBAction func preferences(sender: AnyObject) {
        settingWindow = SettingWindow()
        settingWindow.showWindow(self)
    }
    
    @IBAction func addTask(sender: AnyObject) {
        newTaskWindow = NewTaskWindow()
        newTaskWindow.showWindow(self)
    }
    
    @IBAction func nextTag(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("nextTag", object: self)
    }

    @IBAction func previousTag(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("previousTag", object: self)
    }
    @IBAction func refresh(sender: AnyObject) {
        Aria2cMethods.sharedInstance.TellStatus()
    }
    
    @IBAction func delete(sender: AnyObject) {
        
        BackgroundTask.sharedInstance.selectedIndexs.enumerateIndexesUsingBlock { index, _ in
            
            // 越界
            let status = DataAPI.sharedInstance.data()[index].status
            let gid = DataAPI.sharedInstance.data()[index].gid
            
            if status == "complete" || status == "error" {
                Aria2cMethods.sharedInstance.removeDownloadResult(gid)
            } else {
                Aria2cMethods.sharedInstance.remove(gid)
            }
            
            
        }
    }
    
    @IBAction func pause(sender: AnyObject) {
        if BackgroundTask.sharedInstance.selectedRow == 1 {
            BackgroundTask.sharedInstance.selectedIndexs.enumerateIndexesUsingBlock { index, _ in
                let gid = DataAPI.sharedInstance.data()[index].gid
                Aria2cMethods.sharedInstance.pause(gid)
            }
        }
    }
    
    
    @IBAction func unpause(sender: AnyObject) {
        if BackgroundTask.sharedInstance.selectedRow == 1 {
            BackgroundTask.sharedInstance.selectedIndexs.enumerateIndexesUsingBlock { index, _ in
                let gid = DataAPI.sharedInstance.data()[index].gid
                Aria2cMethods.sharedInstance.unpause(gid)
            }
        }
    }
    
    var newTaskWindow: NewTaskWindow!
    var settingWindow: SettingWindow!
    
    @IBOutlet weak var pauseButton: NSMenuItem!
    @IBOutlet weak var unPauseButton: NSMenuItem!
    
    
    func setButton(notification: NSNotification) {
        let row = notification.userInfo!["selectedRow"] as? Int
        if row == 1 {
            pauseButton.enabled = true
            unPauseButton.enabled = true
        } else {
            pauseButton.enabled = false
            unPauseButton.enabled = false
        }
    }
    
    
}
