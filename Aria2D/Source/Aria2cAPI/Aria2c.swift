//
//  Aria2c.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/9.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

/*


import Cocoa

class Aria2c: NSObject {
	
	lazy var defaultConf: String = {
		return ""
	}()
	
	func start() {
		startAria2()
		createSessionFile()
	}
	var confPath: String {
		var url = try! FileManager.default.url(for: .documentDirectory , in: .userDomainMask, appropriateFor: nil, create: true)
		url.appendPathComponent("aria2D.conf")
		return url.path
	}
	
	func test() {
		
		let task = Process()
		task.launchPath = "/bin/sh"
		task.currentDirectoryPath = Bundle.main.resourcePath!
		
		if let path = Bundle.main.path(forResource: "CheckVersion", ofType: "sh") {
			task.arguments  = [path]
		}
		task.launch()
		
	}
	
	
	func version(_ aria2cPath: String, block: @escaping (_ version: String) -> Void) {
		let path = URL(fileURLWithPath: aria2cPath).deletingLastPathComponent()
		let _ = path.addSecurityScope()
		
		let task = Process()
		let pipe = Pipe()
		task.standardOutput = pipe
		
		task.launchPath = "/bin/sh"
		task.currentDirectoryPath = URL(fileURLWithPath: aria2cPath).deletingLastPathComponent().path
		
		if let path = Bundle.main.path(forResource: "CheckVersion", ofType: "sh") {
			task.arguments  = [path, aria2cPath]
		}
		task.launch()
		//        connect Aria2Websocket when task complete
		task.terminationHandler = { _ in
			let data = pipe.fileHandleForReading.readDataToEndOfFile()
			if let output = String(data: data, encoding: .utf8) {
				let t = output.replacingOccurrences(of: "\n", with: " ").components(separatedBy: " ")
				if t.first == "aria2" && t.index(of: "version") == 1 {
					if let version = t[safe: 2] {
						block(version)
					}
				}
				
			}
		}
		
		path.removeSecurityScope()
	}
	
	
}





private extension Aria2c {
	
	var sessionPath: String {
		var url = try! FileManager.default.url(for: .documentDirectory , in: .userDomainMask, appropriateFor: nil, create: true)
		url.appendPathComponent("aria2D.session")
		return url.path
	}

	
	
	
	func createSessionFile() {
		if !FileManager.default.fileExists(atPath: sessionPath) {
			FileManager.default.createFile(atPath: sessionPath, contents: nil, attributes: nil)
		}
		if !FileManager.default.fileExists(atPath: confPath) {
			let contents = "enable-rpc=true\nrpc-allow-origin-all=true\nrpc-listen-all=true"
			FileManager.default.createFile(atPath: confPath, contents: contents.data(using: .utf8), attributes: nil)
		}
		
	}
	
	
	
	func startAria2() {
		let task = Process()
		task.launchPath = "/bin/sh"
		task.currentDirectoryPath = Bundle.main.resourcePath!
		
		if let path = Bundle.main.path(forResource: "StartAria2c", ofType: "sh") {
			task.arguments  = [path,
			                   "--enable-rpc=true",
			                   "--rpc-listen-port=\(defaultValue.port.rawValue)",
				"--rpc-listen-all=true",
				"--rpc-allow-origin-all",
				"--daemon=true",
				"--save-session-interval=10",
				//                                   "--rpc-secret=secret",
				"--input-file=\(sessionPath)",
				"--save-session=\(sessionPath)",
				"--allow-overwrite=true",
				"--auto-save-interval=10"] + Preferences.shared.options
		}
		task.launch()
		//        connect Aria2Websocket when task complete
		task.terminationHandler = { _ in
			Aria2Websocket.shared.connect()
		}
	}
	

	
	
}
*/
