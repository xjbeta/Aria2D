//
//  SetPCSViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/2/2.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa
import WebKit

class SetPCSViewController: NSViewController, WKNavigationDelegate {
	@IBOutlet var viewForWeb: NSView!
	@IBOutlet var getTokenButton: NSButton!
	@IBOutlet var stackView: NSStackView!
	@IBOutlet var tokenStatusCheck: NSButton!
	
	@IBOutlet var folderTextField: NSTextField!
	@IBAction func getToken(_ sender: Any) {
		Preferences.shared.baiduFolder = ""
		Preferences.shared.baiduToken = ""		
		showWebView()
		let url = URL(string: "https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=\(baiduAPIKey)&redirect_uri=oob&scope=netdisk")
		let request = URLRequest(url: url!)
		webView.load(request)
	}
	
	var webView: WKWebView!
	
	var baiduAPIKey: String {
		get {
			return Preferences.shared.baiduAPIKey
		}
		set {
			Preferences.shared.baiduAPIKey = newValue
		}
	}
	
	var baiduSecretKey: String {
		get {
			return Preferences.shared.baiduSecretKey
		}
		set {
			Preferences.shared.baiduSecretKey = newValue
		}
	}
	
	var webViewConfiguration: WKWebViewConfiguration {
		get {
			let contentController = WKUserContentController()
			let script = "document.body.appendChild(document.getElementsByClassName(\"two-cols clearfix\")[0]); document.getElementsByClassName(\"topbar\")[0].remove(); document.getElementsByClassName(\"page-tip\")[0].remove(); document.getElementsByClassName(\"g-bd\")[0].remove();document.getElementsByClassName(\"user-avatar-img\")[0].remove()"
			let scriptInjection = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
			contentController.addUserScript(scriptInjection)
			let config = WKWebViewConfiguration()
			config.userContentController = contentController
			return config
		}
	}
	
	override func loadView() {
		super.loadView()
		webView = WKWebView(frame: viewForWeb.bounds, configuration: webViewConfiguration)
		webView.navigationDelegate = self
		viewForWeb.addSubview(webView)
		hideWebView()
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		initTokenStatusCheck()
		
		NotificationCenter.default.addObserver(self, selector: #selector(initTokenStatusCheck), name: .updateToken, object: nil)
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		Baidu.shared.checkToken(nil)
	}
	
	var onViewControllerDismiss: (() -> Void)?
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		hideWebView()
		if webView != nil, webView.isLoading {
			webView.stopLoading()
		}
		onViewControllerDismiss?()
	}
	
	@objc func initTokenStatusCheck() {
		DispatchQueue.main.async {
			self.tokenStatusCheck.state = Baidu.shared.isTokenEffective ? .on : .off
			self.folderTextField.stringValue = Preferences.shared.baiduFolder
		}
	}
	
	func showWebView() {
		stackView.isHidden = true
		viewForWeb.isHidden = false
	}
	
	func hideWebView() {
		stackView.isHidden = false
		viewForWeb.isHidden = true
	}
	
	func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
		if let str = webView.url?.absoluteString {
			if str.contains("https://openapi.baidu.com/oauth/2.0/login_success") {
				let token = str.subString(from: "access_token=", to: "&")
				if token.characters.count == 71 {
					Preferences.shared.baiduToken = token
					Baidu.shared.checkToken(nil)
					hideWebView()
				}
			}
		}
	}
}
