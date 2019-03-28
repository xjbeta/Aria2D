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
        return supportPath.appendingPathComponent("aria2c.log").path
    }()
    
    let aria2cProcessName = "Aria2D_aria2c"
    
    var aria2cArgs: [String] {
        get {
            let confPath = Preferences.shared.aria2cOptions.path(for: .aria2cConf)
            let aria2cPath = Preferences.shared.aria2cOptions.path(for: .aria2c)
            
            guard FileManager.default.fileExists(atPath: aria2cPath),
                FileManager.default.isExecutableFile(atPath: aria2cPath),
                FileManager.default.fileExists(atPath: confPath) else {
                    
                    
                    let t = ""
                    
                    
                    return []
            }
            
            var args = ["--conf-path=\(confPath)"]
            
            // save session
            args.append("--input-file=\(sessionPath)")
            args.append("--save-session=\(sessionPath)")
            
            // log
            args.append("--log-level=notice")
            args.append("--log=\(logPath)")
            
            let dic = Preferences.shared.aria2cOptionsDic.compactMap { kv -> String? in
                if let v = kv.value as? String {
                    if v != "" {
                        return "--\(kv.key)=\(v)"
                    } else {
                        return nil
                    }
                } else if let v = kv.value as? Bool {
                    return "--\(kv.key)=\(v ? "true" : "false")"
                } else {
                    return "--\(kv.key)=\(kv.value)"
                }
            }.sorted()
            args.append(contentsOf: dic)
            
            args = args.map { s -> String in
                var str = s
                if s.contains(" ") {
                    let i = str.firstIndex(of: "=")!
                    str.remove(at: i)
                    str.insert(contentsOf: "='", at: i)
                    str += "'"
                }
                return str
            }
            
            return args
        }
    }
    
    func autoStart() {
        guard Preferences.shared.autoStartAria2c else { return }
        Log("Should autoStartAria2c")
        createFiles()
        aria2cPid().then { pids -> Promise<()> in
            switch pids.count {
            case 0:
                Log("Aria2c process not found, start aria2c.")
                return self.startAria2()
            case 1:
                Log("Aria2c did started, do nothing.")
                return Promise.value(())
            case 1...:
                Log("More than 1 process, kill all and restart.")
                return self.killAria2c().then {
                    self.startAria2()
                }
            default:
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
        killAria2c().done {
            Log("killed aria2c.")
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
        } else {
            return []
        }
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
    // bash -c 'exec -a Aria2D_aria2c aria2c ...... -D'
    
	func startAria2(_ test: Bool = false) -> Promise<Void> {
        return Promise { resolver in
            Preferences.shared.aria2cOptions.resetLastConf()
            deleteAria2cLogFile()
            
            let task = Process()
            task.currentDirectoryPath = supportPath.path
            task.launchPath = "/bin/bash"
            var args = aria2cArgs
            let aria2cPath = Preferences.shared.aria2cOptions.path(for: .aria2c)
            args.insert(aria2cPath, at: 0)
            args.append("-D")
            
            task.arguments = ["-c", "exec -a \(aria2cProcessName) \(args.joined(separator: " "))"]

            task.launch(.promise).done { out, err in
                resolver.fulfill(())
                }.catch {
                    resolver.reject($0)
            }
        }
	}
	
    // pgrep -f "path"
    func aria2cPid() -> Promise<([String])> {
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments  = ["\(aria2cProcessName)"]
        
        return Promise { resolver in
            task.launch(.promise).done { out, err in
                if let output = out.text() {
                    resolver.fulfill(output.split(separator: "\n").map(String.init))
                } else {
                    resolver.fulfill([])
                }
                }.catch {
                    let err = self.pMKError($0).1
                    if err != "" {
                        Log("Get aria2c pid error: \(err)")
                    }
                    resolver.fulfill([])
            }
        }
    }
	
	// kill -9 "pid"
	func killAria2c() -> Promise<Void> {
        deleteAria2cLogFile()
        return aria2cPid().then {
            when(resolved: $0.map( { self.killProcess($0) } )).done { _ in }
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
    
    func deleteAria2cLogFile() {
        if FileManager.default.fileExists(atPath: logPath) {
            do {
                try FileManager.default.removeItem(atPath: logPath)
            } catch let err {
                Log("Delete aria2c log file error: \(err)")
            }
        }
    }
    
    func pMKError(_ err: Error) -> (String, String) {
        guard let error = err as? Process.PMKError else {
            assert(false, "The wrong process error type.")
            return ("", "")
        }
        switch error {
        case .notExecutable:
            Log("Get process error: notExecutable.")
        case .execution(process: _, standardOutput: let out, standardError: let err):
            return (out ?? "", err ?? "")
        }
        return ("", "")
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
