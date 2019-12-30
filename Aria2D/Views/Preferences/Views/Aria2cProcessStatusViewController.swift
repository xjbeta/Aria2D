//
//  Aria2cProcessStatusViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2019/3/9.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa
import PromiseKit

class Aria2cProcessStatusViewController: NSViewController {

    @IBOutlet weak var processStatus: NSTextField!
    @IBOutlet weak var pidString: NSTextField!
    @IBOutlet weak var launchButton: NSButton!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBAction func launchAria2c(_ sender: NSButton) {
        progressIndicator.isHidden = false
        launchButton.isEnabled = false
        startAria2cError = ""
        var action = ""
        
        Aria2.shared.aria2c.aria2cPid().then { pids -> Promise<()> in
            if pids.count > 0 {
                action = "Stop"
                return when(fulfilled: pids.map({ Aria2.shared.aria2c.killProcess($0) }))
            } else {
                action = "Start"
                return Aria2.shared.aria2c.startAria2()
            }
            }.ensure(on: .main) {
                self.progressIndicator.isHidden = true
                self.launchButton.isEnabled = true
                self.updateLaunchButton()
            }.done {
                if action == "Start" {
                    Aria2.shared.aria2c.aria2cPid().done(on: .main) {
                        if $0.count != 1 {
                            self.performSegue(withIdentifier: .showAria2cLog, sender: self)
                        }
                        }.catch {
                          Log("Check aria2c pid for Aria2c log view error: \($0)")
                    }
                }
            }.catch {
                Log("Launch aria2c process error: \($0)")
                guard let e = $0 as? Process.PMKError else { return }
                switch e {
                case .execution(_,_,let str):
                    self.startAria2cError = str ?? ""
                    self.performSegue(withIdentifier: .showAria2cLog, sender: self)
                case .notExecutable(_):
                    break
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
        self.processStatus.stringValue = ""
        self.pidString.stringValue = ""
        self.launchButton.title = ""
        progressIndicator.isHidden = false
        Aria2.shared.aria2c.aria2cPid().ensure(on: .main) {
            self.progressIndicator.isHidden = true
            }.done(on: .main) {
                if $0.count >= 1 {
                    self.processStatus.stringValue = "Running"
                    self.launchButton.title = "Stop"
                    self.pidString.stringValue = $0.joined(separator: ", ")
                } else {
                    self.processStatus.stringValue = "Stopped"
                    self.launchButton.title = "Start"
                    self.pidString.stringValue = $0.first ?? ""
                }
            }.catch {
                Log("Unknown error: \($0)")
        }
    }
}
