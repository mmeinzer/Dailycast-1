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
import TUSafariActivity


class ArticleViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: WKWebView!
    var url: URL?
    @IBOutlet weak var pageTitle: UINavigationItem!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self

        webView.load(URLRequest(url: url!))
        webView.layer.zPosition = 0
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.scrollView.delegate = self
        navBar.barStyle = .default
        
        pageTitle.title = url?.host

        setNeedsStatusBarAppearanceUpdate()
        
        
        pageTitle.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped(_:))), animated: true)
        
        pageTitle.setLeftBarButton(UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backTapped)), animated: true)

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        
        view.addGestureRecognizer(edgePan)
        
    }

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        progressView.isHidden = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if(scrollView.contentOffset.y >= 0){
            progressHeight.constant = 4 - scrollView.contentOffset.y
        }
    }
    

    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(webView.estimatedProgress)
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func shareTapped(_ sender : UIBarButtonItem){
        
            let text = "Check out this article I read on Dailycast"

    
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [text, url], applicationActivities: [TUSafariActivity()])
    
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.barButtonItem = sender
            activityViewController.popoverPresentationController?.permittedArrowDirections = .up;
        
            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
    
    
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    @objc func backTapped(){
        if(webView.canGoBack) {
            //Go back in webview history
            webView.goBack()
        } else {
            //Pop view controller to preview view controller
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
