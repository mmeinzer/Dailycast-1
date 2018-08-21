//
//  DoneViewController.swift
//  Dailycast
//
//  Created by Adam Barr-Neuwirth on 5/12/18.
//  Copyright © 2018 Somdede. All rights reserved.
//

import Foundation
import UIKit
import M13Checkbox
import SwiftyRate

class DoneViewController: UIViewController, UIGestureRecognizerDelegate{
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var yesterdayView: UIView!
    @IBOutlet weak var yesterdayLabel: UILabel!
    var swipeLeft: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setup
        SwiftyRate.request(from: self, afterAppLaunches: 3)

        let checkbox = M13Checkbox(frame: checkView.frame)
        checkbox.stateChangeAnimation = .stroke
        checkbox.tintColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
        checkbox.isUserInteractionEnabled = false
        checkbox.checkmarkLineWidth = 8.0
        checkbox.boxLineWidth = 8.0
        view.addSubview(checkbox)
        let success = UINotificationFeedbackGenerator()

        yesterdayView.layer.cornerRadius = 4
        yesterdayView.layer.zPosition = 2
        let yesterdayTap = UITapGestureRecognizer(target: self, action: #selector(yesterdayTapped))
        yesterdayView.addGestureRecognizer(yesterdayTap)
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeftAction))
        swipeLeft.direction = .left
        swipeLeft.delegate = self
        view.addGestureRecognizer(swipeLeft)
        
        
        checkbox.toggleCheckState(true)
        success.notificationOccurred(.success)
        

        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func swipedLeftAction(){
        print("swipe left")
        yesterdayTapped()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MMMM_d"
        let date = formatter.date(from: globalDate)
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "MMM d"
        let buttonText = simpleFormatter.string(from: date!)
        
        yesterdayLabel.text = "See news for " + buttonText + " 👉"
    }
    
    @objc func yesterdayTapped(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MMMM_d"
        let date = formatter.date(from: globalDate)
        let previous = Calendar.current.date(byAdding: .day, value: -1, to: date!)
        globalDate = formatter.string(from: previous!)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "rootview") as! RootViewController

        let transition = CATransition()
        transition.duration = 0.3
        
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)

        self.present(rootViewController, animated: false)
    }
}
