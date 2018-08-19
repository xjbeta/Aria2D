//
//  BaiduViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2018/6/3.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

class BaiduViewController: NSViewController {
    
    @IBOutlet weak var stepTableView: NSTableView!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var viewForWeb: NSView!
    @IBOutlet weak var waitProgressIndicator: NSProgressIndicator!
    var webView: WKWebView!

    @IBAction func reConnect(_ sender: Any) {
        loadWebView(.baiduLogin)
    }
    
    @IBOutlet weak var contiune: NSButton!
    @IBAction func `continue`(_ sender: Any) {
        let step = baiduSteps.enumerated().filter({ $0.element.checkStatus == .mixed }).first?.offset ?? 0
        switch step {
        case 1:
            Preferences.shared.baiduAPIKey = pcsApiKeyTextField.stringValue
            setStep(.accessToken)
        case 3:
            Preferences.shared.baiduFolder = folderTextField.stringValue
            Baidu.shared.checkAppsFolder { success in
                DispatchQueue.main.async {
                    if success {
                        self.dismiss?()
                    } else {
                        self.folderTextField.stringValue = "/apps/"
                    }
                }

            }
        default:
            break
        }
    }
    
    @IBOutlet weak var previous: NSButton!
    @IBAction func previous(_ sender: Any) {
        let step = baiduSteps.enumerated().filter({ $0.element.checkStatus == .mixed }).first?.offset ?? 0
        switch step {
        case 1:
            Baidu.shared.logout({
                DispatchQueue.main.async {
                    self.setStep(.baiduAccount)
                }
            }) { _ in
                self.tabView.selectTabViewItem(at: 1)
            }
        case 2, 3:
            setStep(.pcsKey)
        default:
            break
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss?()
    }
    
    @IBOutlet weak var pcsApiKeyTextField: NSSecureTextField!
    @IBOutlet weak var folderTextField: NSTextField!
    
    var dismiss: (() -> Void)?
    
    @objc dynamic var enableApiKey = false
    @objc dynamic var enableSecretKey = false
    @objc dynamic var enableFolder = false
    
    enum webSite {
        case baiduLogin
        case pcsToken
    }
    
    struct BaiduStep {
        var name: String
        var checkStatus: NSControl.StateValue
    }
    
    var baiduSteps = [BaiduStep(name: NSLocalizedString("baiduStep.baiduAccount", comment: ""), checkStatus: .off),
                      BaiduStep(name: NSLocalizedString("baiduStep.pcsKey", comment: ""), checkStatus: .off),
                      BaiduStep(name: NSLocalizedString("baiduStep.accessToken", comment: ""), checkStatus: .off),
                      BaiduStep(name: NSLocalizedString("baiduStep.pcsFolder", comment: ""), checkStatus: .off)]
    
    enum Steps: Int {
        case baiduAccount, pcsKey, accessToken, pcsFolder
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSteps()
    }
    
    func initSteps() {
        Baidu.shared.checkBaiduState { state in
            DispatchQueue.main.async {
                switch state {
                case .shouldLogin:
                    self.setStep(.baiduAccount)
                case .tokenFailure:
                    self.setStep(.pcsKey)
                case .folderFailure:
                    self.setStep(.pcsFolder)
                case .success:
                    self.dismiss?()
                case .error:
                    self.tabView.selectTabViewItem(at: 1)
                }
            }
        }
    }
    
    func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    

    func setStep(_ step: Steps, _ didFindFolder: Bool = false) {
        guard step.rawValue < baiduSteps.count else {
            return
        }
        previous.isEnabled = true
        contiune.isEnabled = true
        
        baiduSteps.enumerated().forEach {
            switch $0.offset {
            case _ where $0.offset < step.rawValue:
                baiduSteps[$0.offset].checkStatus = .on
            case _ where $0.offset == step.rawValue:
                baiduSteps[$0.offset].checkStatus = .mixed
            case _ where $0.offset > step.rawValue:
                baiduSteps[$0.offset].checkStatus = .off
            default:
                break
            }
        }
        stepTableView.reloadData()
        
        switch step {
        case .baiduAccount:
            loadWebView(.baiduLogin)
            previous.isEnabled = false
            contiune.isEnabled = false
        case .pcsKey:
            enableApiKey = true
            enableSecretKey = false
            enableFolder = false
            Preferences.shared.baiduToken = ""
            Preferences.shared.baiduFolder = ""
            tabView.selectTabViewItem(at: 2)
        case .accessToken:
            loadWebView(.pcsToken)
            previous.isEnabled = true
            contiune.isEnabled = false
        case .pcsFolder:
            enableApiKey = false
            enableSecretKey = false
            enableFolder = !didFindFolder
            folderTextField.stringValue = didFindFolder ? Preferences.shared.baiduFolder : "/apps/"
            tabView.selectTabViewItem(at: 2)
        }
    }

    
    func loadWebView(_ webSite: webSite) {
        tabView.selectTabViewItem(at: 0)
        
        var url: URL?
        var script = ""
        switch webSite {
        case .baiduLogin:
            url = URL(string: "https://wappass.baidu.com")
            script = """
            $("style:contains('font-size')").html("html{font-size:36px!important;}");
            document.getElementsByClassName("pass-header")[0].remove();
            document.getElementsByClassName("f14 clearfix login-problem")[0].remove();
            document.getElementsByClassName("f14 account-login account-login-width")[0].remove();
            $("#pageWrapper").css({"padding-bottom":"0rem"});
            $("body").css({"min-height":"0rem"});
            """
        case .pcsToken:
            url = URL(string: "https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=\(Preferences.shared.baiduAPIKey)&redirect_uri=oob&scope=netdisk")
            script = """
            document.body.appendChild(document.getElementsByClassName("two-cols clearfix")[0]);
            document.getElementsByClassName("topbar")[0].remove();
            document.getElementsByClassName("page-tip")[0].remove();
            document.getElementsByClassName("g-bd")[0].remove();
            document.getElementsByClassName("user-avatar-img")[0].remove()
            """
        }
        
        // WebView Config
        let contentController = WKUserContentController()
        let scriptInjection = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(scriptInjection)
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        // Display Views
        waitProgressIndicator.isHidden = true
        webView = WKWebView(frame: viewForWeb.bounds, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        viewForWeb.subviews.removeAll()
        viewForWeb.addSubview(webView)
        webView.isHidden = false
        
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    func displayWait() {
        webView.isHidden = true
        webView.stopLoading(self)
        waitProgressIndicator.isHidden = false
        waitProgressIndicator.startAnimation(self)
    }
}

extension BaiduViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let str = webView.url?.absoluteString, str.contains("https://openapi.baidu.com/oauth/2.0/login_success") {
                let token = str.subString(from: "access_token=", to: "&")
                if token.count == 71 {
                    Preferences.shared.baiduToken = token
                    Baidu.shared.getAppsFolderPath { success in
                        DispatchQueue.main.async {
                            self.setStep(.pcsFolder, success)
                        }
                    }
                }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if (navigationResponse.response.url?.absoluteString.contains("https://wap.baidu.com"))! {
            displayWait()
            Baidu.shared.updateCookie {
                DispatchQueue.main.async {
                    self.setStep(.pcsKey)
                }
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nserr = error as NSError
        if nserr.code == -1022 {
            Log("NSURLErrorAppTransportSecurityRequiresSecureConnection")
        } else if let err = error as? URLError {
            switch(err.code) {
            case .cancelled:
                break
            case .cannotFindHost, .notConnectedToInternet, .resourceUnavailable, .timedOut:
                tabView.selectTabViewItem(at: 1)
            default:
                tabView.selectTabViewItem(at: 1)
                Log("error code: " + String(describing: err.code) + "  does not fall under known failures")
            }
        }
    }

}

extension BaiduViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return baiduSteps.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = stepTableView.makeView(withIdentifier: .stepTableCellView, owner: self) as? StepTableCellView,
            let item = baiduSteps[safe: row] {
            cell.stepName.stringValue = item.name
            cell.stepCheck.state = item.checkStatus
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}
