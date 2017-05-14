//
//  BaiduLoginViewController.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/11.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import WebKit
import SwiftyJSON

class BaiduLoginViewController: NSViewController {

	@IBOutlet var waitProgressIndicator: NSProgressIndicator!
    @IBOutlet var webView: WebView!
    let url = URL(string: "https://wappass.baidu.com/")!
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }
	
	override func viewDidAppear() {
		displayLoginWeb()
	}
	
    func displayLoginWeb() {
        webView.isHidden = false
		waitProgressIndicator.isHidden = true
        let urlRequest = URLRequest(url: url)
		webView.customUserAgent = Baidu.shared.userAgent["User-Agent"]
        webView.mainFrame.load(urlRequest)
    }
	
	func displayWait() {
		webView.isHidden = true
		webView.stopLoading(self)
		waitProgressIndicator.isHidden = false
		waitProgressIndicator.startAnimation(self)
	}
	var onViewControllerDismiss: (() -> Void)?
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		onViewControllerDismiss?()
	}
	
}


extension BaiduLoginViewController: WebResourceLoadDelegate {
	
	func webView(_ sender: WebView!, resource identifier: Any!, didReceive response: URLResponse!, from dataSource: WebDataSource!) {
		if let str = response.url?.absoluteString,
			str.contains("https://wappass.baidu.com/wp/api/login?tt="),
			String(describing: (response as? HTTPURLResponse)?.allHeaderFields["Set-Cookie"]).contains("BDUSS")  {
			displayWait()
			Baidu.shared.updateCookie {
				Baidu.shared.checkLogin { isLogin in
					DispatchQueue.main.async {
						if isLogin {
							self.dismiss(self)
						} else {
							self.displayLoginWeb()
						}
					}
				}
			}
		}
	}
}
