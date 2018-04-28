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


class DataViewController: UIViewController {

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""
    var headlineSnippet: String = ""
    var index: Int?
    

    var animatedView: UIImageView!
    var swipeUp = UISwipeGestureRecognizer!
    
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
        
        setBackground()
    }
    
    func swipedAction(){
        
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
    
    
    func setBackground(){
        print("setting background at index \(index!)")

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

