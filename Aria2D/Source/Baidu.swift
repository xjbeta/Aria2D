//
//  Baidu.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/14.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import PromiseKit
import Alamofire

class Baidu: NSObject {
	
	static let shared = Baidu()
	private override init() {
        
        networkReachabilityManager = NetworkReachabilityManager(host: "pan.baidu.com")!
        networkReachabilityManager.listener = { status in
            switch status {
            case .notReachable:
                Log("Network notReachable")
            case .reachable:
                Log("Network reachable")
            case .unknown:
                Log("Network unknown")
            }
        }
        networkReachabilityManager.startListening()
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:63.0) Gecko/20100101 Firefox/63.0"
        let baiduConf = URLSessionConfiguration.default
        baiduConf.httpAdditionalHeaders = headers
        baiduHTTP = SessionManager(configuration: baiduConf,
                                   serverTrustPolicyManager: BaiduTrustPolicyManager(policies: [:]))
        
        
        let privateConf = URLSessionConfiguration.default
        privateConf.httpAdditionalHeaders = headers
        privateConf.httpCookieStorage = nil
        privateHTTP = SessionManager(configuration: privateConf,
                                     serverTrustPolicyManager: BaiduTrustPolicyManager(policies: [:]))
	}
    
    let networkReachabilityManager: NetworkReachabilityManager
    let baiduHTTP: SessionManager
    let privateHTTP: SessionManager

	let mainPath = "/"
	
    var isLogin = false {
        didSet {
            if isLogin {
                getBdStoken().done { _ in }.catch {
                    Log("Get bdstoken error \($0)")
                }
            } else {
                bdStoken = ""
            }
            
            if isLogin != oldValue {
                NotificationCenter.default.post(name: .baiduStatusUpdated, object: nil)
            }
        }
    }
    
	var selectedPath = "/" {
		didSet {
			getFileList(forPath: selectedPath).done { _ in }.catch {
                Log("Get baidu file list error \($0)")
            }
		}
	}

    var bdStoken = ""
    
	func updateCookie() -> Promise<Void> {
        return Promise { resolver in
            baiduHTTP.request("https://pan.baidu.com/disk/home")
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(())
            }
        }
	}
	
    struct BaiduUserInfo: Decodable {
        let username: String
        let quota: Quota
        struct Quota: Decodable {
            let total: Int
            let used: Int
        }
    }
    
    func getUserInfo() -> Promise<BaiduUserInfo> {
        return Promise { resolver in
            baiduHTTP.request("https://pan.baidu.com/wap/home")
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    let str = $0.text ?? ""
                    struct Result: Decodable {
                        let username: String
                        let quota: Quota
                        struct Quota: Decodable {
                            let total: Int
                            let used: Int
                        }
                    }
                    if let re = str.subString(from: "window.yunData = ", to: ";\n").data(using: .utf8)?.decode(BaiduUserInfo.self) {
                        resolver.fulfill(re)
                    } else {
                        resolver.fulfill(BaiduUserInfo(username: "", quota: Baidu.BaiduUserInfo.Quota(total: 0, used: 0)))
                    }
            }
        }
	}
    
	
    func logout() -> Promise<Void> {
        return Promise { resolver in
            baiduHTTP.request("https://wappass.baidu.com/passport?logout")
                .validate()
                .response { _ in
                    resolver.fulfill(())
            }
        }
	}
    
    func checkLogin() -> Promise<Bool> {
        return Promise { resolver in
            baiduHTTP.request("https://pan.baidu.com/api/quota")
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    
                    guard let errno = $0.data?.decode(PCSErrno.self)?.errno, errno == 0 else {
                        self.isLogin = false
                        resolver.reject(BaiduHTTPError.shouldLogin)
                        return
                    }
                    self.isLogin = true
                    resolver.fulfill(self.isLogin)
            }
        }
    }
    
	func getFileList(forPath path: String) -> Promise<Void> {
        return Promise { resolver in
            baiduHTTP.request("https://pan.baidu.com/api/list", parameters: ["dir": path])
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    
                    guard let json = $0.data?.decode(PCSFileList.self), json.errno == 0 else {
                        resolver.reject(BaiduHTTPError.cantGetList)
                        return
                    }
                    
                    DataManager.shared.setData(forBaidu: json.list, forPath: path)
                    resolver.fulfill(())
            }
        }
	}
    
    struct DeleteResult: Decodable {
        let errno: Int
        let path: String
    }
	
    func delete(_ paths: [String]) -> Promise<[DeleteResult]> {
        let p = ["filelist": "\(paths)"]
        return Promise { resolver in
            baiduHTTP.request("https://pan.baidu.com/api/filemanager?opera=delete&web=1&channel=chunlei&web=1&bdstoken=\(bdStoken)&clienttype=0", method: .post, parameters: p)
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    struct Result: Decodable {
                        let errno: Int
                        let info: [DeleteResult]
                    }
                    
                    guard let re = $0.data?.decode(Result.self), re.errno == 0 else {
                        resolver.reject(BaiduHTTPError.cantDelete)
                        return
                    }
                    resolver.fulfill(re.info)
            }
        }
    }
    
    func creatShareLink(_ fsIds: [Int]) -> Promise<String> {
        let p = [
            "fid_list": "\(fsIds)",
            "schannel": "0",
            "channel_list": "[]",
            "period": "0"]
        return Promise { resolver in
            baiduHTTP.request("https://pan.baidu.com/share/set?web=1&channel=chunlei&web=1&bdstoken=\(bdStoken)&clienttype=0", method: .post, parameters: p)
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    struct ShareResult: Decodable {
                        let errno: Int
                        let link: String
                    }
                    guard let re = $0.data?.decode(ShareResult.self),
                        re.errno == 0 else {
                            resolver.reject(BaiduHTTPError.shareFileError)
                            return
                    }
                    resolver.fulfill(re.link)
            }
        }
    }
    
    struct SharedLinkInfo: Decodable {
        let uk: Int
        let timestamp: Int
        let shareid: Int
        let sign: String
    }
    
    func getSharedLinkInfo(_ sLink: String) -> Promise<SharedLinkInfo> {
        return Promise { resolver in
            privateHTTP.request(sLink)
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    guard let infoData = $0.text?.subString(from: "yunData.setData(", to: ");").data(using: .utf8),
                        let info = infoData.decode(SharedLinkInfo.self) else {
                            resolver.reject(BaiduHTTPError.cantFindInfoInShareLink)
                            return
                    }
                    resolver.fulfill(info)
            }
        }
    }
    
    struct BaiduDlink: Decodable {
        let fileName: String
        let md5: String
        let dlink: String
        var dlinks: [String] = []
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
        private enum CodingKeys: String, CodingKey {
            case fileName = "server_filename",
            md5,
            dlink
        }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            fileName = try values.decode(String.self, forKey: .fileName)
            md5 = try values.decode(String.self, forKey: .md5)
            dlink = try values.decode(String.self, forKey: .dlink)
            dlinks = cdnList.map {
                $0 + dlink.subString(from: "com")
            }
        }
    }
    

    
    func getDlinks(_ info: SharedLinkInfo, fsIds: [Int]) -> Promise<[BaiduDlink]> {
        let p = ["encrypt": "0",
                 "product": "share",
                 "uk": "\(info.uk)",
            "primaryid": "\(info.shareid)",
            "fid_list": "\(fsIds)"]
        return Promise { resolver in
            privateHTTP.request("https://pan.baidu.com/api/sharedownload?sign=\(info.sign)&timestamp=\(info.timestamp)", method: .post, parameters: p)
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    struct Result: Decodable {
                        let list: [BaiduDlink]
                        let errno: Int
                    }
                    
                    guard let re = $0.data?.decode(Result.self), re.errno == 0 else {
                        resolver.reject(BaiduHTTPError.cantGenerateDlinks)
                        return
                    }
                    resolver.fulfill(re.list)
            }
        }
    }
    
    func cancelSharing(_list: [Int]) -> Promise<Void> {
        let p = ["shareid_list": "\(_list)"]
        
        return Promise { resolver in
            baiduHTTP.request("https://pan.baidu.com/share/cancel?web=1&channel=chunlei&web=1&bdstoken=\(bdStoken)&clienttype=0", method: .post, parameters: p)
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    
                    guard let re = $0.data?.decode(PCSErrno.self), re.errno == 0 else {
                        resolver.reject(BaiduHTTPError.cancelSharingError)
                        return
                    }
                    resolver.fulfill(())
            }
        }
    }
    
    func getBdStoken() -> Promise<String> {
        return Promise { resolver in
            if bdStoken != "", bdStoken.count == 32 {
                resolver.fulfill(bdStoken)
            }
            baiduHTTP.request("https://pan.baidu.com/disk/home")
                .validate()
                .response {
                    if let error = $0.error {
                        resolver.reject(error)
                        return
                    }
                    let str = $0.text?.subString(from: "initPrefetch(\'", to: "\',")
                    guard let bdStoken = str, bdStoken.count == 32 else {
                        resolver.fulfill("")
                        return
                    }
                    self.bdStoken = bdStoken
                    resolver.fulfill(bdStoken)
            }
        }
    }
}

extension DefaultDataResponse {
    var text: String? {
        get {
            if let data = data, let str = String(data: data, encoding: .utf8) {
                return str
            }
            return nil
        }
    }
}

enum BaiduHTTPError: Error {
    case shouldLogin
    
    // Download links
    case shareFileError
    case cantFindInfoInShareLink
    case cantGenerateDlinks
    
    // Delete files
    case cantDelete
    
    // Get file list
    case cantGetList
    
    // Cancel sharing
    case cancelSharingError
}
