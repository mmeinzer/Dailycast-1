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
import SwiftSoup
import SafariServices


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



class DataViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var headlineView: UITextView!
    
    var activityCleared = false
    var imageURL: URL?
    var dataObject: String = ""
    var headlineSnippet: String = ""
    var articleURL: URL?
    var index: Int?
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var instructions: UILabel!
    
    var placeholderView: UIImageView!
    var imageView: UIImageView!
    var swipeUp: UISwipeGestureRecognizer!
    var swipeLeft: UISwipeGestureRecognizer!
    var spinner: UIActivityIndicatorView!
    var linkArray: [URL] = []
    var backgroundAttempt = 0
    var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var headlineHeight: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.zPosition = 0
        view.addSubview(blurEffectView)
        blurEffectView.isHidden = true

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
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeftAction))
        swipeLeft.direction = .right
        swipeLeft.delegate = self
        view.addGestureRecognizer(swipeLeft)
        
        //initial spinner
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.isHidden = true
        
        //news view
        placeholderView = UIImageView(frame: CGRect(x: 0, y: self.dateLabel.frame.maxY + 16, width: self.view.frame.width/1.8, height: self.view.frame.width/1.8))
        placeholderView.center = CGPoint(x: self.view.center.x, y: placeholderView.frame.midY)
        placeholderView.image = UIImage(named: "news")
        placeholderView.layer.zPosition = 0
        self.view.addSubview(placeholderView)

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(clearActivity), name: Notification.Name("resetCache"), object: nil)
        
        bgView.layer.cornerRadius = 4
        bgView.layer.zPosition = 2
        topView.layer.cornerRadius = 2
        topView.layer.zPosition = 2
        let topTap = UITapGestureRecognizer(target: self, action: #selector(topTapped))
        topView.addGestureRecognizer(topTap)
        topView.isUserInteractionEnabled = true
        
        let arrowTap = UITapGestureRecognizer(target: self, action: #selector(swipedAction))
        arrowImage.addGestureRecognizer(arrowTap)
        arrowImage.isUserInteractionEnabled = true
        
        
        let sanatize = dataObject.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ")
        topText.text = String(sanatize!).removingPercentEncoding
        
        
        //set logo
        var dim = (self.view.frame.maxY - 42 - dateLabel.frame.maxY)/2
        if(view.frame.width < dim){
            dim = view.frame.width - 32
        }
        logoView.image = UIImage(named: "logo")
 

        
        setBackground()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith slug: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("interaction")
        print(slug)
        print(slug.path)
        
        let svc = SFSafariViewController(url: URL(string: "https://en.wikipedia.org" + slug.path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!)!)
        self.present(svc, animated: true, completion: nil)
        
        return true
    }

    
    @objc func swipedAction(){
        print("swipe")

        if(index != 0){
            
            if #available(iOS 11.0, *) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let svc = SFSafariViewController(url: articleURL!, configuration: config)
                svc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                self.present(svc, animated: true, completion: nil)
            } else {
                let svc = SFSafariViewController(url: articleURL!, entersReaderIfAvailable: true)
                svc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                self.present(svc, animated: true, completion: nil)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func swipedLeftAction(){
        print("swipe left")
        
        if(index == 0){
            
            let today = Date()
            let nexttoday = Calendar.current.date(byAdding: .day, value: -1, to: today)


            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy_MMM_dd"
            let date = formatter.date(from: globalDate)
            
            let todaystring = formatter.string(from: nexttoday!)
            
            if(todaystring != globalDate){
                let next = Calendar.current.date(byAdding: .day, value: 1, to: date!)
                globalDate = formatter.string(from: next!)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "rootview") as! RootViewController
                
                let transition = CATransition()
                transition.duration = 0.3
                
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
                
                self.present(rootViewController, animated: false)
                
                print(todaystring)
                print("isnt")
                print(globalDate)
                
            }
            
            
           
        }
    }
    
    @objc func topTapped(){
            let svc = SFSafariViewController(url: URL(string: "https://en.wikipedia.org" + dataObject)!)
            self.present(svc, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let noExt = headlineSnippet.components(separatedBy: "<a rel=\"nofollow\" class=\"external text\"")[0]
        let attrs = NSMutableAttributedString(html: noExt)
        attrs?.addAttribute(.font, value: UIFont(name: "Avenir", size: 20.0)!, range: NSRange(location:0,length:(attrs?.length)!))

        self.headlineView.attributedText = attrs
        
        resizeFormatHeadline()

    }
    
    func resizeFormatHeadline(){
        headlineView.isScrollEnabled = true
        var font = 20.0
        print("Resizing text")

        let linkText = NSMutableAttributedString(attributedString: headlineView.attributedText)
        let newString = NSMutableAttributedString(attributedString: headlineView.attributedText)
        
        linkText.enumerateAttributes(in: NSRange(0..<linkText.length), options: .reverse) { (attributes, range, pointer) in
            if let _ = attributes[NSAttributedStringKey.link] {
                newString.removeAttribute(NSAttributedStringKey.font, range: range)
                newString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Avenir-Black", size: CGFloat(font)), range: range)
            }
        }
        
        self.headlineView.attributedText = newString
        
        let linkAttributes: [String : Any] = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.black,
            NSAttributedStringKey.underlineColor.rawValue: UIColor.clear]
        self.headlineView.linkTextAttributes = linkAttributes
        
        
        
        while(headlineView.contentSize.height > 146 && font > 15){
            font -= 1
            let resizedText = NSMutableAttributedString(attributedString: headlineView.attributedText)
            resizedText.removeAttribute(NSAttributedStringKey.font, range: NSRange(0..<resizedText.length))
            resizedText.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Avenir", size: CGFloat(font))!, range: NSRange(0..<resizedText.length))
            headlineView.attributedText = resizedText
            print("set font to \(font)")
            
            let linkText = NSMutableAttributedString(attributedString: headlineView.attributedText)
            let newString = NSMutableAttributedString(attributedString: headlineView.attributedText)
            
            linkText.enumerateAttributes(in: NSRange(0..<linkText.length), options: .reverse) { (attributes, range, pointer) in
                if let _ = attributes[NSAttributedStringKey.link] {
                    newString.removeAttribute(NSAttributedStringKey.font, range: range)
                    newString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Avenir-Black", size: CGFloat(font)), range: range)
                }
            }
            self.headlineView.attributedText = newString
        }
        
        if(headlineView.contentSize.height > headlineHeight.constant){
            while(headlineView.contentSize.height + 12 > headlineHeight.constant){
                print("increasing headline size")
                headlineHeight.constant += 2
                self.view.layoutIfNeeded()
            }
        }
        else{
            while(headlineView.contentSize.height + 12 < headlineHeight.constant){
                print("decreasing headline size")
                headlineHeight.constant -= 1
                self.view.layoutIfNeeded()
            }
        }
        
        
        
        
        headlineView.isScrollEnabled = false

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
        activityCleared = true
        
    }
    
    func setBackground(){
        if(index == 0){
            print("first index")
            topLabel.text = "Dailycast"
            headlineView.isHidden = true
            arrowImage.isHidden = true
            topView.isHidden = true
            
            if(!activityCleared){
                spinner.isHidden = false
                spinner.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.maxY - 42)
                spinner.startAnimating()
                self.view.addSubview(spinner)
            }
            else{
                clearActivity()
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy_MMM_dd"
            let date = dateFormatter.date(from: globalDate)
            let next = Calendar.current.date(byAdding: .day, value: 1, to: date!)

            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d, yyyy"
            
            let result = formatter.string(from: next!)
            bgView.isHidden = true
            
            dateLabel.text = result
            dateLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 18.0)
            dateLabel.textAlignment = .center
            dateLabel.textColor = UIColor.white
            
            view.addSubview(dateLabel)
            
            placeholderView.isHidden = true
            
            
            let launchedBefore = UserDefaults.standard.integer(forKey: "launchedBefore")
            if(launchedBefore == nil){
                print("First launch, setting UserDefault.")
                UserDefaults.standard.set(0, forKey: "launchedBefore")
                instructions.isHidden = false
                logoView.isHidden = true
            }
            else if (launchedBefore > 3)  {
                print("More than 3 times")
                instructions.isHidden = true
                logoView.isHidden = false
                UserDefaults.standard.set(launchedBefore + 1, forKey: "launchedBefore")
            } else {
                print("Incrementing launch userDefault.")
                UserDefaults.standard.set(launchedBefore + 1, forKey: "launchedBefore")
                instructions.isHidden = false
                logoView.isHidden = true
            }
            
            let logoTapRec = UITapGestureRecognizer(target: self, action: #selector(logoTap))
            view.addGestureRecognizer(logoTapRec)
            
        }
        else{
            
            
            topLabel.isHidden = true
            dateLabel.isHidden = true
            instructions.isHidden = true
            logoView.isHidden = true

            let title = String(dataObject.split(separator: "/").last!)
            imageURL = images[title]
            
            if(imageURL?.absoluteString != "notfound"){
                print("image background")
                print(imageURL!)
                
                let activity = UIActivityIndicatorView()
                activity.activityIndicatorViewStyle = .white
                let windowx = placeholderView.frame.minX + 0.3278008299*placeholderView.frame.width
                let windowy = placeholderView.frame.minY + 0.3402489627*placeholderView.frame.height

                activity.center = CGPoint(x: windowx, y: windowy)
                activity.startAnimating()
                self.view.addSubview(activity)
                
                
                imageView = UIImageView(frame: view.frame)
                imageView.clipsToBounds = true
                imageView.layer.zPosition = 1
                
                self.imageView.kf.setImage(with: imageURL, completionHandler: { (image, error, cacheType, imageUrl) in
                    if(image != nil){
                        print("image dimensions:")
                        let size = image?.size
                        
                        if(Int((size?.height)!) > Int(((size?.width)!*0.5))){ //if height is more than half the width
                            self.imageView.contentMode = .scaleAspectFill
//                            self.imageView.contentMode = .center
                        }
                        else{
                            self.imageView.contentMode = .scaleAspectFit
                            self.imageView.frame.insetBy(dx: 10, dy: 10)
                            self.imageView.transform = CGAffineTransform(translationX: 0.0, y: -self.headlineView.frame.height / 2 ) //set between headline and topic
                        }
                        
                        self.view.addSubview(self.imageView)
                        
                        activity.stopAnimating()
                        activity.removeFromSuperview()
                        self.placeholderView.isHidden = true
                        self.view.backgroundColor = UIColor(patternImage: image!)
                        self.blurEffectView.isHidden = false

                    }
                    else{
                        activity.stopAnimating()
                        activity.removeFromSuperview()
                    }
                })
            }
            else{
                print("no background here")
            }

        }
        view.sendSubview(toBack: blurEffectView)
    }
    
    @objc func logoTap(sender: UITapGestureRecognizer){
        print("logo tap")
        if(logoView.isHidden){
            instructions.isHidden = true
            logoView.isHidden = false
        }
        else{
            instructions.isHidden = false
            logoView.isHidden = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

