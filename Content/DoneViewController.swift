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

class DoneViewController: UIViewController{
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var yesterdayView: UIView!
    @IBOutlet weak var yesterdayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setup
        let checkbox = M13Checkbox(frame: checkView.frame)
        checkbox.stateChangeAnimation = .stroke
        checkbox.tintColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
        checkbox.isUserInteractionEnabled = false
        checkbox.checkmarkLineWidth = 8.0
        checkbox.boxLineWidth = 8.0
        view.addSubview(checkbox)
        let success = UINotificationFeedbackGenerator()

        yesterdayView.layer.cornerRadius = 2
        yesterdayView.layer.zPosition = 2
        let yesterdayTap = UITapGestureRecognizer(target: self, action: #selector(yesterdayTapped))
        yesterdayView.addGestureRecognizer(yesterdayTap)
        
        
        
        checkbox.toggleCheckState(true)
        success.notificationOccurred(.success)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MMM_dd"
        let date = formatter.date(from: globalDate)
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "MMM d"
        let buttonText = simpleFormatter.string(from: date!)
        
        yesterdayLabel.text = "See news for " + buttonText
    }
    
    @objc func yesterdayTapped(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MMM_dd"
        let date = formatter.date(from: globalDate)
        let previous = Calendar.current.date(byAdding: .day, value: -1, to: date!)
        globalDate = formatter.string(from: previous!)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "rootview") as! RootViewController
        self.present(rootViewController, animated: true)
    }
}
