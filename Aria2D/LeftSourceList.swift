//
//  LeftSourceList.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/21.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa





class LeftSourceList: NSViewController {


    @IBOutlet weak var leftSourceList: NSOutlineView!
    
    let list = List(name: "Download", icon: nil)

    

    
    override func viewDidLoad() {
        super.viewDidLoad()


        
        let downloading = Object(name: "正在下载", icon: NSImage(named: "NSPrivateChaptersTemplate"))
        let completed = Object(name: "已完成", icon: NSImage(named: "NSMenuOnStateTemplate"))

        list.object.append(downloading)
        list.object.append(completed)
        
        
        leftSourceList.reloadData()
        leftSourceList.expandItem(list)
        
        selectItem(leftSourceList.itemAtRow(1))
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LeftSourceList.nextTag), name: "nextTag", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LeftSourceList.previousTag), name: "previousTag", object: nil)
        
    }
    
    
    
    
    
    
    

    
    func selectItem(item: AnyObject?) {
        let itemIndex: Int = leftSourceList.rowForItem(item)
        guard itemIndex < 0 else {
            leftSourceList.selectRowIndexes(NSIndexSet(index: itemIndex), byExtendingSelection: false)
            return
        }
    }
    
    
    func nextTag() {
        let index = leftSourceList.selectedRow
        guard index >= 2 else {
            selectItem(leftSourceList.itemAtRow(index + 1))
            return
        }
        
        
    }
    
    func previousTag() {
        let index = leftSourceList.selectedRow
        guard index < 2 else {
            selectItem(leftSourceList.itemAtRow(index - 1))
            return
        }
    }
    
    
    
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName("LeftSourceListSelection", object: self, userInfo: ["selectedRow": leftSourceList.selectedRow])
    }
    
    

}


extension LeftSourceList: NSOutlineViewDataSource {
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {

        guard let _ = item else {
            return list
        }
        guard let child: AnyObject = list.object[index] else {
            return self
        }
        
        return child
    }
    
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        guard let list = item as? List else {
            return false
        }
        return (list.object.count > 0) ? true : false
        
        
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil { return 1 }
        guard let _ = item as? List else {
            return 0
        }
        return list.object.count
        
        
        
    }
    
    
    
}

extension LeftSourceList: NSOutlineViewDelegate {
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) ->NSView? {
        
        guard let list = item as? SourceListItemDisplayable,
            view = outlineView.makeViewWithIdentifier(list.cellID(), owner: self) as? NSTableCellView else {
                return nil
        }
        if let textField = view.textField {
            textField.stringValue = list.name
        }
        if let imageView = view.imageView {
            imageView.image = list.icon
        }
        return view
        
        
    }
    
    
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return item is List
    }
    
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
//        
//        let itemIndex: Int = LeftSourceList.rowForItem(item)
//        
//        print("itemIndex\(itemIndex)")
        
        return !self.outlineView(outlineView, isGroupItem: item)
    }

    
    
    
    
    
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        
        guard let _ = item as? Object else {
            return 15
        }
        return 40
    }
    
    
    func outlineView(outlineView: NSOutlineView, shouldShowOutlineCellForItem item: AnyObject) -> Bool {
        return false
    }
    
}




