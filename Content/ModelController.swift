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
import SWXMLHash
import Kingfisher
import SwiftyJSON

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

var gifURLs: [Int : URL] = [0 : URL(string: "http://google.com")!] //global

class ModelController: NSObject, UIPageViewControllerDataSource {

    
    var topics: [String] = ["one"]
    var headlines: [String] = ["first"]

    override init() {
        super.init()
        getHeadlines()
    }
    
    
    func getHeadlines(){
        Alamofire.request("https://trends.google.com/trends/hottrends/atom/feed?pn=p1").response{ response in
            if let data = response.data{
                let xml = SWXMLHash.parse(data)
                let items = xml["rss"]["channel"]["item"]
                for i in 0 ... items.all.count - 1{
                    self.topics.append(items[i]["title"].element!.text)
                    self.headlines.append(items[i]["ht:news_item"][0]["ht:news_item_title"].element!.text.html2String)
                }
                self.preFetch()

            }
        }
    }
    
    func preFetch(){
        print("getting gif urls") //these gifs need to be more contextually aware. fix later
        for i in 0 ... topics.count - 1{
            Alamofire.request("https://api.giphy.com/v1/gifs/search?api_key=ZIZcdJ26TgdNjrBGCVompOfU1eYVWY8F&q=" + topics[i].addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&limit=3&offset=0&rating=PG&lang=en").responseJSON{ response in
                if let result = response.result.value {
                    let json = JSON(result)
                    let number = Int(arc4random_uniform(2))
                    gifURLs[i] = (json["data"][number]["images"]["original"]["url"].url!) //random of 1st 3 results
                }
                if(i == (self.topics.count - 1)){
                    print("prefetching")
                    let prefetcher = ImagePrefetcher(urls: Array(gifURLs.values)) {
                        skippedResources, failedResources, completedResources in
                        print("Prefetched: \(completedResources.count)")
                        print("Skipped: \(skippedResources.count)")
                        print("Failed: \(failedResources.count)")
                    }
                    prefetcher.start()
                    
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
        print("index")
        dump(index)
        if(index != -1){
            let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
            dataViewController.dataObject = self.topics[index]
            dataViewController.headlineSnippet = self.headlines[index]
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
        
        if (index == 0) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let interestsViewController = storyboard.instantiateViewController(withIdentifier: "InterestsViewController") as! InterestsViewController
            return interestsViewController
        }
        else if(index == NSNotFound){
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.topics.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

}

