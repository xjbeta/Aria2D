//
//  LeftSourceListData.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/25.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

protocol SourceListItemDisplayable: class {
    var name: String { get }
    var icon: NSImage? { get }
    func cellID() -> String
    func count() -> Int
}


extension SourceListItemDisplayable {
    func cellID() -> String { return "DataCell" }
    func count() -> Int { return 0 }
}


class List: NSObject, SourceListItemDisplayable {
    let name:String
    let icon:NSImage?
    var object:[Object] = []
    
    func cellID() -> String {
        return "HeaderCell"
    }
    
    func count() -> Int {
        return object.count
    }
    
    init(name: String, icon: NSImage?) {
        self.name = name
        self.icon = icon
    }
}

class Object: NSObject, SourceListItemDisplayable {
    let name: String
    let icon: NSImage?
    
    init(name: String, icon: NSImage?) {
        self.name = name
        self.icon = icon
        super.init()
    }
}
