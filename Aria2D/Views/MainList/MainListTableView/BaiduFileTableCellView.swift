//
//  BaiduFileListCell.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/16.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class BaiduFileTableCellView: NSTableCellView {
    @IBOutlet var icon: NSImageView!
    @IBOutlet var fileName: NSTextField!
    @IBOutlet var size: NSTextField!
    @IBOutlet var dateModified: NSTextField!


	var selected = false
	let folderIcon = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
	
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
	}
	
	var fsid = ""
	
	
    func setData(_ data: PCSFile) {
        
        guard !data.isBackButton else {
            fileName.stringValue = ".."
            size.stringValue = ""
            dateModified.stringValue = ""
            folderIcon.size = NSSize(width: 28, height: 28)
            icon.image = folderIcon
			fsid = "\(data.fsID)"
            return
        }
		
        fileName.stringValue = URL(fileURLWithPath: data.path).lastPathComponent
		
		dateModified.objectValue = data.serverMtime
		
        if data.isdir {
            folderIcon.size = NSSize(width: 28, height: 28)
            icon.image = folderIcon
            size.stringValue = ""
        } else {
			let image = NSWorkspace.shared.icon(forFileType: URL(fileURLWithPath: data.path).pathExtension)
            image.size = NSSize(width: 28, height: 28)
            icon.image = image
			size.stringValue = data.size.ByteFileFormatter()
        }
		fsid = "\(data.fsID)"
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
	
}
