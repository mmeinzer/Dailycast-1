//
//  InterestsViewController.swift
//  Dailycast
//
//  Created by Adam Barr-Neuwirth on 4/26/18.
//  Copyright © 2018 Somdede. All rights reserved.
//

import Foundation
import UIKit
import M13Checkbox

 class InterestsTableCell: UITableViewCell{
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var checkView: UIView!
    var checkbox: M13Checkbox?
    
}

class InterestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    var subjectList = ["Top Stories", "Trending Searches", "Business", "Technology", "Politics", "Sports", "Arts", "Travel"]
    let selection = UISelectionFeedbackGenerator()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! InterestsTableCell
        cell.checkbox?.toggleCheckState(true)
        selection.selectionChanged()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestsTableCell
        
        cell.subjectLabel.text = subjectList[indexPath.row]
        cell.checkbox = M13Checkbox(frame: cell.checkView.frame)
        cell.checkbox?.stateChangeAnimation = .bounce(.fill)
        cell.checkbox?.tintColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
        cell.checkbox?.isUserInteractionEnabled = false
        cell.addSubview(cell.checkbox!)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    
    
}
