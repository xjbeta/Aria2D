//
//  Aria2c.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/9.
//  Copyright © 2016年 xjbeta. All rights reserved.
//


import Cocoa

@MainActor
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
                
//                let t = ""
                return []
            }
            
            var args = ["--conf-path=\(confPath)"]
            
            // save session
            args.append("--input-file=\(sessionPath)")
            args.append("--save-session=\(sessionPath)")
            
            // log
            args.append("--log-level=notice")
            args.append("--log=\(logPath)")
            
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
    
    func autoStart() async {
        guard Preferences.shared.autoStartAria2c else { return }
        Log("Should autoStartAria2c")
        createFiles()
        let pids = await aria2cPid()
        switch pids.count {
        case 0:
            Log("Aria2c process not found, start aria2c.")
            await startAria2()
        case 1:
            Log("Aria2c did started, do nothing.")
        case 1...:
            Log("More than 1 process, kill all and restart.")
            await killAria2c()
            await startAria2()
        default:
            Log("Unknown aria2c status, do nothing.")
        }
        Log("Auto start success.")
    }
    
	func autoClose() async {
		guard !Preferences.shared.autoStartAria2c else { return }
        await killAria2c()
        Log("killed aria2c.")
	}
    
    func aria2cPaths() async -> [String] {
        await MainActor.run {
            let outText = Process.run(["/usr/bin/which", "aria2c"], wait: true).outText
            return outText?.components(separatedBy: "\n").filter({ $0 != "" }) ?? []
        }
    }
    
    func checkCustomPath() async -> Bool {
        let path = Preferences.shared.aria2cOptions.customAria2c
        guard FileManager.default.isExecutableFile(atPath: path) else { return false }
        
        let outs = await MainActor.run {
            let outText = Process.run([path, "-v"], wait: true).outText
            return outText?.components(separatedBy: "\n").filter({ $0 != "" }) ?? []
        }
        
        return outs.first?.contains("aria2") ?? false
    }
    
	func createFiles() {
		guard Preferences.shared.aria2cOptions.selectedAria2cConf == .default🙂 else { return }
		if !FileManager.default.fileExists(atPath: sessionPath) {
			FileManager.default.createFile(atPath: sessionPath, contents: nil, attributes: nil)
		}
		let confPath = Preferences.shared.aria2cOptions.defaultAria2cConf
        
        guard !FileManager.default.fileExists(atPath: confPath),
              let path = Bundle.main.path(forResource: "Aria2D", ofType: "conf") else { return }
        
        let url = URL(fileURLWithPath: confPath)
        do {
            try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: url)
        } catch let error {
            Log("Create Aria2D.conf file error: \(error)")
        }
	}
	
	
	// aria2c ...... -D
    // bash -c 'exec -a Aria2D_aria2c aria2c ...... -D'
    
    func startAria2(_ test: Bool = false) async {
        Preferences.shared.aria2cOptions.resetLastConf()
        deleteAria2cLogFile()
        
        var args = aria2cArgs
        let aria2cPath = Preferences.shared.aria2cOptions.path(for: .aria2c)
        args.insert(aria2cPath, at: 0)
//            args.append("-D")
        args = ["/bin/bash", "-c", "exec -a \(aria2cProcessName) \(args.joined(separator: " "))"]
        
        Process.run(args,
                    at: .init(fileURLWithPath: supportPath.path),
                    wait: false)
	}
	
    // pgrep -f "path"
    func aria2cPid() async -> [String] {
        await MainActor.run {
            let outText = Process.run(["/usr/bin/pgrep", "\(aria2cProcessName)"], wait: true).outText
            return outText?.components(separatedBy: "\n").filter({ $0 != "" }) ?? []
        }
    }
	
	// kill -9 "pid"
    func killAria2c() async {
        deleteAria2cLogFile()
        let pids = await aria2cPid()
        
        for pid in pids {
            try? await killProcess(pid)
        }
	}
	
    func killProcess(_ pid: String) async throws {
        var error: NSDictionary?
        let descriptor = NSAppleScript(source: "do shell script \"kill -KILL \(pid)\"")?.executeAndReturnError(&error)
        Preferences.shared.aria2cOptions.resetLastConf()
        if error != nil {
            Log(error)
            Log(descriptor)
            throw Aria2ProcessError.killProcessError
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

extension Process {
    @discardableResult
    static func run(_ cmd: [String], at currentDir: URL? = nil, wait: Bool = true) -> (process: Process, outText: String?, errText: String?) {
        guard cmd.count > 0 else {
            fatalError("Process.launch: the command should not be empty")
        }
        
        let (stdout, stderr) = (Pipe(), Pipe())
        let process = Process()
        process.executableURL = URL(fileURLWithPath: cmd[0])
        process.currentDirectoryURL = currentDir ?? Bundle.main.resourceURL
        
        process.arguments = [String](cmd.dropFirst())
        process.standardOutput = stdout
        process.standardError = stderr
        process.launch()
    
        guard wait else {
            return (process, nil, nil)
        }
        
        process.waitUntilExit()
        
        let outText = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        let errText = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        
        return (process, outText, errText)
    }
}
