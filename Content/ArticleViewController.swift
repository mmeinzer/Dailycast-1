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
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: WKWebView!
    var url: URL?
    @IBOutlet weak var pageTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url!))
        
        navBar.barStyle = .default
//        navBar.barTintColor = UIColor.black
//        navBar.tintColor = UIColor.white
        
        let string = url!.absoluteString
        let sindex = string.range(of: "/", options: .backwards)?.upperBound
        let title = string.substring(from: sindex!).replacingOccurrences(of: "_", with: " ")
        pageTitle.title = title

        setNeedsStatusBarAppearanceUpdate()

        //        let config = SFSafariViewController.Configuration()
//        config.entersReaderIfAvailable = true
//        let safariVC = SFSafariViewController(url: url, configuration: config)
//        present(safariVC, animated: true, completion: nil)
    }

    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
