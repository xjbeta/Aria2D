//
//  Aria2cTrackerListViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2019/3/30.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class Aria2cTrackerListViewController: NSViewController {

    let allTrackersList = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt"
    let allIpTrackersList = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_ip.txt"
    
    @IBAction func openWebSite(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/ngosang/trackerslist") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBOutlet weak var ipAddress: NSButton!
    @IBOutlet weak var domains: NSButton!
    
    @IBAction func trackersType(_ sender: NSButton) {
        if ipAddress.state == .on, domains.state == .off {
            Preferences.shared.trackersType = TrackersType.ip.rawValue
        } else {
            Preferences.shared.trackersType = TrackersType.domains.rawValue
        }
        initButtonState(.trackersType)
    }
    
    @IBOutlet weak var udp: NSButton!
    @IBOutlet weak var https: NSButton!
    @IBOutlet weak var http: NSButton!
    @IBOutlet weak var ws: NSButton!
    
    @IBAction func trackersUrlType(_ sender: NSButton) {
        var typeList = [TrackersUrlType]()
        if udp.state == .on {
            typeList.append(.udp)
        }
        if https.state == .on {
            typeList.append(.https)
        }
        if http.state == .on {
            typeList.append(.http)
        }
        if ws.state == .on {
            typeList.append(.ws)
        }
        Preferences.shared.trackersUrlTypes = typeList.map { $0.rawValue }
        initButtonState(.trackersUrlType)
    }
    
    
    @IBAction func done(_ sender: NSButton) {
        var dic = Preferences.shared.aria2cOptionsDic
        dic["bt-tracker"] = textView.string
        Preferences.shared.updateAria2cOptionsDic(dic)
        self.dismiss(nil)
    }
    
    @IBAction func download(_ sender: NSButton) {
        let urlStr = trackersType == .domains ? allTrackersList : allIpTrackersList
        guard let url = URL(string: urlStr) else { return }
        var rq = URLRequest(url: url)
        rq.httpMethod = "GET"
        
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        done.isEnabled = false
        download.isEnabled = false
        textView.string = "Downloading..."
        URLSession.shared.dataTask(.promise, with: rq).compactMap(String.init).done(on: .main) {
            let list = $0.components(separatedBy: "\n\n").filter {
                $0 != ""
                }.filter { url -> Bool in
                    var isSelectedType = false
                    self.trackersUrlTypes.forEach {
                        if url.starts(with: $0.rawValue) {
                            isSelectedType = true
                        }
                    }
                    return isSelectedType
            }
            self.textView.string = list.joined(separator: ",")
            }.ensure(on: .main) {
                self.progressIndicator.isHidden = true
                self.progressIndicator.stopAnimation(nil)
                self.done.isEnabled = true
                self.download.isEnabled = true
            }.catch(on: .main) {
                Log("Download trackers list failed, error: \($0)")
                self.textView.string = "Download trackers list failed."
        }
    }
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var done: NSButton!
    @IBOutlet weak var download: NSButton!
    
    enum ButtonGroup {
        case trackersType, trackersUrlType
    }
    
    enum TrackersType: String {
        case ip, domains
    }
    
    enum TrackersUrlType: String {
        case udp, https, http, ws
    }
    
    var trackersType = TrackersType.domains
    var trackersUrlTypes = [TrackersUrlType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        done.isEnabled = false
        progressIndicator.isHidden = true
        initButtonState(.trackersType)
        initButtonState(.trackersUrlType)
    }
    
    func initButtonState(_ group: ButtonGroup) {
        if group == .trackersType {
            trackersType = TrackersType(rawValue: Preferences.shared.trackersType) ?? .domains
            ipAddress.state = trackersType == .ip ? .on : .off
            domains.state = trackersType == .domains ? .on : .off
        }
        
        if group == .trackersUrlType {
            trackersUrlTypes = Preferences.shared.trackersUrlTypes.compactMap {
                TrackersUrlType(rawValue: $0)
            }
            udp.state = trackersUrlTypes.contains(.udp) ? .on : .off
            https.state = trackersUrlTypes.contains(.https) ? .on : .off
            http.state = trackersUrlTypes.contains(.http) ? .on : .off
            ws.state = trackersUrlTypes.contains(.ws) ? .on : .off
        }
    }
}
