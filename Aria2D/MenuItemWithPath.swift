//
//  MenuItemWithPath.swift
//  Aria2D
//
//  Created by xjbeta on 16/5/15.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class MenuItemWithPath: NSMenuItem {
        
    var path = NSURL()

    convenience init(title aString: String, path aURL: NSURL) {
        self.init()
        title = aString
        path = aURL
        
    }
    

}
