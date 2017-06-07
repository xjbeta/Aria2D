//
//  Baidu.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/14.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Just

class Baidu: NSObject {
	
	static let shared = Baidu()
	private override init() {
		
	}
	
	var isLogin = false {
		didSet {
			NotificationCenter.default.post(name: .updateUserInfo, object: self)
			NotificationCenter.default.post(name: .resetLeftOutlineView, object: self)
		}
	}
	var isTokenEffective = true {
		didSet {
			if isTokenEffective {
				Preferences.shared.baiduFolder = ""
				Preferences.shared.baiduToken = ""
				mainPath = "/"
				selectedPath = mainPath
				NotificationCenter.default.post(name: .updateToken, object: self)
			} else {
				checkAppsFolder {
					if $0 {
						self.getAppsFolderPath()
					}
				}
			}
		}
	}

	let userAgent = ["User-Agent": "netdisk"]

	
	@objc dynamic var mainPath: String = {
		return Preferences.shared.baiduFolder == "" ? "/" : Preferences.shared.baiduFolder
	}()
	
	var selectedPath = Preferences.shared.baiduFolder == "" ? "/" : Preferences.shared.baiduFolder {
		didSet {
			getFileList(forPath: selectedPath)
		}
	}
	
	
	let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
	
	func updateCookie(_ block: @escaping () -> Void) {
		Just.get("https://pan.baidu.com") { _ in
			block()
		}
	}
	
	func getUserInfo(_ block:@escaping (_ userName: String, _ userImage: NSImage, _ capacityInfo: String) -> Void) {
		Just.get("https://pan.baidu.com/wap/home", headers: userAgent) {
			let str = $0.text ?? ""
			let userName = str.subString(from: "<h3 class=\"name\">", to: "</h3>")
			let imageUrl = str.subString(from: "<img src=\"", to: "\" alt=\"\(userName)\"/>")
			let capacityInfo = str.subString(from: "<p class=\"capacity\">", to: "</p>").replacingOccurrences(of: "\n", with: "")
			
			var userImage = NSImage()
			
			Just.get(imageUrl) {
				if let image = NSImage(data: $0.content!) {
					image.size = NSSize(width: 70, height: 70)
					userImage = image
					block(userName, userImage, capacityInfo)
				}
			}
		}
	}
	
	
	//MARK: - Login And LogOut
	func checkLogin(_ block: ((_ isLogin: Bool) -> Void)?) {
		Just.post("https://pan.baidu.com/api/quota", headers: userAgent) {
			self.isLogin = JSON($0.json ?? [])["errno"].intValue == 0
			block?(self.isLogin)
			if self.isLogin {
				self.checkToken(nil)
			}
		}
	}
	
	func logout(_ block:@escaping () -> Void) {
		Just.get("https://wappass.baidu.com/passport?logout") { _ in
			self.isLogin = false
			self.isTokenEffective = true
			block()
		}
	}
	
	//MARK: - GetFileList
	func getFileList(forPath path: String) {
		ViewControllersManager.shared.waiting = true
		let encodePath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "/"
		Just.get("https://pan.baidu.com/api/list?dir=" + encodePath, headers: userAgent) {
			let json = JSON($0.json ?? [])
			if json["errno"].intValue == 0 {
				DataManager.shared.setData(forBaidu: json, forPath: path)
			} else if json["errno"].intValue == -9 {
				self.selectedPath = self.mainPath
			}
			ViewControllersManager.shared.waiting = false
		}
	}
	
}
//MARK: PCS
extension Baidu {
	//MARK: - GetDownloadUrl  PCS
	
	func checkToken(_ block: ((_ t: Bool) -> Void)?) {
		let params = ["method": "info",
		              "access_token": Preferences.shared.baiduToken]
		Just.get("https://pcs.baidu.com/rest/2.0/pcs/quota?", params: params) {
			self.isTokenEffective = JSON($0.json ?? [])["error_code"].exists()
			block?(self.isTokenEffective)
		}
	}
	
	func delete(_ path: String) {
		let encodePath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "/"
		Just.post("https://pcs.baidu.com/rest/2.0/pcs/file?method=delete&access_token=\(Preferences.shared.baiduToken)&path=\(encodePath)") {
			let json = JSON($0.json ?? [])
			if json["error_code"].exists() {
				self.getFileList(forPath: self.selectedPath)
			} else {
				DataManager.shared.deleteBaiduObject(path)
			}
		}
	}
	
	
	func getDownloadUrls(FromPCS path: String, block: @escaping (_ dlinks: [String]) -> Void) {
		let URLString = ["https://pcs.baidu.com/rest/2.0/pcs/file?",
//		                 "https://d.pcs.baidu.com/rest/2.0/pcs/file?",
		                 "https://www.baidupcs.com/rest/2.0/pcs/file?",
		                 "https://www.baidupcs.com/rest/2.0/pcs/stream?",
		                 "https://c.pcs.baidu.com/rest/2.0/pcs/file?"]
		
		
		let encodePath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "/"
		let params = "method=download&access_token=\(Preferences.shared.baiduToken)&path=\(encodePath)"
		
		
		let urls = URLString.map {
			$0 + params
		}
		block(urls)
	}

	func getAppsFolderPath() {
		Just.get("https://pan.baidu.com/api/list?dir=/apps", headers: userAgent) {
			let json = JSON($0.json ?? [])
			if json["errno"] == 0 {
				let folders = json["list"].filter {
					$0.1["isdir"] == 1
					}.map {
						$0.1["path"].stringValue
					}
				folders.forEach { path in
					let encodePath = path.addingPercentEncoding(withAllowedCharacters: self.allowedCharacterSet) ?? ""
					
					Just.post("https://pcs.baidu.com/rest/2.0/pcs/file?method=list&access_token=\(Preferences.shared.baiduToken)&path=\(encodePath)", headers: self.userAgent) {
						let json = JSON($0.json ?? [])
						if !json["error_code"].exists(), Preferences.shared.baiduFolder != path {
							Preferences.shared.baiduFolder = path
							self.selectedPath = path
							self.mainPath = path
							NotificationCenter.default.post(name: .updateToken, object: self)
						}
					}
				}
			}
		}
	}
	
	func checkAppsFolder(_ block: @escaping (_ effective: Bool) -> Void) {
		let encodePath = Preferences.shared.baiduFolder.addingPercentEncoding(withAllowedCharacters: self.allowedCharacterSet) ?? ""
		Just.post("https://pcs.baidu.com/rest/2.0/pcs/file?method=list&access_token=\(Preferences.shared.baiduToken)&path=\(encodePath)", headers: self.userAgent) {
			let json = JSON($0.json ?? [])
			let effective = json["error_code"].exists()
			block(effective)
		}
	}
	
	
	func getToken() {
		
		
		
		
	}
	
	
}

