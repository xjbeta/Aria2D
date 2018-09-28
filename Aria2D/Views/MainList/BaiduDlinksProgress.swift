//
//  BaiduDlinksProgress.swift
//  Aria2D
//
//  Created by xjbeta on 16/9/17.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

protocol BaiduDlinksDataSource {
	func selectedObjects() -> [Int]
}

class BaiduDlinksProgress: NSViewController {
	var dataSource: BaiduDlinksDataSource?
	
	@IBOutlet var downloadButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var infoTextField: NSTextField!
    
	@IBAction func cancel(_ sender: Any) {
		self.dismiss(self)
	}
	
	@IBAction func downloadTasks(_ sender: Any) {
        dlinks.forEach {
            Aria2.shared.addUri(fromBaidu: $0.dlinks, name: $0.fileName, md5: $0.md5)
        }
		self.dismiss(self)
	}
    
	var dlinks: [Baidu.BaiduDlink] = []
	
	override func viewDidAppear() {
		super.viewDidAppear()
        downloadButton.isEnabled = false
        progressIndicator.startAnimation(nil)
        progressIndicator.isHidden = false
        guard let fsIds = dataSource?.selectedObjects() else { return }
        infoTextField.stringValue = "Preparing download links."
        var shareId: [Int] = []
        Baidu.shared.creatShareLink(fsIds).then {
            Baidu.shared.getSharedLinkInfo($0)
            }.get {
                shareId = [$0.shareid]
            }.then {
                Baidu.shared.getDlinks($0, fsIds: fsIds)
            }.done(on: .main) {
                self.dlinks = $0
                self.downloadButton.isEnabled = true
                self.infoTextField.stringValue = "Enjoy your downloads."
            }.ensure(on: .main) {
                self.progressIndicator.isHidden = true
            }.then {
                Baidu.shared.cancelSharing(_list: shareId)
            }.catch(on: .main) { error in
                switch error {
                case BaiduHTTPError.shareFileError:
                    self.infoTextField.stringValue = "Failed to creat share link."
                case BaiduHTTPError.cantFindInfoInShareLink:
                    self.infoTextField.stringValue = "Failed to get parameters in share link."
                case BaiduHTTPError.cantGenerateDlinks:
                    self.infoTextField.stringValue = "Failed to generate dlinks."
                case BaiduHTTPError.cancelSharingError:
                    self.infoTextField.stringValue = "Failed to cancel sharing."
                default:
                    self.infoTextField.stringValue = "Unknown error."
                    Log("Unknown error when generate download lisks \(error)")
                }
        }
	}
}
