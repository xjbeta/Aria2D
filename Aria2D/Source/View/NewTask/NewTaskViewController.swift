//
//  NewTaskViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2016/9/29.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {

	@IBAction func selectTorrent(_ sender: Any) {
		selectTorrentFile()
	}

	@IBAction func download(_ sender: Any) {
		if !torrentTask, taskUrl.stringValue != "" {
			Aria2.shared.addUri(taskUrl.stringValue)
			
		} else if torrentTask, torrentData != "" {
			Aria2.shared.addTorrent(torrentData)
		}
		dismiss(self)
	}
	
	@IBOutlet var showOptionsButton: NSButton!
	@IBAction func showOptions(_ sender: Any) {
		let show = showOptionsButton.state == NSOnState
		NSAnimationContext.runAnimationGroup({
			$0.duration = 0.15
			self.optionsView.isHidden = false
			self.optionsViewHeight.animator().constant = show ? 250 : 0
		}) {
			self.optionsView.isHidden = !show
		}
	}
	
	@IBOutlet var optionsView: NSView!
	@IBOutlet var taskUrl: TaskUrl!
	@IBOutlet var viewForPathControl: NSView!
	@IBOutlet var fileInfoButton: NSButton!
	
	@IBOutlet var viewHeight: NSLayoutConstraint!
	@IBOutlet var optionsViewHeight: NSLayoutConstraint!
	
	@IBOutlet var optionsPredicateEditor: NSPredicateEditor!

	@IBOutlet var optionsRuleEditor: NSRuleEditor!
	
	@IBOutlet var showOptionsStackView: NSStackView!
	
	let enableOptions = false
	
	var torrentTask = false
	var torrentData = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		showOptionsStackView.isHidden = !enableOptions
		showTorrentPath(false)
		preferredContentSize = view.frame.size
		
		// init optionsView
		optionsView.isHidden = true
		optionsViewHeight.constant = 0
		
		
//		optionsRuleEditor.setCriteria([1, 2, 3], andDisplayValues: [1, 2, 3], forRowAt: 0)
    }
	
	func selectTorrentFile() {
		let openPanel = NSOpenPanel()
		openPanel.canChooseFiles = true
		openPanel.allowedFileTypes = ["torrent"]
		openPanel.allowsMultipleSelection = false
		if let window = view.window {
			openPanel.beginSheetModal(for: window) { result in
				if result == NSFileHandlingPanelOKButton, let path = openPanel.url {
					do {
						self.torrentData = try Data(contentsOf: path).base64EncodedString()
						self.setTorrentPath(path)
						self.showTorrentPath(true)
					} catch {
						return
					}
				}
			}
		}
	}
	
	func showTorrentPath(_ bool: Bool) {
		torrentTask = bool
		DispatchQueue.main.async {
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.12
				self.fileInfoButton.isHidden = !bool
				self.taskUrl.isHidden = bool
				self.viewHeight.animator().constant = bool ? 20 : 70
			}, completionHandler: nil)
		}
	}
	
	func setTorrentPath(_ url: URL) {
		DispatchQueue.main.async {
			let image = NSWorkspace.shared().icon(forFileType: url.pathExtension)
			image.size = NSSize(width: 17, height: 17)
			self.fileInfoButton.image = image
			self.fileInfoButton.title = url.lastPathComponent
		}
	}
	
}

extension NewTaskViewController: NSRuleEditorDelegate {
	
	func ruleEditor(_ editor: NSRuleEditor, numberOfChildrenForCriterion criterion: Any?, with rowType: NSRuleEditorRowType) -> Int {
		return 5
	}
	
	func ruleEditor(_ editor: NSRuleEditor, child index: Int, forCriterion criterion: Any?, with rowType: NSRuleEditorRowType) -> Any {
		
		return ""
	}
	
	func ruleEditor(_ editor: NSRuleEditor, displayValueForCriterion criterion: Any, inRow row: Int) -> Any {
		
		return ""
	}
	
	
}
