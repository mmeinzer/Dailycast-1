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

extension NSMutableAttributedString {
    
    internal convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }
        
        guard let attributedString = try? NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString: attributedString)
    }
}


class DataViewController: UIViewController, WKNavigationDelegate, UITextViewDelegate{

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var headlineView: UITextView!
    
    
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
    var linkArray: [URL] = []
    var backgroundAttempt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("index \(index)")
        imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.zPosition = 1
        view.addSubview(imageView)
        
        
        headlineView.layer.zPosition = 2
        headlineView.isScrollEnabled = false
        headlineView.isEditable = false
        headlineView.isSelectable = true
        headlineView.delegate = self
        headlineView.isUserInteractionEnabled = true
        
        arrowImage.layer.zPosition = 2

        topLabel.backgroundColor = UIColor.black
        
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedAction))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.isHidden = true
        
        setBackground() //have this fetch the next background

        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(clearActivity), name: Notification.Name("resetCache"), object: nil)
        
        bgView.layer.cornerRadius = 4
        bgView.layer.zPosition = 2
        topView.layer.cornerRadius = 2
        topView.layer.zPosition = 2
        
        let sanatize = dataObject.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ")
        topText.text = String(sanatize!).removingPercentEncoding

        
        let placeholderView = UIImageView(frame: CGRect(x: 0, y: self.dateLabel.frame.maxY + 16, width: self.view.frame.width/1.8, height: self.view.frame.width/1.8))
        placeholderView.center = CGPoint(x: self.view.center.x, y: placeholderView.frame.midY)
        
        placeholderView.image = UIImage(named: "news")
        placeholderView.layer.zPosition = 0
        
        self.view.addSubview(placeholderView)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith slug: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("interaction")
        print(slug)
        print(slug.path)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let articleViewController = storyboard.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        articleViewController.url = URL(string: "https://en.wikipedia.org" + slug.path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!)
        self.present(articleViewController, animated: true)
        
        return true
    }

    
    @objc func swipedAction(){
        print("swipe")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let articleViewController = storyboard.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        articleViewController.url = articleURL
        if(index != 0){
            self.present(articleViewController, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let attrs = NSMutableAttributedString(html: headlineSnippet)
        attrs?.addAttribute(.font, value: UIFont(name: "Avenir", size: 18.0)!, range: NSRange(location:0,length:(attrs?.length)!))
        self.headlineView.attributedText = attrs
        
        //set the font to fit the frame here
        
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
            headlineView.isHidden = true
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
            
            if(backgroundAttempt >= dataObject.indices.count - 1){
                print("too many attempts")
                //break out
            }
            else{
                let title = String(dataObject.split(separator: "/").last!)
                print("attempting to get an image from:")
                print(title)
                print("we're on attempt number \(backgroundAttempt)")

                getPageImage(title: title)
                
            }
        }
    }
    
    func getPageImage(title: String){
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=" + title + "&prop=pageimages&format=json&piprop=original").response{ response in
            if let data = response.data{
                let json = JSON(data)
                let dict = json["query"]["pages"].dictionaryValue
                let pageid: String = String(describing: dict.keys.first!)
                let image = json["query"]["pages"][pageid]["original"]["source"]
                DispatchQueue.main.async() {
                    if(image.string != nil){
                        if(image.string?.split(separator: ".").last! == "svg"){
                            print("Main image is an svg, parsing through the rest of the page")
                            self.findImageOnPage(title: title)
                        }
                        else{
                            print("Setting main page image from: ")
                            dump(image.string!)
                            self.imageView.kf.setImage(with: image.url!)
                            self.checkForDefaultImage()
                        }
                    }
                    else{
                        print("No main image, parsing through the rest of the page")
                        self.findImageOnPage(title: title)
                    }
                }
            }
        }
    }
    
    func findImageOnPage(title: String){
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=" + title + "&prop=images&redirects&format=json").response{ response in
            if let data = response.data{
                let json = JSON(data)
                let dict = json["query"]["pages"].dictionaryValue
                let pageid: String = String(describing: dict.keys.first!)
                let images = json["query"]["pages"][pageid]["images"]
                var image = ""
                for i in 0...images.count-1{
                    let filepath = images[i]["title"].string!
                    let filetype = filepath.split(separator: ".").last!
                    if(filetype != "svg" && filetype != "tif"){
                        image = "https://commons.wikimedia.org/wiki/Special:FilePath/" + filepath.split(separator: ":")[1].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                        break //this sucks
                    }
                }
                DispatchQueue.main.async() {
                    
                    if(image != ""){
                        print("Setting image from page with url \(image)")
                        self.imageView.kf.setImage(with: URL(string: image))
                        self.checkForDefaultImage()
                    }
                    else{
                        print("no image")

                    }
                }
            }
        }
    }
    
    func checkForDefaultImage(){
        if(imageView.image == nil){
            
        }
    }
    
    
    
    func handleSVG(url: String){
        do{
            
            self.view.backgroundColor = UIColor.white
            topView.backgroundColor = UIColor.black
            topText.textColor = UIColor.white
            bgView.backgroundColor = UIColor.black
            headlineView.textColor = UIColor.white
            headlineView.backgroundColor = UIColor.black
            
//            guard let text = self.headlineView.attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
//            text.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location:0,length:(text.length)))
//            self.headlineView.attributedText = text
            
            let svgURL = URL(string: url)!
            let hammock = CALayer(SVGURL: svgURL) { (svgLayer) in
                svgLayer.resizeToFit(self.view.bounds)
                svgLayer.backgroundColor = UIColor.white.cgColor
            }
            self.view.layer.addSublayer(hammock)
        }
        catch{
            print(error)
        }
    }
    


    

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

