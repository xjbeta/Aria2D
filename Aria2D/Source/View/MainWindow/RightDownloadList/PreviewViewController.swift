//
//  PreviewViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/7.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON

protocol PreviewViewDataSource {
	func dataOfPreviewObjects() -> [TaskObject]
	func selectedRowIndexes() -> IndexSet
}

protocol PreviewViewDelegate {
	func preview(handel event: NSEvent)
}



class PreviewViewController: NSViewController {

	@IBOutlet var iconImage: MovableImageView!
	@IBOutlet var titleTextField: NSTextField!
	
	@IBOutlet var statusTextField: NSTextField!
	
	@IBOutlet var connectionsTextField: NSTextField!
	@IBOutlet var totalLengthTextField: NSTextField!
	@IBOutlet var completedLengthTextField: NSTextField!
	@IBOutlet var uploadLengthTextField: NSTextField!
	@IBOutlet var gidTextField: DoubleClickTextField!
	
	@IBOutlet var infoStackView: NSStackView!
	@IBOutlet var loadingProgressIndicator: NSProgressIndicator!
	var dataSource: PreviewViewDataSource?
	var delegate: PreviewViewDelegate?
	
	private var selectedIndex = 0
	
	var isVisible = false

	override func viewWillAppear() {
		super.viewWillAppear()
		infoStackView.isHidden = true
		reloadData()
	}
	

	
    override func viewDidLoad() {
        super.viewDidLoad()
		isVisible = true
		preferredContentSize = view.frame.size
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
			if self.isVisible {
				switch $0.keyCode {
				case 49, 123, 124:
					self.keyDown(with: $0)
					return nil
				case 125, 126:
					self.delegate?.preview(handel: $0)
					self.reloadData()
					return nil
				default:
					break
				}
			}
			return $0
		}
    }
	
	

	
	
	override func keyDown(with event: NSEvent) {
		if event.keyCode == 49 {
			dismiss(self)
			isVisible = false
			selectedIndex = 0
			return
		}
		
		if let objects = dataSource?.dataOfPreviewObjects() {
			if event.keyCode == 123 {
				if objects.count > 1 {
					selectedIndex -= 1
					if selectedIndex == -1 {
						selectedIndex = objects.count - 1
					}
					reloadData()
					return
				}
			} else if event.keyCode == 124 {
				if objects.count > 1 {
					selectedIndex += 1
					if selectedIndex == objects.count {
						selectedIndex = 0
					}
					reloadData()
					return
				}
			}
		}
	}
	
	func reloadData() {
		showLoadingProgressIndicator(true)
		if let data = dataSource?.dataOfPreviewObjects()[safe: selectedIndex] {
			titleTextField.stringValue = URL(fileURLWithPath: data.path).lastPathComponent
			let folderIcon = NSWorkspace.shared.icon(forFileType: URL(fileURLWithPath: data.path).pathExtension)
			folderIcon.size = NSSize(width: 255, height: 255)
			iconImage.image = folderIcon
			view.needsDisplay = true
			Aria2.shared.initData([data.gid]) {
				self.setData($0["result"][0][0])
				self.showLoadingProgressIndicator(false)
			}
		}
	}
	
	func setData(_ obj: JSON) {
		DispatchQueue.main.async {
			self.statusTextField.stringValue = obj["status"].stringValue
			self.connectionsTextField.stringValue = obj["connections"].stringValue
			self.totalLengthTextField.stringValue = obj["totalLength"].int64Value.ByteFileFormatter()
			self.completedLengthTextField.stringValue = obj["completedLength"].int64Value.ByteFileFormatter()
			self.uploadLengthTextField.stringValue =  obj["uploadLength"].int64Value.ByteFileFormatter()
			self.gidTextField.stringValue = obj["gid"].stringValue
		}
	}
	
	func showLoadingProgressIndicator(_ show: Bool) {
		DispatchQueue.main.async {
			self.infoStackView.isHidden = show
			if show {
				self.loadingProgressIndicator.startAnimation(self)
			} else {
				self.loadingProgressIndicator.stopAnimation(self)
			}
			self.loadingProgressIndicator.isHidden = !show
			self.view.display()
		}
	}
	
	
}
