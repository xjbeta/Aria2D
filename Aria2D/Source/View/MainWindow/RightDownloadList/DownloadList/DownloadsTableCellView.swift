//
//  DownloadsTableCellView.swift
//  Aria2D
//
//  Created by xjbeta on 16/6/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class DownloadsTableCellView: NSTableCellView {

    @IBOutlet var downloadTaskName: NSTextField!
    @IBOutlet var totalLength: NSTextField!
    @IBOutlet var fileIcon: NSImageView!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var time: NSTextField!
    @IBOutlet var percentage: NSTextField!
    @IBOutlet var status: NSTextField!

    var filePath: URL!
	var gid: GID = ""
	var rowNumber = -1
	var notificationToken: NotificationToken? = nil
	
	let folderIcon = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
	
	override var isOpaque: Bool {
		return true
	}
	
	
    func setData(_ data: TaskObject) {
		gid = data.gid
		setText(data)
		notificationToken = data.addNotificationBlock {
			switch $0 {
			case .change:
				if let data = DataManager.shared.data(TaskObject.self).filter ({
					$0.gid == self.gid
				}).first {
					self.setText(data)
				}
			default:
				break
			}
		}
		
    }
	
	func setText(_ data: TaskObject) {
		let path = URL(fileURLWithPath: data.path)
		filePath = path
		downloadTaskName.stringValue = {
			let name = path.lastPathComponent
			if name != "Data" {
				return name
			} else {
				if data.totalLength != 0 {
					Aria2.shared.getFiles([data.gid])
				}
				return "Unknown"
			}
		}()
		
		let image: NSImage = {
			var image = NSImage()
			if data.isBitTorrent, path.pathExtension == "" {
				image = folderIcon
			} else {
				image = NSWorkspace.shared.icon(forFileType: path.pathExtension)
			}
			image.size = NSSize(width: 35, height: 35)
			return image
		}()
		fileIcon.image = image
		
		totalLength.integerValue = data.totalLength
		switch ViewControllersManager.shared.selectedRow {
		case .downloading:
			if data.status == "active" {
				time.stringValue = data.time
				status.stringValue = data.speed
			} else {
				time.stringValue = ""
				status.stringValue = data.status
			}
			
			if data.progressIndicator == 0 && data.status != "active" {
				progressIndicator.isHidden = true
				percentage.stringValue = ""
			} else {
				progressIndicator.isHidden = false
				progressIndicator.doubleValue = data.progressIndicator
				percentage.stringValue = data.percentage
			}
		case .completed, .removed:
			progressIndicator.isHidden = true
			time.stringValue = ""
			percentage.stringValue = ""
			status.stringValue = data.status
		default:
			break
		}
		

	}
	
	
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
	
	
	deinit {
		notificationToken?.stop()
		gid = ""
	}
	
}
