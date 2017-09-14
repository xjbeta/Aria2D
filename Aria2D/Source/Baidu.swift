//
//  Baidu.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/14.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import Just

class Baidu: NSObject {
	
	static let shared = Baidu()
	private override init() {
		
	}
	
	var isLogin = false {
		didSet {
			NotificationCenter.default.post(name: .updateUserInfo, object: nil)
			NotificationCenter.default.post(name: .resetLeftOutlineView, object: nil)
		}
	}
	var isTokenEffective = false {
		didSet {
			if isTokenEffective {
				checkAppsFolder {
					if $0 {
						self.getAppsFolderPath()
					}
				}
			} else {
				Preferences.shared.baiduFolder = ""
				Preferences.shared.baiduToken = ""
				mainPath = "/"
				selectedPath = mainPath
				NotificationCenter.default.post(name: .updateToken, object: nil)
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
			if let errno = $0.content?.decode(PCSErrno.self)?.errno {
				self.isLogin = errno == 0
			}
			
			block?(self.isLogin)
			if self.isLogin {
				self.checkToken(nil)
			}
		}
	}
	
	func logout(_ block:@escaping () -> Void) {
		Just.get("https://wappass.baidu.com/passport?logout") { _ in
			self.isLogin = false
			self.isTokenEffective = false
			block()
		}
	}
	
	//MARK: - GetFileList
	func getFileList(forPath path: String) {
		ViewControllersManager.shared.waiting = true
		let encodePath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "/"
		Just.get("https://pan.baidu.com/api/list?dir=" + encodePath, headers: userAgent) {
			if let json = $0.content?.decode(PCSFileList.self) {
				if json.errno == 0 {
					DataManager.shared.setData(forBaidu: json.list, forPath: path)
				} else if json.errno == -9 {
					self.selectedPath = self.mainPath
				}
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
			if let error = $0.content?.decode(PCSError.self) {
				self.isTokenEffective = !error.isError
			} else {
				self.isTokenEffective = false
			}
			block?(self.isTokenEffective)
		}
	}
	
	func delete(_ path: String) {
		let encodePath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "/"
		Just.post("https://pcs.baidu.com/rest/2.0/pcs/file?method=delete&access_token=\(Preferences.shared.baiduToken)&path=\(encodePath)") {
			if let error = $0.content?.decode(PCSError.self),
				!error.isError {
					DataManager.shared.deletePCSFile(path)
				} else {
					self.getFileList(forPath: self.selectedPath)
			}
		}
	}
	
	
	func getDownloadUrls(FromPCS path: String, block: @escaping (_ dlinks: [String]) -> Void) {
		let URLString = ["https://pcs.baidu.com/rest/2.0/pcs/file?",
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
			if let json = $0.content?.decode(PCSFileList.self),
				json.errno == 0 {
				json.list.filter {
					$0.isdir == true
					}.map {
						$0.path
				}.forEach { path in
					let encodePath = path.addingPercentEncoding(withAllowedCharacters: self.allowedCharacterSet) ?? ""
					Just.post("https://pcs.baidu.com/rest/2.0/pcs/file?method=list&access_token=\(Preferences.shared.baiduToken)&path=\(encodePath)", headers: self.userAgent) {
						if let error = $0.content?.decode(PCSError.self),
							!error.isError,
							Preferences.shared.baiduFolder != path {
								Preferences.shared.baiduFolder = path
								self.selectedPath = path
								self.mainPath = path
								NotificationCenter.default.post(name: .updateToken, object: nil)
						}
					}
				}
			}
		}
	}
	
	func checkAppsFolder(_ block: @escaping (_ effective: Bool) -> Void) {
		let encodePath = Preferences.shared.baiduFolder.addingPercentEncoding(withAllowedCharacters: self.allowedCharacterSet) ?? ""
		Just.post("https://pcs.baidu.com/rest/2.0/pcs/file?method=list&access_token=\(Preferences.shared.baiduToken)&path=\(encodePath)", headers: self.userAgent) {
			if let error = $0.content?.decode(PCSError.self) {
				block(error.isError)
			} else {
				block(true)
			}
		}
	}
	
}
