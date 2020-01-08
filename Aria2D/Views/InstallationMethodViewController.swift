//
//  InstallationMethodViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2019/4/6.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class InstallationMethodViewController: NSViewController {
    @IBOutlet weak var tabView: NSTabView!
    @IBAction func officeSite(_ sender: NSButton) {
        if let u = URL(string: "https://aria2.github.io") {
            NSWorkspace.shared.open(u)
        }
    }
    
    @IBAction func homeBrew(_ sender: NSButton) {
        tabView.selectTabViewItem(at: 1)
    }
    
    @IBAction func openTerminal(_ sender: NSButton) {
        NSWorkspace.shared.launchApplication("Terminal")
    }
    
    @IBAction func dmgFile(_ sender: NSButton) {
        if let u = URL(string: "https://github.com/xjbeta/AppUpdaterAppcasts/raw/master/aria2/aria2-Latest.dmg") {
            NSWorkspace.shared.open(u)
        }
        tabView.selectTabViewItem(at: 2)
    }
    
    @IBAction func dmgHelp(_ sender: Any) {
        if let path = Bundle.main.path(forResource: "DMG File Installation Guide", ofType: "pdf") {
            NSWorkspace.shared.openFile(path, withApplication: "Preview.app")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
