//
//  Baidu.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/14.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftHTTP

class Baidu: NSObject {
	
	static let shared = Baidu()
	private override init() {
        HTTP.globalRequest {
            $0.timeoutInterval = 2
            $0.addValue("netdisk", forHTTPHeaderField: "User-Agent")
        }
	}
    
    //https://pcs.baidu.com/rest/2.0/pcs/manage?method=listhost
    //https://pcs.baidu.com/rest/2.0/pcs/file?app_id=250528&method=locateupload
    
    let cdnList = ["https://pcs.baidu.com",
                   "https://www.baidupcs.com",
                   "https://c.pcs.baidu.com",
                   "https://c3.pcs.baidu.com",
                   "https://d.pcs.baidu.com",
                   "https://d3.pcs.baidu.com",
                   "https://nj.baidupcs.com",
                   "https://bj.baidupcs.com",
                   "https://qd.baidupcs.com",
                   "https://ipv6.baidupcs.com"]
	
    var isTokenEffective = false {
        didSet {
            if isTokenEffective != oldValue {
                NotificationCenter.default.post(name: .baiduStatusUpdated, object: nil)
            }
        }
    }
	
	@objc dynamic var mainPath: String = {
		return Preferences.shared.baiduFolder == "" ? "/" : Preferences.shared.baiduFolder
	}()
	
	var selectedPath = Preferences.shared.baiduFolder == "" ? "/" : Preferences.shared.baiduFolder {
		didSet {
			getFileList(forPath: selectedPath)
		}
	}

	func updateCookie(_ block: @escaping () -> Void) {
		HTTP.GET("https://pan.baidu.com") { _ in
			block()
		}
	}
	
    func getUserInfo(_ block: ((_ userName: String, _ capacityInfo: String, _ capacityPer: Double) -> Void)?,
                     _ error: ((_ error: Error) -> Void)?) {
		HTTP.GET("https://pan.baidu.com/wap/home") {
			let str = $0.text ?? ""
			let userName = str.subString(from: "<h3 class=\"name\">", to: "</h3>")
			let capacityInfo = str.subString(from: "<p class=\"capacity\">", to: "</p>").replacingOccurrences(of: "\n", with: "")
            let params = ["method": "info",
                          "access_token": Preferences.shared.baiduToken]
            if $0.error != nil {
                error?($0.error!)
            }
            HTTP.GET("https://pcs.baidu.com/rest/2.0/pcs/quota?", parameters: params) {
                if $0.error == nil, let info = $0.data.decode(PCSInfo.self) {
                    block?(userName, capacityInfo, Double(info.used/info.quota))
                } else {
                    error?($0.error!)
                }
            }
		}
	}
    
    func checkTokenEffective() {
        isTokenEffective = false
        checkToken {
            if $0 {
                self.checkAppsFolder {
                    self.isTokenEffective = $0
                }
            }
        }
    }
	
    func logout(_ block: (() -> Void)?,
                _ error: ((_ error: Error) -> Void)?) {
		HTTP.GET("https://wappass.baidu.com/passport?logout") {
            if $0.error != nil {
                error?($0.error!)
            }
            Preferences.shared.baiduToken = ""
            Preferences.shared.baiduFolder = ""
			block?()
		}
	}
	
	//MARK: - GetFileList
	func getFileList(forPath path: String) {
		ViewControllersManager.shared.waiting = true
        HTTP.GET("https://pan.baidu.com/api/list", parameters: ["dir": path]) {
        
			if let json = $0.data.decode(PCSFileList.self) {
				if json.errno == 0 {
					DataManager.shared.setData(forBaidu: json.list, forPath: path)
				} else {
					self.selectedPath = self.mainPath
				}
			}
			ViewControllersManager.shared.waiting = false
		}
	}
	
    enum baiduState {
        case shouldLogin, tokenFailure, folderFailure, error, success
    }
    
    func checkBaiduState(_ block: ((_ state: baiduState) -> Void)?) {
        Baidu.shared.checkLogin({
            if $0 {
                Baidu.shared.checkToken {
                    if $0 {
                        Baidu.shared.checkAppsFolder {
                            if $0 {
                                self.isTokenEffective = true
                                block?(.success)
                            } else {
                                Preferences.shared.baiduFolder = ""
                                Baidu.shared.getAppsFolderPath {
                                    if $0 {
                                        self.isTokenEffective = true
                                        block?(.success)
                                    } else {
                                        self.isTokenEffective = false
                                        block?(.folderFailure)
                                    }
                                }
                            }
                        }
                    } else {
                        self.isTokenEffective = false
                        block?(.tokenFailure)
                    }
                }
            } else {
                self.isTokenEffective = false
                block?(.shouldLogin)
            }
        }) { _ in
            self.isTokenEffective = false
            block?(.error)
        }
    }
}
//MARK: PCS
extension Baidu {
	//MARK: - GetDownloadUrl  PCS
	
    func checkLogin(_ block: ((_ isLogin: Bool) -> Void)?,
                    _ error: ((_ error: Error) -> Void)?) {
        HTTP.GET("https://pan.baidu.com/api/quota") {
            if $0.error != nil {
                error?($0.error!)
            }
            if let errno = $0.data.decode(PCSErrno.self)?.errno {
                block?(errno == 0)
            } else {
                block?(false)
            }
        }
    }
    
	func checkToken(_ block: ((_ t: Bool) -> Void)?) {
		let params = ["method": "info",
		              "access_token": Preferences.shared.baiduToken]
        HTTP.GET("https://pcs.baidu.com/rest/2.0/pcs/quota?", parameters: params) {
			if let error = $0.data.decode(PCSError.self) {
                block?(!error.isError)
			} else {
				block?(false)
			}
		}
	}
	
    func delete(_ paths: [String]) {
        struct Path: Encodable {
            let path: String
        }
        
        struct List: Encodable {
            let list: [Path]
        }
        
        if let data = try? JSONEncoder().encode(List(list: paths.map({ Path(path: $0) }))),
            let paramStr = String(data: data, encoding: .utf8) {
            HTTP.GET("https://pcs.baidu.com/rest/2.0/pcs/file",
                     parameters: ["method": "delete",
                               "access_token": "\(Preferences.shared.baiduToken)",
                        "param": paramStr]) {
                        if let error = $0.data.decode(PCSError.self),
                            !error.isError {
                            DataManager.shared.deletePCSFile(paths)
                        } else {
                            self.getFileList(forPath: self.selectedPath)
                        }
            }
        }
    }
    
	func getDownloadUrls(FromPCS path: String, block: @escaping (_ dlinks: [String]) -> Void) {
        
        let URLString = cdnList.map {
            $0 + "/rest/2.0/pcs/file?"
            } + cdnList.map {
                $0 + "/rest/2.0/pcs/stream?"
        }

        var reserved = CharacterSet.urlQueryAllowed
        reserved.remove(charactersIn: ": #[]@!$&'()*+, ;=")
        
        let encodePath = path.addingPercentEncoding(withAllowedCharacters: reserved) ?? "/"
        let params = "method=download&access_token=\(Preferences.shared.baiduToken)&path=\(encodePath)"
		
		let urls = URLString.map {
			$0 + params
		}
		block(urls)
	}

	func getAppsFolderPath(_ block: ((_ isFinded: Bool) -> Void)?) {
		HTTP.GET("https://pan.baidu.com/api/list?dir=/apps") {
            let group = DispatchGroup()
			if let json = $0.data.decode(PCSFileList.self),
				json.errno == 0 {
				json.list.filter {
					$0.isdir == true
					}.map {
						$0.path
				}.forEach { path in
                    group.enter()
                    HTTP.GET("https://pcs.baidu.com/rest/2.0/pcs/file",
                             parameters: ["method": "list",
                                          "access_token": "\(Preferences.shared.baiduToken)",
                                "path": path]) {
                                    if let error = $0.data.decode(PCSError.self),
                                        !error.isError,
                                        Preferences.shared.baiduFolder != path {
                                        Preferences.shared.baiduFolder = path
                                        self.selectedPath = path
                                        self.mainPath = path
                                        
                        }
                                    group.leave()
					}
				}
                group.notify(queue: .main) {
                    self.checkAppsFolder {
                        block?($0)
                    }
                }
            } else {
                block?(false)
            }
		}
	}
	
	func checkAppsFolder(_ block: @escaping (_ effective: Bool) -> Void) {
        HTTP.GET("https://pcs.baidu.com/rest/2.0/pcs/file",
                 parameters: ["method": "list",
                           "access_token": "\(Preferences.shared.baiduToken)",
                    "path": Preferences.shared.baiduFolder]) {
			if let error = $0.data.decode(PCSError.self) {
				block(!error.isError)
			} else {
				block(true)
			}
		}
	}
}
