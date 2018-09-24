//
//  BaiduViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2018/6/3.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

class BaiduViewController: NSViewController {
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var viewForWeb: NSView!
    @IBOutlet weak var waitProgressIndicator: NSProgressIndicator!
    var webView: WKWebView!

    @IBAction func reConnect(_ sender: Any) {
        loadWebView()
    }
    
    @IBOutlet weak var ok: NSButton!
    @IBAction func ok(_ sender: Any) {
        self.dismiss?()
    }
    
    @IBOutlet weak var cancel: NSButton!
    @IBAction func cancel(_ sender: Any) {
        self.dismiss?()
    }
    
    var dismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ok.isEnabled = false
        loadWebView()
    }
    
    func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    
    func loadWebView() {
        tabView.selectTabViewItem(at: 0)
        
        let url = URL(string: "https://wappass.baidu.com")
        let script = """
        $("style:contains('font-size')").html("html{font-size:36px!important;}");
        document.getElementsByClassName("pass-header")[0].remove();
        document.getElementsByClassName("f14 clearfix login-problem")[0].remove();
        document.getElementsByClassName("f14 account-login account-login-width")[0].remove();
        $("#pageWrapper").css({"padding-bottom":"0rem"});
        $("body").css({"min-height":"0rem"});
        """
        
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
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if (navigationResponse.response.url?.absoluteString.contains("https://wap.baidu.com"))! {
            displayWait()
            Baidu.shared.updateCookie().then {
                Baidu.shared.checkLogin()
                }.done(on: .main) {
                    if $0 {
                        self.tabView.selectTabViewItem(at: 2)
                        self.ok.isEnabled = true
                        self.cancel.isEnabled = false
                    } else {
                        self.loadWebView()
                    }
                }.catch(on: .main) {
                    Log("Baidu website login success update infos error \($0)")
                    self.loadWebView()
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
