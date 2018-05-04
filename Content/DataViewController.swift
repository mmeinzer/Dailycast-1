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
import SwiftyGif
import Kingfisher
import SafariServices

class DataViewController: UIViewController {

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""
    var headlineSnippet: String = ""
    var articleURL: URL?
    var index: Int?
    

    var animatedView: UIImageView!
    var swipeUp: UISwipeGestureRecognizer!
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        animatedView = UIImageView(frame: view.frame)
        animatedView.contentMode = .scaleAspectFill
        animatedView.clipsToBounds = true
        animatedView.layer.zPosition = 0
        view.addSubview(animatedView)

        topLabel.text = dataObject
        topLabel.layer.zPosition = 1
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

    }
    
    @objc func swipedAction(){
        print("swipe")
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let articleViewController = storyboard.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
//        articleViewController.url = articleURL
//        self.present(articleViewController, animated: true)
        let urlString = "http://www.google.com"
        let url = URL(string: urlString)!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safariVC = SFSafariViewController(url: url, configuration: config)
        present(safariVC, animated: true, completion: nil)
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
    
    
    func preFetch(array: [URL]){
        print("prefetching")
        let prefetcher = ImagePrefetcher(urls: array) {
            skippedResources, failedResources, completedResources in
            print("Prefetched: \(completedResources.count)")
            print("Skipped: \(skippedResources.count)")
            print("Failed: \(failedResources.count)")
        }
        prefetcher.start()
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
        print("setting background at index \(index!)")

        if(index == 0){
            print("first index")
            topLabel.text = "Dailycast"
            dataLabel.isHidden = true
            arrowImage.isHidden = true
            
            spinner.isHidden = false
            spinner.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.maxY - 32)
            spinner.startAnimating()
            self.view.addSubview(spinner)
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d, yyyy"
            let result = formatter.string(from: date)

            
            let dateFrame = CGRect(x: topLabel.frame.minX, y: topLabel.frame.maxY+30, width: self.view.frame.width, height: CGFloat(21.0))
            let dateLabel = UILabel(frame: dateFrame)
            dateLabel.text = result
            dateLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 18.0)
            dateLabel.textAlignment = .center
            dateLabel.textColor = UIColor.white
            
            self.view.addSubview(dateLabel)
            

        }
        else{
            animatedView.kf.indicatorType = .activity
            let imageArray = gifURLs[index!]

            animatedView.kf.setImage(with: imageArray?[0])
            preFetch(array: imageArray!)

            var i = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (timer) in
                print("timer")
                i += 1
                if(i == 3){ i = 0 }

                self.animatedView.kf.setImage(with: imageArray?[i], options: [.onlyFromCache])
            }
            RunLoop.current.add(timer, forMode: .commonModes)
        }

    }



}

