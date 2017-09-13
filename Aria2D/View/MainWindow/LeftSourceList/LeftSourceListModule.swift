//
//  LeftSourceListNode.swift
//  Aria2D
//
//  Created by xjbeta on 16/7/7.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

protocol LeftSourceListBaseObject: class {
    var name: String { get }
    var icon: NSImage? { get }
    var cellID: String { get }
}

class LeftSourceListNode: LeftSourceListBaseObject {
    let name: String
    let icon: NSImage?
    var children = [LeftSourceListNodeChild]()
    let cellID = "NodeCell"
    init(name: String, icon: NSImage?) {
        self.name = name
        self.icon = icon
    }
}

class LeftSourceListNodeChild: LeftSourceListBaseObject {
    let name: String
    let icon: NSImage?
    let cellID = "ChildCell"
    init(name: String, icon: NSImage?) {
        self.name = name
        icon?.size.height = 13
        icon?.size.width = 13
        self.icon = icon
    }
}