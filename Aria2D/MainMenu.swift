//
//  MainMenu.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MainMenu: NSViewController {

    var newTaskWindow: NewTaskWindow!
    
    lazy var preferencesWindow: PreferencesWindow = {
        let wcSB = NSStoryboard(name: "Preferences", bundle: NSBundle.mainBundle())
        // or whichever bundle
        return wcSB.instantiateInitialController() as! PreferencesWindow
    }()
    
    
    
    
    @IBOutlet weak var pauseAllButton: NSMenuItem!
    @IBOutlet weak var unPauseAllButton: NSMenuItem!
    
    @IBOutlet weak var pauseOrUnpauseButton: NSMenuItem!
    

    
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(MainMenu.nextTag(_:)) {
            if BackgroundTask.sharedInstance.selectedRow == 1 {
                return true
            } else {
                return false
            }
        }
        
        if menuItem.action == #selector(MainMenu.previousTag(_:)) {
            if BackgroundTask.sharedInstance.selectedRow == 1 {
                return false
            } else {
                return true
            }
            
        }
        
        
        if menuItem.action == #selector(MainMenu.pauseOrUnpause(_:)) {
            if BackgroundTask.sharedInstance.selectedRow == 1 && BackgroundTask.sharedInstance.selectedIndexs.count > 0 {
                return true
            } else {
                return false
            }
            
        }
        
        
        if menuItem.action == #selector(MainMenu.pauseAll(_:)) {
            if BackgroundTask.sharedInstance.selectedRow == 1 {
                return true
            } else {
                return false
            }
            
        }
        if menuItem.action == #selector(MainMenu.unPauseAll(_:)) {
            if BackgroundTask.sharedInstance.selectedRow == 1 {
                return true
            } else {
                return false
            }
            
        }
        
        
        return true
    }
    
    
}

//MARK: Button Action
extension MainMenu {
    
    @IBAction func about(sender: AnyObject) {
    }
    
    @IBAction func preferences(sender: AnyObject) {
        preferencesWindow.showWindow(self)
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
        Aria2cAPI.sharedInstance.tellStatus()
    }
    
    @IBAction func delete(sender: AnyObject) {
        
        BackgroundTask.sharedInstance.selectedIndexs.enumerateIndexesUsingBlock { index, _ in
            
            // 越界
            let status = DataAPI.sharedInstance.data()[index].status
            let gid = DataAPI.sharedInstance.data()[index].gid
            
            if status == .complete || status == .error {
                Aria2cAPI.sharedInstance.removeDownloadResult(gid)
            } else {
                Aria2cAPI.sharedInstance.remove(gid)
            }
            
            
        }
    }
    
    
    
    @IBAction func pauseOrUnpause(sender: AnyObject) {
        if BackgroundTask.sharedInstance.selectedRow == 1 {
            if maxCount() == "pause" {
                pauseOrUnpauseButton.title = "pause"
                BackgroundTask.sharedInstance.selectedIndexs.enumerateIndexesUsingBlock { index, _ in
                    DataAPI.sharedInstance.data()[index].gid.pause()
                }
                
                
            } else if maxCount() == "unpause" {
                pauseOrUnpauseButton.title = "unpause"
                BackgroundTask.sharedInstance.selectedIndexs.enumerateIndexesUsingBlock { index, _ in
                    DataAPI.sharedInstance.data()[index].gid.unpause()
                }
            }
        }
        
        
        
    }
    
    
    @IBAction func pauseAll(sender: AnyObject) {
        Aria2cAPI.sharedInstance.pauseAll()
    }
    @IBAction func unPauseAll(sender: AnyObject) {
        Aria2cAPI.sharedInstance.unPauseAll()
    }
    
    @IBAction func showInFinder(sender: AnyObject) {
        
        BackgroundTask.sharedInstance.selectedIndexs.enumerateIndexesUsingBlock { index, _ in
            //            let path = DataAPI.sharedInstance.data()[index].
            
            
        }
        
        
        
    }
    
}





//MARK: Private
private extension MainMenu {
    
    func maxCount() -> String {
        let taskStatusCount = BackgroundTask.sharedInstance.taskStatusCount
        let x = taskStatusCount.active + taskStatusCount.waiting
        let y = taskStatusCount.paused
        
        var maxCount: String
        maxCount = x >= y ? "pause" : "unpause"

        return maxCount
    }
    
    
}

