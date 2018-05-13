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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //setup
        let checkbox = M13Checkbox(frame: checkView.frame)
        checkbox.stateChangeAnimation = .stroke
        checkbox.tintColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
        checkbox.isUserInteractionEnabled = false
        checkbox.checkmarkLineWidth = 8.0
        checkbox.boxLineWidth = 8.0
        view.addSubview(checkbox)
        let success = UINotificationFeedbackGenerator()
        
        //run
//        let today = Date()
//
//        if let finished = UserDefaults.standard.object(forKey: "finished") as? Date {
//            if(today != finished){
//                checkbox.toggleCheckState(true)
//                success.notificationOccurred(.success)
//            }
//        }
//        else{
//            checkbox.toggleCheckState(true)
//            success.notificationOccurred(.success)
//        }
//
//        //finished today
//        UserDefaults.standard.set(today, forKey: "finished")
        
        checkbox.toggleCheckState(true)
        success.notificationOccurred(.success)

    }
}
