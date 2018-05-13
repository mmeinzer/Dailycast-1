//
//  ModelController.swift
//  Dailycast
//
//  Created by Adam Barr-Neuwirth on 4/25/18.
//  Copyright © 2018 Somdede. All rights reserved.
//

import UIKit

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

import Alamofire
import Kingfisher
import SwiftyJSON
import SwiftSoup

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


class ModelController: NSObject, UIPageViewControllerDataSource {

    
    var topics: [String] = ["one"]
    var headlines: [String] = ["first"]
    var urls: [URL] = [URL(string: "http://google.com")!]
    var arrayLoaded = false

    override init() {
        super.init()
        getHeadlines()
    }
    
    
    func getHeadlines(){
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=parse&format=json&prop=text&page=Template:In_the_news").response{ response in
            if let data = response.data{
                let json = JSON(data)
                let fullhtml = json["parse"]["text"]["*"].string!
                let separator = """
                <div class=\"itn-footer\"
                """
                let html = fullhtml.components(separatedBy: separator)[0]
                do{
                    let doc: Document = try! SwiftSoup.parse(html)
                    let li: Elements = try doc.select("li")
                    for element in li.array(){
                        print("LI IS HERE")
                        self.headlines.append(try element.text())
                        let bold = try element.select("b")
                        self.topics.append(try bold.text())
                        let link = try bold.select("a")
                        let url = try link.attr("href")
                        self.urls.append(URL(string: "https://en.wikipedia.org" + url)!)
                    }

                }
                catch Exception.Error(let type, let message) {
                    print(message)
                } catch {
                    print("error")
                }
                
                self.arrayLoaded=true
                let nc = NotificationCenter.default
                DispatchQueue.main.async() {
                    nc.post(name: Notification.Name("resetCache"), object: nil)
                }

            }
        }
    }
    
    

    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.topics.count == 0) || (index >= self.topics.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.

        if(index != -1){
            let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
            dataViewController.dataObject = self.topics[index]
            dataViewController.headlineSnippet = self.headlines[index]
            dataViewController.articleURL = self.urls[index]
            dataViewController.index = index
            return dataViewController
        }
        return nil
    }

    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return topics.index(of: viewController.dataObject) ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = 0
        if(viewController.classForCoder == DataViewController.self){
            index = self.indexOfViewController(viewController as! DataViewController)
        }
        
//        if (index == 0) {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let interestsViewController = storyboard.instantiateViewController(withIdentifier: "InterestsViewController") as! InterestsViewController
//            return interestsViewController
//        }
//        else if(index == NSNotFound){
//            return nil
//        }

        if(index == NSNotFound){
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = topics.count
        if(viewController.classForCoder == DataViewController.self){
            index = self.indexOfViewController(viewController as! DataViewController)
        }
        if (index == NSNotFound || arrayLoaded == false) {
            return nil
        }
        
        index += 1
        if index == self.topics.count {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let doneViewController = storyboard.instantiateViewController(withIdentifier: "DoneViewController") as! DoneViewController
            return doneViewController
        }
        else if index == self.topics.count + 1{
            return nil
        }

        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}

