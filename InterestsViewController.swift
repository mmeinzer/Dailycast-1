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
    @IBOutlet weak var checkView: M13Checkbox!
    var unchecked = false
    
    override func layoutSubviews() {
        checkView.stateChangeAnimation = .bounce(.fill)
        checkView.tintColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
        checkView.isUserInteractionEnabled = false
        if(unchecked){
            checkView.checkState = .unchecked
        }
        else{
            checkView.checkState = .checked
        }
    }
    
}

class InterestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var actionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.separatorStyle = .none
        
        actionView.layer.cornerRadius = 4.0
        actionView.layer.masksToBounds = true
    }
    
    var subjectList = ["Wikipedia", "Reuters", "The New York Times", "Sky News", "BBC", "The Wall Street Journal", "CBC", "Associated Press", "CBS News", "The Guardian", "Business Insider", "CNN", "CNBC", "MSNBC", "Fox News", "Euronews", "NPR", "ABC News", "Wikipedia", "Local News Sources"]
    let selection = UISelectionFeedbackGenerator()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! InterestsTableCell
        cell.checkView.toggleCheckState(true)
        selection.selectionChanged()
    
        if(cell.checkView.checkState == .unchecked){
            UserDefaults.standard.set(true, forKey: "row" + String(describing: indexPath.row))
        }
        else{
            UserDefaults.standard.removeObject(forKey: "row" + String(describing: indexPath.row))
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: InterestsTableCell, forRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestsTableCell
        
        cell.subjectLabel.text = subjectList[indexPath.row]
        
        if UserDefaults.standard.object(forKey: "row" + String(describing: indexPath.row)) != nil{
            cell.unchecked = true
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    
    
}
