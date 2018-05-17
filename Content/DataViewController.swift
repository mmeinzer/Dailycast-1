//
//  DataViewController.swift
//  Dailycast
//
//  Created by Adam Barr-Neuwirth on 4/25/18.
//  Copyright © 2018 Somdede. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import WebKit
import SwiftSoup
import SwiftSVG

class DataViewController: UIViewController, WKNavigationDelegate{

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""
    var headlineSnippet: String = ""
    var articleURL: URL?
    var index: Int?
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    

    var imageView: UIImageView!
    var swipeUp: UISwipeGestureRecognizer!
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("index \(index)")
        imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.zPosition = 0
        view.addSubview(imageView)

        dataLabel.layer.zPosition = 2
        arrowImage.layer.zPosition = 2

        topLabel.backgroundColor = UIColor.black
        
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedAction))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.isHidden = true
        
        setBackground()
        
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(clearActivity), name: Notification.Name("resetCache"), object: nil)
        
        bgView.layer.cornerRadius = 4
        bgView.layer.zPosition = 2
        topView.layer.cornerRadius = 2
        topView.layer.zPosition = 2
        
        let sanatize = dataObject.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ")
        topText.text = String(sanatize!).removingPercentEncoding

    }
    
    @objc func swipedAction(){
        print("swipe")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let articleViewController = storyboard.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        articleViewController.url = articleURL
        self.present(articleViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = headlineSnippet
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    
    @objc func clearActivity(){
        spinner.stopAnimating()
        spinner.isHidden = true
        let labelFrame = CGRect(x: 0, y: self.view.frame.maxY - 48, width: self.view.frame.width, height: 28)
        let label = UILabel(frame: labelFrame)
        label.text = "Swipe 👉"
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-MediumItalic", size: 28.0)
        label.textColor = UIColor.white
        self.view.addSubview(label)
        
    }
    
    func setBackground(){ //try to get not an svg
        if(index == 0){
            print("first index")
            topLabel.text = "Dailycast"
            dataLabel.isHidden = true
            arrowImage.isHidden = true
            topView.isHidden = true
            
            spinner.isHidden = false
            spinner.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.maxY - 32)
            spinner.startAnimating()
            self.view.addSubview(spinner)
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d, yyyy"
            let result = formatter.string(from: date)
            bgView.isHidden = true
            
            dateLabel.text = result
            dateLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 18.0)
            dateLabel.textAlignment = .center
            dateLabel.textColor = UIColor.white
            
            self.view.addSubview(dateLabel)
            

        }
        else{
            topLabel.isHidden = true
            dateLabel.isHidden = true
            imageView.kf.indicatorType = .activity
//            let string = articleURL!.absoluteString
//            let sindex = string.range(of: "/", options: .backwards)?.upperBound
//            let title = string.substring(from: sindex!).replacingOccurrences(of: "_", with: "%20")
            let title = String(dataObject.split(separator: "/").last!)
            print(title)
            
            Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=" + title + "&prop=pageimages&format=json&piprop=original").response{ response in
                if let data = response.data{
                    let json = JSON(data)
                    let dict = json["query"]["pages"].dictionaryValue
                    let pageid: String = String(describing: dict.keys.first!)
                    print(pageid)
                    let image = json["query"]["pages"][pageid]["original"]["source"]
                    dump(image.string)
                    DispatchQueue.main.async() {
                        if(image.string != nil){
                            print("SETTING IMAGE AT ")
                            dump(title)
                            if(image.string?.split(separator: ".").last! == "svg"){
                                print("creating svg")
                                self.handleSVG(url: image.string!)
                            }
                            else{
                                self.imageView.kf.setImage(with: image.url!)
                            }
                        }
                        else{
                            self.backgroundAttempt2(title: title)
                        }
                    }
                }
            }
        }

    }
    
    func handleSVG(url: String){
        do{
            
            self.view.backgroundColor = UIColor.white
            topView.backgroundColor = UIColor.black
            topText.textColor = UIColor.white
            bgView.backgroundColor = UIColor.black
            dataLabel.textColor = UIColor.white

            let svgURL = URL(string: url)!
            let hammock = CALayer(SVGURL: svgURL) { (svgLayer) in
//                svgLayer.fillColor = UIColor(red:0.52, green:0.16, blue:0.32, alpha:1.00).cgColor
                svgLayer.resizeToFit(self.view.bounds)
                svgLayer.backgroundColor = UIColor.white.cgColor
            }
            self.view.layer.addSublayer(hammock)
            
//            let html = try String(contentsOf: URL(string: url)!, encoding: .ascii)
//            let doc: Document = try! SwiftSoup.parse(html)
//            let svg: Elements = try doc.select("svg")
//            let width = try svg.first()?.attr("width").replacingOccurrences(of: "px", with: "")
//            let height = try svg.first()?.attr("height").replacingOccurrences(of: "px", with: "")
//
//            let webView: WKWebView = WKWebView(frame: CGRect(x: 0, y: self.topView.frame.maxY+30, width: self.view.frame.width, height: CGFloat(Int(height!)!)))
//            webView.navigationDelegate = self
//            webView.layer.zPosition = 1
//            webView.load(URLRequest(url: URL(string: url)!))
//            self.view.addSubview(webView)
        }
        catch{
            print(error)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("scaleing")
        let contentSize = webView.scrollView.contentSize;
        let webViewSize = webView.bounds.size;
        do{
            let html = try String(contentsOf: webView.url!, encoding: .ascii)
            let doc: Document = try! SwiftSoup.parse(html)
            let svg: Elements = try doc.select("svg")
            let width = try svg.first()?.attr("width").replacingOccurrences(of: "px", with: "")
            let height = try svg.first()?.attr("height").replacingOccurrences(of: "px", with: "")
            
            print(height)
            print(webView.frame.height)
           
            let scaleFactor = webViewSize.width / CGFloat(Int(width!)!);
            
            webView.scrollView.minimumZoomScale = scaleFactor
            webView.scrollView.maximumZoomScale = scaleFactor
            webView.scrollView.setZoomScale(scaleFactor, animated: false)
            webView.scrollView.isScrollEnabled = false
            webView.isUserInteractionEnabled = false

            
        }
        catch{
            print(error)
        }
       
        
    }

    
    func backgroundAttempt2(title: String){
        print("attempting the background again")
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=" + title + "&prop=images&format=json&piprop=original").response{ response in
            if let data = response.data{
                let json = JSON(data)
                let dict = json["query"]["pages"].dictionaryValue
                let pageid: String = String(describing: dict.keys.first!)
                let image = json["query"]["pages"][pageid]["images"][0]["title"].string!.replacingOccurrences(of: "File:", with: "")
                let imagepath = "https://commons.wikimedia.org/wiki/Special:FilePath/" + image.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                dump(imagepath)
                DispatchQueue.main.async() {
                    if(imagepath != nil){
                        print("SETTING IMAGE AGAIN AT ")
                        print(imagepath)
                        self.imageView.kf.setImage(with: URL(string: imagepath))
                    }
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

