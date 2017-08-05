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
		notificationToken = obj.addNotificationBlock {
			switch $0 {
			case .change:
				if let data = DataManager.shared.data(Aria2Object.self).filter ({
					$0.gid == self.gid
				}).first {
					self.setText(data)
				}
			default:
				break
			}
		}
		if obj.path() == nil {
			Aria2.shared.getFiles(obj.gid)
		}
    }
	
	func setText(_ obj: Aria2Object) {
		filePath = URL(fileURLWithPath: obj.files.first?.path ?? "")
		downloadTaskName.stringValue = obj.path()?.lastPathComponent ?? "Unknown"
		if totalLength.integerValue == 0,
			downloadTaskName.stringValue == "Unknown",
			obj.totalLength != 0 || gid == "" {
			Aria2.shared.getFiles(obj.gid)
		}
		
		fileIcon.image = {
			var image = NSImage()
			if obj.files.count > 1 || obj.bittorrent?.mode == .multi {
				image = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
			} else {
				image = NSWorkspace.shared.icon(forFileType: URL(fileURLWithPath: downloadTaskName.stringValue).pathExtension)
			}
			
			image.size = NSSize(width: 35, height: 35)
			return image
		}()
		totalLength.stringValue = obj.totalLength.ByteFileFormatter()
		switch ViewControllersManager.shared.selectedRow {
		case .downloading:
			if obj.status == .active {
				time.stringValue = timeFormat(obj.totalLength - obj.completedLength, speed: obj.downloadSpeed)
				status.stringValue = "\(obj.downloadSpeed.ByteFileFormatter())/s"
			} else {
				time.stringValue = ""
				status.stringValue = obj.status.string()
			}
			if obj.status == .active, obj.totalLength != 0, obj.completedLength != 0 {
				progressIndicator.isHidden = false
				progressIndicator.doubleValue = Double(obj.completedLength) / Double(obj.totalLength) * 100
				percentage.stringValue = "\(percentageFormat(progressIndicator.doubleValue))%"
			} else if obj.status == .active, obj.totalLength == 0 || obj.completedLength == 0 {
				progressIndicator.isHidden = false
				progressIndicator.doubleValue = 0
				percentage.stringValue = "\(percentageFormat(progressIndicator.doubleValue))%"
				
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
	
	
	func percentageFormat(_ double: Double) -> String {
		var str = String(format: "%.1f", Float(double))
		if str.hasSuffix(".0") {
			let range = str.characters.index(str.endIndex, offsetBy: -2)..<str.endIndex
			str.removeSubrange(range)
		}
		return str
	}
	
	
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
	
	override var isOpaque: Bool {
		return true
	}
	
	deinit {
		notificationToken?.stop()
		gid = ""
	}
	
}



extension Aria2Object {
	
	func path() -> URL? {
		if let name = bittorrent?.name, dir != "", name != "" {
			return URL(fileURLWithPath: dir + name)
		}
		if let path = files.first?.path {
			return URL(fileURLWithPath: path)
		}
		return nil
	}
	
}
