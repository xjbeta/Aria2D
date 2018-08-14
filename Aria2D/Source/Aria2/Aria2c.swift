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
			let lastLaunch = Preferences.shared.aria2cOptions.lastLaunch
			
			if Preferences.shared.restartAria2c {
				// should restart
				self.killLastAria2c {
					Preferences.shared.restartAria2c = false
					self.startAria2()
				}
			} else if lastPID != "", $0 == lastPID {
				// do nothing
				return
			} else if $0 == "", lastLaunch != "" {
				if lastPID == "" {
					// should kill test
					self.aria2cPid(lastLaunch.replacingOccurrences(of: " -D", with: "")) {
						self.killAria2c($0) {
							self.startAria2()
						}
					}
				} else {
					self.startAria2()
				}
				
			} else if lastPID != "", $0 != lastPID {
				// should kill launched
				self.killLastAria2c {
					self.startAria2()
				}
			} else if $0 == "", lastPID == "", lastLaunch == "" {
				self.startAria2()
			}
		}
	}
	func autoClose() {
		guard !Preferences.shared.autoStartAria2c else { return }
		self.killLastAria2c { }
	}
    
    func aria2cPaths() -> [String] {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launchPath = "/bin/bash"
        task.arguments  = ["-l", "-c", "which aria2c"]
        
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            return output.components(separatedBy: "\n").filter({ $0 != "" })
        }
        return []
    }
    
    func checkCustomPath() -> Bool {
        
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launchPath = Preferences.shared.aria2cOptions.customAria2c
        task.arguments  = ["-v"]
        
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            if let str = output.components(separatedBy: "\n").first {
                return str.contains("aria2")
            }
        }
        return false
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
	
	var logPath: String {
		do {
			var url = try FileManager.default.url(for: .applicationSupportDirectory , in: .userDomainMask, appropriateFor: nil, create: true)
			url.appendPathComponent(Bundle.main.bundleIdentifier!)
			url.appendPathComponent("Aria2D.log")
			return url.path
		} catch { }
		return ""
	}
	

	
	func createFiles() {
		guard Preferences.shared.aria2cOptions.selectedAria2cConf == .default🙂 else { return }
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
	func startAria2(_ test: Bool = false) {
		Preferences.shared.aria2cOptions.resetLastConf()
		let task = Process()
		do {
			var url = try FileManager.default.url(for: .applicationSupportDirectory , in: .userDomainMask, appropriateFor: nil, create: true)
			url.appendPathComponent(Bundle.main.bundleIdentifier!)
			task.currentDirectoryPath = url.path
		} catch { }
		
		let outputPipe = Pipe()
		let errorPipe = Pipe()
		task.standardOutput = outputPipe
		task.standardError = errorPipe
		
		
		
		let aria2cPath = Preferences.shared.aria2cOptions.path(for: .aria2c)
		let confPath = Preferences.shared.aria2cOptions.path(for: .aria2cConf)
		
		if FileManager.default.fileExists(atPath: aria2cPath),
			FileManager.default.fileExists(atPath: confPath) {
			task.launchPath = aria2cPath
//			var args = ["--conf-path=\(confPath)", "--log=\(logPath)"]
			var args = ["--conf-path=\(confPath)"]
			args.append("-D")
			
			if Preferences.shared.aria2cOptions.selectedAria2cConf == .default🙂 {
				args.append("--input-file=\(sessionPath)")
				args.append("--save-session=\(sessionPath)")
			}
			task.arguments = args
			
			task.launch()
			
			task.terminationHandler = { _ in
				args.insert(task.launchPath ?? "", at: 0)
				let path = args.joined(separator: " ")
				self.aria2cPid(path) {
					Preferences.shared.aria2cOptions.lastLaunch = path
//					Log($0)
//					Log("\(task.processIdentifier + 1)")
					if $0 == "\(task.processIdentifier + 1)" {
						Preferences.shared.aria2cOptions.lastPID = $0
					} else {
						ViewControllersManager.shared.showAria2cAlert(String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8))
					}
				}
			}
		}
	}
	
	
	// pgrep -f "path"
	func aria2cPid(_ arg: String = "", block: @escaping (_ pid: String) -> Void) {
		let lastLaunch = arg == "" ? Preferences.shared.aria2cOptions.lastLaunch : arg
		let task = Process()
		let pipe = Pipe()
		task.standardOutput = pipe
		task.launchPath = "/usr/bin/pgrep"
		task.arguments  = ["-f", "\(lastLaunch)"]
		task.launch()
		
		task.terminationHandler = { _ in
			if let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
				block(output.replacingOccurrences(of: "\n", with: ""))
			}
		}
	}
	
	// kill -9 "pid"
	func killLastAria2c(_ block: @escaping () -> Void) {
		if Preferences.shared.aria2cOptions.lastPID != "" {
			killAria2c(Preferences.shared.aria2cOptions.lastPID) {
				block()
			}
		} else if Preferences.shared.aria2cOptions.lastLaunch != "" {
			aria2cPid(Preferences.shared.aria2cOptions.lastLaunch) {
				self.killAria2c($0) {
					block()
				}
			}
		} else {
			block()
		}
	}
	
	func killAria2c(_ pid: String, block: @escaping () -> Void) {
		NSAppleScript(source: "do shell script \"kill -KILL \(pid)\"")?.executeAndReturnError(nil)
		Preferences.shared.aria2cOptions.resetLastConf()
		block()
	}
}
