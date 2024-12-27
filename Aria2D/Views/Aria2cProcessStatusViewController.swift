//
//  Aria2cProcessStatusViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2019/3/9.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class Aria2cProcessStatusViewController: NSViewController {

    @IBOutlet weak var processStatus: NSTextField!
    @IBOutlet weak var pidString: NSTextField!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var launchButton: NSButton!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBAction func launchAria2c(_ sender: NSButton) {
        progressIndicator.isHidden = false
        launchButton.isEnabled = false
        cancelButton.isEnabled = false
        startAria2cError = ""
        var action = ""
        
        Task {
            let pids = await Aria2.shared.aria2c.aria2cPid()
            if pids.count > 0 {
                action = "Stop"
                for pid in pids {
                    try? await Aria2.shared.aria2c.killProcess(pid)
                }
            } else {
                action = "Start"
                await Aria2.shared.aria2c.startAria2()
            }
            
            updateLaunchButton()
            
            progressIndicator.isHidden = true
            launchButton.isEnabled = true
            cancelButton.isEnabled = true
            
            if action == "Start" {
                let pids = await Aria2.shared.aria2c.aria2cPid()
                if pids.count != 1 {
                    performSegue(withIdentifier: .showAria2cLog, sender: self)
                }
            }
        }
    }
    
    @IBOutlet var argsTextView: NSTextView!
    var startAria2cError = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.startAnimation(nil)
        updateLaunchButton()
        
        initArgsTextView()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .showAria2cLog,
            let vc = (segue.destinationController as? NSWindowController)?.contentViewController as? Aria2cLogViewController {
            vc.showButton.isEnabled = false
            if startAria2cError != "" {
                vc.textView.string = startAria2cError
            } else if let d = FileManager.default.contents(atPath: vc.logPath),
                let s = String(data: d, encoding: .utf8) {
                vc.textView.string = s
                vc.showButton.isEnabled = true
            } else {
                vc.textView.string = "oops, something went wrong."
            }
        }
    }
    
    func initArgsTextView() {
        // Args TextView
        var aria2cArgs = Aria2.shared.aria2c.aria2cArgs
        aria2cArgs.insert(Preferences.shared.aria2cOptions.path(for: .aria2c), at: 0)
        argsTextView.string = aria2cArgs.joined(separator: " ")
    }
    
    func updateLaunchButton() {
        processStatus.stringValue = ""
        pidString.stringValue = ""
        launchButton.title = ""
        progressIndicator.isHidden = false
        
        Task { @MainActor in
            let pids = await Aria2.shared.aria2c.aria2cPid()
            progressIndicator.isHidden = true
            if pids.count >= 1 {
                processStatus.stringValue = "Running"
                launchButton.title = "Stop"
                pidString.stringValue = pids.joined(separator: ", ")
            } else {
                processStatus.stringValue = "Stopped"
                launchButton.title = "Start"
                pidString.stringValue = pids.first ?? ""
            }
        }
    }
}
