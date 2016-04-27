//
//  LogText.swift
//  Aria2D
//
//  Created by xjbeta on 16/4/26.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class LogText: NSViewController, NSTextViewDelegate {

    @IBOutlet var textView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.string = "\n\n\n\n\n\n\n\n\n\n\n\n\n\nwqwqwqwqwqwqwqwq"

        textView.scrollToEndOfDocument(self)
        
        
    }
    
    
    
//    func stringByAppendingString(aString: String) -> String {
//        
//    }
    
    
    
}
