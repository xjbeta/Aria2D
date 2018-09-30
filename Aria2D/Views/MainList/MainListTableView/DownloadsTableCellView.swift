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
	var gid: String = ""
	var notificationToken: NotificationToken? = nil
	
    func setData(_ obj: Aria2Object) {
		gid = obj.gid
		setText(obj)
    }
	
	func setText(_ obj: Aria2Object) {
		filePath = URL(fileURLWithPath: obj.files.first?.path ?? "")
		downloadTaskName.stringValue = obj.nameString()
		if totalLength.integerValue == 0,
			downloadTaskName.stringValue == "Unknown",
			obj.totalLength != 0 || gid == "" {
			Aria2.shared.getFiles(obj.gid)
		}
		fileIcon.image = obj.fileIcon()
		
		totalLength.stringValue = obj.totalLength.ByteFileFormatter()
		switch ViewControllersManager.shared.selectedRow {
		case .downloading:
			if obj.status == .active {
				time.stringValue = timeFormat(obj.totalLength - obj.completedLength, speed: obj.downloadSpeed)
                
                if obj.bittorrent != nil, obj.totalLength == obj.completedLength {
                    status.stringValue = "⬆︎ \(obj.uploadSpeed.ByteFileFormatter())/s"
                } else {
                    status.stringValue = "\(obj.downloadSpeed.ByteFileFormatter())/s"
                }
			} else {
				time.stringValue = ""
				status.stringValue = obj.status.string()
			}
			if obj.status != .complete, obj.totalLength != 0 {
				progressIndicator.isHidden = false
				progressIndicator.doubleValue = Double(obj.completedLength) / Double(obj.totalLength) * 100
				percentage.stringValue = progressIndicator.doubleValue.percentageFormat()
			} else if obj.status == .active, obj.totalLength == 0 || obj.completedLength == 0 {
				progressIndicator.isHidden = false
				progressIndicator.doubleValue = 0
				percentage.stringValue = progressIndicator.doubleValue.percentageFormat()
				
			} else {
				progressIndicator.isHidden = true
				percentage.stringValue = ""
			}
		case .completed, .removed:
			progressIndicator.isHidden = true
			time.stringValue = ""
			percentage.stringValue = ""
			status.stringValue = obj.status.string()
		default:
			break
		}
	}
	
	func timeFormat(_ length: Int64, speed: Int64) -> String {
		if speed == 0 { return "INF" }
		
		let formatter = DateComponentsFormatter()
		formatter.zeroFormattingBehavior = .default
		formatter.allowedUnits = [.day, .hour, .minute, .second, .year]
		formatter.maximumUnitCount = 2
		formatter.unitsStyle = .abbreviated
		formatter.calendar?.locale = Locale(identifier: "en_US")
		
		var component = DateComponents()
		component.second = Int(length / speed)
		
		if let str = formatter.string(for: component) {
			return str.replacingOccurrences(of: " ", with: "")
		} else {
			return "INF"
		}
	}
	
	override func viewDidEndLiveResize() {
//		progressIndicator.wantsLayer = true
		progressIndicator.needsDisplay = true
	}
	
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
    
	deinit {
		notificationToken?.invalidate()
		gid = ""
	}
	
}
