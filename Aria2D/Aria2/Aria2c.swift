//
//  Aria2c.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/9.
//  Copyright © 2016年 xjbeta. All rights reserved.
//


import Cocoa
import PromiseKit
import PMKFoundation

class Aria2c: NSObject {
	
    lazy var supportPath: URL = {
        do {
            var url = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            url.appendPathComponent(Bundle.main.bundleIdentifier!)
            return url
        } catch let error {
            Log("Get application support dictionary failed: \(error)")
            fatalError("Get application support dictionary failed: \(error)")
        }
    }()
    
    lazy var sessionPath: String = {
        return supportPath.appendingPathComponent("Aria2D.session").path
    }()
    
    lazy var logPath: String = {
        return supportPath.appendingPathComponent("Aria2D.log").path
    }()
    
    func autoStart() {
        guard Preferences.shared.autoStartAria2c else { return }
        Log("Should autoStartAria2c")
        createFiles()
        aria2cPid().then { pid -> Promise<()> in
            let lastPID = Preferences.shared.aria2cOptions.lastPID
            let lastLaunch = Preferences.shared.aria2cOptions.lastLaunch
            if lastPID != "", pid == lastPID {
                Log("Aria2 did started, do nothing.")
                return Promise.value(())
            } else if pid == "", lastLaunch != "" {
                if lastPID == "" {
                    Log("Should kill test process.")
                    return self.aria2cPid(lastLaunch.replacingOccurrences(of: " -D", with: "")).then {
                        self.killProcess($0)
                        }.then {
                            self.startAria2()
                        }
                } else {
                    Log("Start aria2c.")
                    return self.startAria2()
                }
            } else if lastPID != "", pid != lastPID {
                Log("The wrong pid with lastPID.")
                return self.killLastAria2c().then {
                    self.startAria2()
                }
            } else if pid == "", lastPID == "", lastLaunch == "" {
                return self.startAria2()
            } else {
                Log("Unknown aria2c status, do nothing.")
                return Promise.value(())
            }
            }.done {
                Log("Auto start success.")
            }.catch {
                Log("Auto start error: \($0).")
        }
    }
    
	func autoClose() {
		guard !Preferences.shared.autoStartAria2c else { return }
        killLastAria2c().done {
            Log("killed last aria2c.")
            }.catch {
                Log($0)
        }
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
        let customPath = Preferences.shared.aria2cOptions.customAria2c
        if FileManager.default.isExecutableFile(atPath: customPath) {
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
        }
        return false
    }
	
}



extension Aria2c {
    
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
                } catch let error {
                    Log("Create Aria2D.conf file error: \(error)")
                }
			}
		}
	}
	
	
	// aria2c ...... -D
	func startAria2(_ test: Bool = false) -> Promise<Void> {
        return Promise { resolver in
            Preferences.shared.aria2cOptions.resetLastConf()
            let task = Process()
            task.currentDirectoryPath = supportPath.path
            
            let aria2cPath = Preferences.shared.aria2cOptions.path(for: .aria2c)
            let confPath = Preferences.shared.aria2cOptions.path(for: .aria2cConf)
            
            guard FileManager.default.fileExists(atPath: aria2cPath),
                FileManager.default.fileExists(atPath: confPath) else {
                    resolver.reject(Aria2ProcessError.configFileMissed)
                    return
            }
            
            task.launchPath = aria2cPath
            //            var args = ["--conf-path=\(confPath)", "--log=\(logPath)"]
            var args = ["--conf-path=\(confPath)"]
            args.append("-D")
            
            if Preferences.shared.aria2cOptions.selectedAria2cConf == .default🙂 {
                args.append("--input-file=\(sessionPath)")
                args.append("--save-session=\(sessionPath)")
            }
            task.arguments = args
            args.insert(task.launchPath ?? "", at: 0)
            let path = args.joined(separator: " ")
            
            task.launch(.promise).done { out, err in
                if let output = out.text() {
                    Log(output)
                    self.aria2cPid(path).done {
                        Preferences.shared.aria2cOptions.lastLaunch = path
                        if $0 == "\(task.processIdentifier + 1)" {
                            Preferences.shared.aria2cOptions.lastPID = $0
                        } else {
                            ViewControllersManager.shared.showAria2cAlert(err.text())
                        }
                        resolver.fulfill(())
                        }.catch {
                            resolver.reject($0)
                    }
                } else if let error = err.text() {
                    Log("Get aria2c pid error: \(error)")
                    resolver.reject(Aria2ProcessError.getPidError)
                } else {
                    Log("Get aria2c pid error, can't get error output.")
                    resolver.reject(Aria2ProcessError.getPidError)
                }
                }.catch {
                    resolver.reject($0)
            }
        }
	}
	
    // pgrep -f "path"
    func aria2cPid(_ arg: String = "") -> Promise<(String)> {
        let lastLaunch = arg == "" ? Preferences.shared.aria2cOptions.lastLaunch : arg
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments  = ["-f", "\(lastLaunch)"]
        
        return Promise { resolver in
            task.launch(.promise).done { out, err in
                if let output = out.text() {
                    resolver.fulfill(output.replacingOccurrences(of: "\n", with: ""))
                } else if let error = err.text() {
                    Log("Get aria2c pid error: \(error)")
                    resolver.reject(Aria2ProcessError.getPidError)
                } else {
                    Log("Get aria2c pid error, can't get error output.")
                    resolver.reject(Aria2ProcessError.getPidError)
                }
                }.catch {
                    resolver.reject($0)
            }
        }
    }
	
	// kill -9 "pid"
	func killLastAria2c() -> Promise<Void> {
		if Preferences.shared.aria2cOptions.lastPID != "" {
            return killProcess(Preferences.shared.aria2cOptions.lastPID)
		} else if Preferences.shared.aria2cOptions.lastLaunch != "" {
            return aria2cPid(Preferences.shared.aria2cOptions.lastLaunch).then {
                self.killProcess($0)
            }
		} else {
            return Promise { resolver in
                resolver.fulfill(())
            }
		}
	}
	
	func killProcess(_ pid: String) -> Promise<Void> {
        return Promise { resolver in
            var error: NSDictionary?
            let descriptor = NSAppleScript(source: "do shell script \"kill -KILL \(pid)\"")?.executeAndReturnError(&error)
            Preferences.shared.aria2cOptions.resetLastConf()
            if error != nil {
                Log(error)
                Log(descriptor)
                resolver.reject(Aria2ProcessError.killProcessError)
            } else {
                resolver.fulfill(())
            }
        }
	}
}

enum Aria2ProcessError: Error {
    case getPidError
    case killProcessError
    case configFileMissed
}


extension Pipe {
    func text() -> String? {
        return String(data: fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
    }
}
