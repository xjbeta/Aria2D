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
    
    let launchAgentLabel = "com.xjbeta.Aria2D.aria2c"
    
    lazy var launchAgentPlistURL: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents")
            .appendingPathComponent("\(launchAgentLabel).plist")
    }()
    
    var aria2cArgs: [String] {
        get {
            let confPath = Preferences.shared.aria2cOptions.path(for: .aria2cConf)
            let aria2cPath = Preferences.shared.aria2cOptions.path(for: .aria2c)
            
            guard FileManager.default.fileExists(atPath: aria2cPath),
                  FileManager.default.isExecutableFile(atPath: aria2cPath),
                  FileManager.default.fileExists(atPath: confPath) else {
                return []
            }
            
            var args = ["--conf-path=\(confPath)"]
            
            // save session
            args.append("--input-file=\(sessionPath)")
            args.append("--save-session=\(sessionPath)")
            
            // log
            args.append("--log-level=notice")
            args.append("--log=\(logPath)")
            
            return args
        }
    }
    
    func argsDisplay() -> String {
        var args = aria2cArgs
        guard args.count > 0 else { return "" }
        args.insert(Preferences.shared.aria2cOptions.path(for: .aria2c), at: 0)
        return args.map { s -> String in
            guard s.contains(" ") else { return s }
            let parts = s.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { return "\"\(s)\"" }
            return "\(parts[0])='\(parts[1])'"
        }.joined(separator: " ")
    }
    
    func writeLaunchAgentPlist(aria2cPath: String, args: [String]) throws {
        let plist: [String: Any] = [
            "Label": launchAgentLabel,
            "ProgramArguments": [aria2cPath] + args,
            "WorkingDirectory": supportPath.path,
            "RunAtLoad": true,
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try FileManager.default.createDirectory(at: launchAgentPlistURL.deletingLastPathComponent(),
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        try data.write(to: launchAgentPlistURL, options: .atomic)
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
	
	
	// launchctl bootstrap gui/uid ~/Library/LaunchAgents/com.xjbeta.Aria2D.aria2c.plist
    
    func startAria2(_ test: Bool = false) async {
        Preferences.shared.aria2cOptions.resetLastConf()
        deleteAria2cLogFile()
        
        let args = aria2cArgs
        let aria2cPath = Preferences.shared.aria2cOptions.path(for: .aria2c)
        guard args.count > 0 else { return }
        
        do {
            try writeLaunchAgentPlist(aria2cPath: aria2cPath, args: args)
        } catch let error {
            Log("Write launch agent plist error: \(error)")
            return
        }
        
        // Ignore errors: bootout fails if the service is not loaded.
        Process.run(["/bin/launchctl", "bootout", "gui/\(getuid())/\(launchAgentLabel)"], wait: true)
        Process.run(["/bin/launchctl", "bootstrap", "gui/\(getuid())", launchAgentPlistURL.path], wait: true)
	}
	
    // launchctl list prints "PID  Status  Label"
    func aria2cPid() async -> [String] {
        await MainActor.run {
            let outText = Process.run(["/bin/launchctl", "list", launchAgentLabel], wait: true).outText
            guard let line = outText?
                .split(separator: "\n")
                .map(String.init)
                .dropFirst(1).first else { return [] }
            let pid = line.split(separator: "\t").map(String.init).first ?? ""
            return (pid == "-" || pid.isEmpty) ? [] : [pid]
        }
    }
	
	// launchctl bootout gui/uid/label
    func killAria2c() async {
        deleteAria2cLogFile()
        Process.run(["/bin/launchctl", "bootout", "gui/\(getuid())/\(launchAgentLabel)"], wait: true)
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
