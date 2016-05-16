//
//  Generalview.swift
//  Aria2D
//
//  Created by xjbeta on 16/5/5.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class Generalview: NSViewController {

    @IBAction func testbutton(sender: AnyObject) {
        popupButton.sizeToFit()
        
        if let item = popupButton.selectedItem as? MenuItemWithPath {
            print(item.path)
        }
        
        
    }
    @IBOutlet weak var popupButton: NSPopUpButton!
    @IBOutlet weak var downloadDirMenu: NSMenu!
    @IBOutlet weak var maxConcurrentDownloadsTextField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        
        setItems()
        
        
    }
    
    

    
    

}




extension Generalview {
    func setItems() {
        
        //        devicesList
        //        let listBase = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListFavoriteVolumes.takeUnretainedValue(), NSMutableDictionary())
        
        
        //        favouriteList
        let listBase = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListFavoriteItems.takeUnretainedValue(), nil).takeUnretainedValue()
        var seed:UInt32 = 0
        let itemsCF = LSSharedFileListCopySnapshot(listBase, &seed)
        let items = itemsCF.takeRetainedValue() as NSArray
        
        items.forEach { item in
            let name = LSSharedFileListItemCopyDisplayName(item as! LSSharedFileListItem).takeUnretainedValue()
            
            let path = LSSharedFileListItemCopyResolvedURL(item as! LSSharedFileListItem, 0, nil).takeUnretainedValue()
//            let itembutton = NSMenuItem(title: name as String, action: nil, keyEquivalent: "")
            
            let itembutton = MenuItemWithPath(title: String(name), path: path)
            
            
            if "\(path)" == "x-apple-finder:icloud" {
            } else if let path = (path as NSURL).relativePath {
                let image = NSWorkspace.sharedWorkspace().iconForFile(path)
                image.size.height = 16
                image.size.width = 16
                itembutton.image = image
                //                downloadDirMenu.addItem(itembutton)
                downloadDirMenu.insertItem(itembutton, atIndex: downloadDirMenu.itemArray.count - 2)
                
            }
        }
        
    }
}
