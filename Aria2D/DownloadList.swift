//
//  DownloadList.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/19.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON

class DownloadList: NSViewController {

    @IBOutlet weak var downloadListTableView: NSTableView!

    @IBAction func cellDoubleAction(sender: AnyObject) {
        
        guard BackgroundTask.sharedInstance.selectedRow != 2 else {
            downloadListTableView.selectedRowIndexes.enumerateIndexesUsingBlock{ index, _ in
                
                let data = DataAPI.sharedInstance.data()[index]
                
                let path = "/users/" + NSUserName() + "/downloads/" + data.name
//                open file with Finder
//                NSWorkspace.sharedWorkspace().openFile(path, withApplication: "Finder")
                NSWorkspace.sharedWorkspace().openFile(path, withApplication: "Finder", andDeactivate: true)
                
                
//                show in Finder
//                NSWorkspace.sharedWorkspace().selectFile(path, inFileViewerRootedAtPath: "")
//                let url = NSURL(fileURLWithPath: path)
//                NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([url])

            }
            return
        }
        

        
        
        
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        webSocketNoticeSet()
        downloadListTableView.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DownloadList.changeSelectRow(_:)), name: "LeftSourceListSelection", object: nil)
        downloadListTableView.selectionHighlightStyle = .Regular
    }

    
    
    
    
}



// MARK: - TableView
extension DownloadList: NSTableViewDelegate, NSTableViewDataSource {

    

    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        return 60
    }
    
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        return DataAPI.sharedInstance.data().count
        
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let nib = NSNib(nibNamed: "CustomCell", bundle: nil)
        self.downloadListTableView.registerNib(nib, forIdentifier: "CustomCell")
        let view = downloadListTableView.makeViewWithIdentifier("CustomCell", owner: self) as! CustomCell
        
        setTableData(view, row: row)
        return view
    }
    
    
    
    
//    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
//        
//        return true
//        
//    }
    
    

    func tableViewSelectionDidChange(notification: NSNotification) {
        BackgroundTask.sharedInstance.selectedIndexs = downloadListTableView.selectedRowIndexes
    }




}



extension DownloadList {
    
    
    func setTableData(view: CustomCell, row: Int) {
        
        guard row > -1 && row < DataAPI.sharedInstance.data().count else {
            return
        }
        
        
        
        let data = DataAPI.sharedInstance.data()[row]

        
        view.downloadTaskName.stringValue = data.name
        view.totalLength.stringValue = data.totalLength
        view.fileIcon.image = NSWorkspace.sharedWorkspace().iconForFileType(data.fileType)

        
        if BackgroundTask.sharedInstance.selectedRow == 1 {
            view.progressIndicator.hidden = false
            
            view.progressIndicator.doubleValue = data.progressIndicator
            view.percentage.stringValue = data.percentage
            
            if data.status == "active" {
                view.time.stringValue = data.time
                view.status.stringValue = data.speed
            } else {
                view.time.stringValue = ""
                view.status.stringValue = data.status
            }
            
            
            
        } else if BackgroundTask.sharedInstance.selectedRow == 2 {
            view.progressIndicator.hidden = true
            view.time.stringValue = ""
            view.percentage.stringValue = ""
            view.status.stringValue = data.status
            
        }

        
        

    }
    
    
    func changeSelectRow(notification: NSNotification) {
        downloadListTableView.reloadData()
    }
    
    
    
    func reloadDataWithGID(gidList: [String]) {
        

        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
}




extension DownloadList {

    // MARK: - SetWebSocketNotice
    
    func webSocketNoticeSet() {
        
        
        Aria2Websocket.sharedInstance.onConnect = {
            
            
            
            
        }
        Aria2Websocket.sharedInstance.onDisconnect = { error in
            DataAPI.sharedInstance.resetData()
        }
        
        Aria2Websocket.sharedInstance.onData = { data in
            
            
            
        }
        
        
        WebsocketNotificationHandle.sharedInstance.updateTable = {
            
            if BackgroundTask.sharedInstance.selectedRow == 1 {
                
                switch DataAPI.sharedInstance.status() {
                case .setData:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.downloadListTableView.reloadData()
                    }
                case .update:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.reloadDownloadingCell(DataAPI.sharedInstance.activeCount())
                    }
                default:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.downloadListTableView.reloadData()
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.downloadListTableView.reloadData()
                }
            }

        }
    }
    
    
    
    func reloadDownloadingCell(count: Int) {
        guard count == 0 else {
            let rowIndexs = NSIndexSet(indexesInRange: NSRange(0..<count))
            let columnIndex = NSIndexSet(index: 0)
            downloadListTableView.reloadDataForRowIndexes(rowIndexs, columnIndexes: columnIndex)
            return
        }

    }
    
    
    
    
    

}







