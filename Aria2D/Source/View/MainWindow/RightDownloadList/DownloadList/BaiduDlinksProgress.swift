//
//  BaiduDlinksProgress.swift
//  Aria2D
//
//  Created by xjbeta on 16/9/17.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import Just

protocol BaiduDlinksDataSource {
	func selectedObjects() -> [BaiduFileObject]
}


class BaiduDlinksProgress: NSViewController {
	var dataSource: BaiduDlinksDataSource?
	
	
	@IBOutlet var downloadButton: NSButton!
	
	@IBAction func cancel(_ sender: Any) {
		self.dismiss(self)
	}
	
	@IBAction func downloadTasks(_ sender: Any) {
		dlinks.forEach {
			Aria2.shared.addUri(fromBaidu: $0[0] as! [String], name: $0[1] as! String)
		}
		self.dismiss(self)
	}
	let group = DispatchGroup()
	let queue = DispatchQueue(label: "com.xjbeta.Aria2D.getDlinksQueue")
	var dlinks: [[Any]] = []
	
	override func viewDidAppear() {
		super.viewDidAppear()
		self.getDlinks()
		downloadButton.isEnabled = false
	}
	
	func getDlinks() {
		if let data = dataSource?.selectedObjects() {
			dlinks = [[Any]](repeating: [], count: data.count)
			data.map {
				$0.path
				}.enumerated().forEach { i, path in
					group.enter()
					Baidu.shared.getDownloadUrls(FromPCS: path) {
						self.dlinks[i] = [$0, URL(fileURLWithPath: path).lastPathComponent]
						self.group.leave()
					}
			}
			
			group.notify(queue: .main) {
				self.downloadButton.isEnabled = true
			}
		}
	}
	
}
