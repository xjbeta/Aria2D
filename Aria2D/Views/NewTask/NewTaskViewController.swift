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
		let show = showOptionsButton.state == .on
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
    
    
    var fileURL: URL? = nil {
        didSet {
            if let url = fileURL {
                self.setTorrentPath(url)
                self.showTorrentPath(true)
            }
        }
    }
    var torrentData: String {
        get {
            do {
                if let url = fileURL {
                    return try Data(contentsOf: url).base64EncodedString()
                }
            } catch { }
            return ""
        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		showOptionsStackView.isHidden = !enableOptions
		preferredContentSize = view.frame.size
		
		// init optionsView
		optionsView.isHidden = true
		optionsViewHeight.constant = 0
        if let url = fileURL {
            setTorrentPath(url)
            showTorrentPath(true)
        } else {
            showTorrentPath(false)
        }
		
    }
	
    lazy var openPanel = NSOpenPanel()
    
	func selectTorrentFile() {
		openPanel.canChooseFiles = true
		openPanel.allowedFileTypes = ["torrent"]
		openPanel.allowsMultipleSelection = false
		if let window = view.window {
			openPanel.beginSheetModal(for: window) { result in
                if result == .OK, let path = self.openPanel.url {
                    self.fileURL = path
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
			let image = NSWorkspace.shared.icon(forFileType: url.pathExtension)
			image.size = NSSize(width: 17, height: 17)
			self.fileInfoButton.image = image
			self.fileInfoButton.title = url.lastPathComponent
		}
	}
	
}

