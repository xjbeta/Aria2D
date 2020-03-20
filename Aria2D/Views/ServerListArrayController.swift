//
//  ServerListArrayController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/2/9.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa



@objc(Aria2ConnectionSettings)
class Aria2ConnectionSettings: NSObject, NSCoding {

	@objc dynamic var wsLabel: String {
		get {
			return enabledSSLorTLS ? "wss://" : "ws://"
		}
		set {}
	}
	
	@objc dynamic var name: String {
		get {
			return host == "" ? "NewServer" : "\(host):\(port)"
		}
		set {}
	}
	
	@objc dynamic var host: String {
		didSet {
			name = host == "" ? "NewServer" : "\(host):\(port)"
		}
	}
	@objc var port: Int {
		didSet {
			name = host == "" ? "NewServer" : "\(host):\(port)"
		}
	}
	
	@objc var enabledSSLorTLS: Bool = false {
		didSet {
			if enabledSSLorTLS != oldValue {
				wsLabel = enabledSSLorTLS ? "wss://" : "ws://"
			}
		}
	}
	
	@objc var customPath: String?

	@objc var secretToken: String
	@objc var rpcPath: String
	@objc var remark: String?

	var websocketURL: URL? {
		get {
			let rpcPath = self.rpcPath == "" ? "jsonrpc" : self.rpcPath
			var url = URL(string: "")
			if secretToken == "" {
				url = URL(string: "\(wsLabel)\(host):\(port)/\(rpcPath)")
			} else {
				url = URL(string: "\(wsLabel)token:\(secretToken)@\(host):\(port)/\(rpcPath)")
			}
			if url?.host != nil, url?.port != nil {
				return url
			} else {
				return nil
			}
		}
	}
	
	var id: String = UUID().uuidString
	
	override init() {
		host = "localhost"
		port = 2333
		rpcPath = ""
		secretToken = ""
	}
	
	required init(enabledSSLorTLS: Bool,
	              host: String,
	              port: Int,
	              rpcPath: String,
	              secretToken: String) {
		self.enabledSSLorTLS = enabledSSLorTLS
		self.host = host
		self.port = port
		self.rpcPath = rpcPath
		self.secretToken = secretToken
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		self.enabledSSLorTLS = aDecoder.decodeBool(forKey: "enabledSSLorTLS")
		self.host = aDecoder.decodeObject(forKey: "host") as? String ?? ""
		self.port = aDecoder.decodeInteger(forKey: "port")
		self.rpcPath = aDecoder.decodeObject(forKey: "rpcPath") as? String ?? ""
		self.secretToken = aDecoder.decodeObject(forKey: "secretToken") as? String ?? ""
		self.remark = aDecoder.decodeObject(forKey: "remark") as? String ?? ""
		self.id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
		self.customPath = aDecoder.decodeObject(forKey: "customPath") as? String
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.enabledSSLorTLS, forKey: "enabledSSLorTLS")
		aCoder.encode(self.host, forKey: "host")
		aCoder.encode(self.port, forKey: "port")
		aCoder.encode(self.rpcPath, forKey: "rpcPath")
		aCoder.encode(self.secretToken, forKey: "secretToken")
		aCoder.encode(self.remark, forKey: "remark")
		aCoder.encode(self.id, forKey: "id")
		aCoder.encode(self.customPath, forKey: "customPath")
	}
}


struct Aria2Servers {
	private var contents: [Aria2ConnectionSettings] = [Aria2ConnectionSettings()]
	private var selectedID = ""
	private var selectedIndex = 0
	
	func get() -> [Aria2ConnectionSettings] {
		return contents
	}
	
	mutating func set(_ contents: [Aria2ConnectionSettings]) {
		self.contents = contents
	}
	
	mutating func set(_ customPath: String) {
		contents[safe: getSelectedIndex()]?.customPath = customPath
	}
	
	
	func getServer() -> Aria2ConnectionSettings {
		return contents[getSelectedIndex()]
	}

	func getSelectedIndex() -> Int {
		return contents.map { $0.id }.firstIndex(of: selectedID) ?? 0
	}
	
	func getSelectedName() -> String {
		return getServer().name
	}
	
	func getSelectedToken() -> String {
		return getServer().secretToken
	}

	var isLocal: Bool {
		get {
			return getServer().host == "localhost"
		}
	}
	
	mutating func select(at index: Int) {
		if index < contents.count {
			selectedIndex = index
			selectedID = contents[index].id
		}
	}
	
	func serverURL() -> URL? {
		return getServer().websocketURL
	}
	
	init?(data: Data) {
		if let coding = NSKeyedUnarchiver.unarchiveObject(with: data) as? Encoding {
			contents = coding.contents
			selectedID = coding.selectedID
			selectedIndex = coding.selectedIndex
		} else {
			return nil
		}
	}
	
	init() {
	}
	
	func encode() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: Encoding(self))
	}
	
//	@objc(Encoding)
	@objc(_TtCV6Aria2D12Aria2ServersP33_171DF4024EB981219431F6BE240222578Encoding)
	private class Encoding: NSObject, NSCoding {
		var contents: [Aria2ConnectionSettings] = []
		var selectedID = ""
		var selectedIndex = -1
		init(_ aria2Servers: Aria2Servers) {
			contents = aria2Servers.contents
			selectedID = aria2Servers.selectedID
			selectedIndex = aria2Servers.selectedIndex
		}
		
		required init?(coder aDecoder: NSCoder) {
			self.contents = aDecoder.decodeObject(forKey: "contents") as? [Aria2ConnectionSettings] ?? []
			self.selectedID = aDecoder.decodeObject(forKey: "selectedID") as? String ?? ""
			self.selectedIndex = aDecoder.decodeObject(forKey: "selectedIndex") as? Int ?? 0
		}
		
		func encode(with aCoder: NSCoder) {
			aCoder.encode(self.contents, forKey: "contents")
			aCoder.encode(self.selectedID, forKey: "selectedID")
			aCoder.encode(self.selectedIndex, forKey: "selectedIndex")
		}
	}
}
