//
//  ArticleViewController.swift
//  Dailycast
//
//  Created by Adam Barr-Neuwirth on 5/3/18.
//  Copyright © 2018 Somdede. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices


class ArticleViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.isHidden = true
//        webView.load(URLRequest(url: url!))
        let urlString = "http://www.google.com"
        let url = URL(string: urlString)!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safariVC = SFSafariViewController(url: url, configuration: config)
        present(safariVC, animated: true, completion: nil)
    }

}
