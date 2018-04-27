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
    
    var swipeUp: UIPanGestureRecognizer!

    var animatedView: AnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        animatedView = AnimatedImageView(frame: view.frame)
        animatedView.contentMode = .scaleAspectFill
        animatedView.clipsToBounds = true
        animatedView.layer.zPosition = 0
        view.addSubview(animatedView)

        topLabel.text = dataObject
        topLabel.layer.zPosition = 1
        dataLabel.layer.zPosition = 1
        arrowImage.layer.zPosition = 1

        topLabel.backgroundColor = UIColor.black
        
        swipeUp = UIPanGestureRecognizer(target: self, action: #selector(self.swipeGesture))
        
        view.addGestureRecognizer(swipeUp)
        
        setBackground()
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
    
    
    @objc func swipeGesture(gesture: UIGestureRecognizer){
//        guard let panRecognizer = gesture as? UIPanGestureRecognizer else {
//            return super.gestureRecognizerShouldBegin(gesture)
//        }
//        let velocity = panRecognizer.velocity(in: self)
//        if abs(velocity.y) > abs(velocity.x) {
//            dump(gesture.location(in: view))
//        }
    }
    
    func setBackground(){
        print("setting background at index \(index!)")

        animatedView.kf.indicatorType = .activity
        animatedView.kf.setImage(with: gifURLs[index!])




    }


}

