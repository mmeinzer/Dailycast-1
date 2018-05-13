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
import SafariServices

class DataViewController: UIViewController {

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
    

    var imageView: UIImageView!
    var swipeUp: UISwipeGestureRecognizer!
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.zPosition = 0
        view.addSubview(imageView)

        dataLabel.layer.zPosition = 1
        arrowImage.layer.zPosition = 1

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
        bgView.layer.zPosition = 1
        topView.layer.cornerRadius = 2
        topView.layer.zPosition = 1

    }
    
    @objc func swipedAction(){
        print("swipe")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let articleViewController = storyboard.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        articleViewController.url = articleURL
        self.present(articleViewController, animated: true)
//        let config = SFSafariViewController.Configuration()
//        config.entersReaderIfAvailable = true
//        let safariVC = SFSafariViewController(url: articleURL!, configuration: config)
//        present(safariVC, animated: true, completion: nil)
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
    
    func setBackground(){
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
            
            let dateFrame = CGRect(x: topLabel.frame.minX, y: topLabel.frame.maxY+30, width: self.view.frame.width, height: CGFloat(21.0))
            let dateLabel = UILabel(frame: dateFrame)
            dateLabel.text = result
            dateLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 18.0)
            dateLabel.textAlignment = .center
            dateLabel.textColor = UIColor.white
            
            self.view.addSubview(dateLabel)
            

        }
        else{
            topLabel.isHidden = true
            imageView.kf.indicatorType = .activity
            let string = articleURL!.absoluteString
            let sindex = string.range(of: "/", options: .backwards)?.upperBound
            let title = string.substring(from: sindex!).replacingOccurrences(of: "_", with: "%20")
            
            Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=" + title + "&prop=pageviews&format=json").response{ response in
                if let data = response.data{
                    print("pv url")
                    print("https://en.wikipedia.org/w/api.php?action=query&titles=" + title + "&prop=pageviews&format=json")
                    let json = JSON(data)
                    let dict = json["query"]["pages"].dictionaryValue
                    let pageid: String = String(describing: dict.keys.first!)
                    let yesterdayDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
                    let yesterdayFormatter = DateFormatter()
                    yesterdayFormatter.dateFormat = "yyyy-MM-dd"
                    let yesterday = yesterdayFormatter.string(from: yesterdayDate!)
                    let pageviews = json["query"]["pages"][pageid]["pageviews"][yesterday]
                    DispatchQueue.main.async() {
                        self.topText.text = String(describing: pageviews) + " views"
                    }
                }
            }

            
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
                            self.imageView.kf.setImage(with: image.url!)
                        }
                        else{
                            self.backgroundAttempt2(title: title)
                        }
                    }
                }
            }
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
                let imagepath = "https://commons.wikimedia.org/wiki/Special:FilePath/" + image
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

