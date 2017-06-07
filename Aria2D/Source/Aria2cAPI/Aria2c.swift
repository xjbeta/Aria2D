//
//  Aria2c.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/9.
//  Copyright © 2016年 xjbeta. All rights reserved.
//


import Cocoa

class Aria2c: NSObject {
	func autoStart() {
		guard Preferences.shared.autoStartAria2c else { return }
		createFiles()
		aria2cPid {
			let lastPID = Preferences.shared.aria2cOptions.lastPID
			if $0 == "" {
				self.startAria2()
			} else if lastPID != "", $0 != lastPID {
				self.killLastAria2c {
					self.startAria2()
				}
			}
		}
	}
}





private extension Aria2c {
	
	var sessionPath: String {
		do {
			var url = try FileManager.default.url(for: .applicationSupportDirectory , in: .userDomainMask, appropriateFor: nil, create: true)
			url.appendPathComponent(Bundle.main.bundleIdentifier!)
			url.appendPathComponent("Aria2D.session")
			return url.path
		} catch { }
		return ""
	}
	

	
	func createFiles() {
		if !FileManager.default.fileExists(atPath: sessionPath) {
			FileManager.default.createFile(atPath: sessionPath, contents: nil, attributes: nil)
		}
		let confPath = Preferences.shared.aria2cOptions.defaultAria2cConf
		if !FileManager.default.fileExists(atPath: confPath) {
			if let path = Bundle.main.path(forResource: "Aria2D", ofType: "conf") {
				let url = URL(fileURLWithPath: confPath)
				do {
					try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: url)
				} catch { }
			}
		}
	}
	
	
	// aria2c ...... -D
	func startAria2() {
		let task = Process()
		let stdoutPipe = Pipe()
		let stderrPipe = Pipe()
		task.standardOutput = stdoutPipe
		task.standardError = stderrPipe
		stderrPipe.fileHandleForReading.readabilityHandler = {
			if let output = String(data: $0.availableData, encoding: String.Encoding.utf8) {
				
				Log(output)
			}
		}
		stdoutPipe.fileHandleForReading.readabilityHandler = {
			if let output = String(data: $0.availableData, encoding: String.Encoding.utf8) {
				
				Log(output)
			}
		}
		
		
		
		do {
			var url = try FileManager.default.url(for: .applicationSupportDirectory , in: .userDomainMask, appropriateFor: nil, create: true)
			url.appendPathComponent(Bundle.main.bundleIdentifier!)
			task.currentDirectoryPath = url.path
			
		} catch { }
		
		let aria2cPath = Preferences.shared.aria2cOptions.path(for: .aria2c)
		let confPath = Preferences.shared.aria2cOptions.path(for: .aria2cConf)
		
		if FileManager.default.fileExists(atPath: aria2cPath),
			FileManager.default.fileExists(atPath: confPath) {
			task.launchPath = aria2cPath
//			var args = ["--conf-path=\(confPath)", "-D"]
			var args = ["--conf-path=\(confPath)"]
			if Preferences.shared.aria2cOptions.selectedAria2cConf == .default🙂 {
				args.append("--input-file=\(sessionPath)")
				args.append("--save-session=\(sessionPath)")
			}
			task.arguments = args
		}
		task.launch()
		
		task.terminationHandler = { _ in

			
//			let data = pipe.fileHandleForReading.readDataToEndOfFile()
//			if let output = String(data: data, encoding: .utf8) {
//				if output.contains("Exception") {
//					Log(output)
//				} else {
//					Preferences.shared.aria2cOptions.lastLaunchPath = aria2cPath
//					self.aria2cPid {
//						Preferences.shared.aria2cOptions.lastPID = $0
//					}
//				}
//			}
		}
	}
	
	// pgrep -f "path"
	func aria2cPid(_ block: @escaping (_ pid: String) -> Void) {
		let lastLaunchPath = Preferences.shared.aria2cOptions.lastLaunchPath
		let task = Process()
		let pipe = Pipe()
		task.standardOutput = pipe
		task.launchPath = "/usr/bin/pgrep"
		task.arguments  = ["-f", lastLaunchPath]
		task.launch()
		
		task.terminationHandler = { _ in
			let data = pipe.fileHandleForReading.readDataToEndOfFile()
			if let output = String(data: data, encoding: .utf8) {
				block(output)
			}
		}
	}
	
	// kill -9 "pid"
	func killLastAria2c(_ block: @escaping () -> Void) {
		let lastLaunchPath = Preferences.shared.aria2cOptions.lastLaunchPath
		let task = Process()
		task.launchPath = "/usr/bin/kill"
		task.arguments  = ["-9", lastLaunchPath]
		task.launch()
		task.terminationHandler = { _ in
			block()
		}
	}
	

	
	
}
