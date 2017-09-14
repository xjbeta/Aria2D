//
//  AboutAria2D.swift
//  Aria2D
//
//  Created by xjbeta on 2016/10/3.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import Quartz

class AboutAria2D: NSViewController {
	
	var previewPanel: QLPreviewPanel!
	
	let acknowledgementsPath: String = {
		if let resource = Bundle.main.resourcePath {
			return resource + "/Aria2D-acknowledgements.pdf"
		} else {
			return ""
		}
	}()
	
	@objc var appName: String {
		return Bundle.main.infoDictionary!["CFBundleExecutable"] as? String ?? ""
	}
	
	@objc var appVersion: String {
		let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
		let build = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? ""
		return "Version \(version) (\(build))"
	}
	
	@objc var appCopyright: String {
		return Bundle.main.infoDictionary!["NSHumanReadableCopyright"] as? String ?? ""
	}
	@IBAction func showCredits(_ sender: Any) {
		// Acknowledgements
//		Bundle.main.path(forResource: "Pods-Aria2D-acknowledgements", ofType: "pdf")
//		NSWorkspace.shared.open
		
		togglePreviewPanel()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
}

extension AboutAria2D: QLPreviewPanelDelegate, QLPreviewPanelDataSource {
	override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
		return true
	}
	
	override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
		previewPanel = panel
		previewPanel.delegate = self
		previewPanel.dataSource = self
	}
	
	override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
		previewPanel = nil
	}
	
	func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
		return 1
	}
	
	func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
		return URL(fileURLWithPath: acknowledgementsPath) as QLPreviewItem
	}
	
	func togglePreviewPanel() {
		guard FileManager.default.fileExists(atPath: acknowledgementsPath) else { return }
		
		if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible {
			QLPreviewPanel.shared().orderOut(self)
		} else {
			QLPreviewPanel.shared().makeKeyAndOrderFront(self)
			QLPreviewPanel.shared().reloadData()
		}
	}
	
}

