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
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MMM_dd"
        let result = formatter.string(from: date)
//        let result = "2018_May_16"
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=parse&format=json&prop=text&page=Portal:Current_events/" + result).response{ response in
            if let data = response.data{
                let json = JSON(data)
                let fullhtml = json["parse"]["text"]["*"].string!
                let separator = """
                <div role=\"heading\"
                """
                let html = fullhtml.components(separatedBy: separator)
                //news starts at index 2
                
                for i in 2 ... html.count - 1{
                    dump("index ")
                    dump(i)
                    do{
                        let doc: Document = try! SwiftSoup.parse(html[i])
                        let li: Elements = try doc.select("li")
                        
                        let sublist = try li.select("li").array()
                        
                        for element in sublist{
                            let subelements = try element.select("ul").array().count
                            if(subelements == 0){
                                print(try element.text())
                                print("has no subelememnts")
                                self.headlines.append(try element.html())
                                let lasturl = try element.select("a").array().last?.attr("href").asURL()
                                self.urls.append(lasturl!)
                                
                                if(self.topics.count < self.headlines.count){
                                    let topic = try element.select("a").first()?.attr("href")
//
//                                    let linkArray = try element.select("a").array()
//                                    var topicArray: [String] = []
//                                    for i in 0...(linkArray.count - 1) {
//                                        topicArray.append(try linkArray[i].attr("href"))
//                                    }
                                    self.topics.append(topic!)
                                }
                            }
                            else{
                                print("at else")
                                if(self.topics.count < self.headlines.count + 1){
                                    let topic = try element.select("a").first()?.attr("href")
//                                    
//                                    let linkArray = try element.select("a").array()
//                                    var topicArray: [String] = []
//                                    for i in 0...(linkArray.count - 1) {
//                                        topicArray.append(try linkArray[i].attr("href"))
//                                    }
                                    self.topics.append(topic!)
                                }
                                
                            }
                        }
                        
                        print("topic array:")
                        dump(self.topics)


                    }
                    catch {
                        print("error")
                    }
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

