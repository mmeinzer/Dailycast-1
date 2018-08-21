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


var images: [String: URL] = [:]

var globalDate = ""

extension UIPageViewController {
    
    func goToNextPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: animated, completion: nil)
    }
    
    func goToPreviousPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: animated, completion: nil)
    }
    
}

class ModelController: NSObject, UIPageViewControllerDataSource {

    
    var topics: [String] = ["one"]
    var headlines: [String] = ["first"]
    var urls: [URL] = [URL(string: "http://google.com")!]
    var arrayLoaded = false
    var count = 0
    var disallowed: [String] = []
    let sources = ["wikipedia", "reuters", "nytimes", "sky", "bbc", "wsj", "cbc", "ap", "cbsnews", "theguardian", "businessinsider", "cnn", "cnbc", "msnbc", "foxnews", "euronews", "npr", "abcnews", "telegraph", "politico", "Local News Sources"]
    
    override init() {
        super.init()
        
        getHeadlines()

 
    }
    
    
    
    func getHeadlines(){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MMMM_d"
        print("date is \(globalDate)")
        var result = globalDate
        if(globalDate == ""){
            print("no date provided")
            let previous = Calendar.current.date(byAdding: .day, value: -1, to: date)
            result = formatter.string(from: previous!)
            globalDate = formatter.string(from: previous!)
        }
//       result = "2018_May_16" //THIS IS FOR DEBUG
        
        var i = 0
        for element in sources{
            if let cellbool = UserDefaults.standard.object(forKey: "row" + String(describing: i)) as? Bool{
                if(cellbool){
                    disallowed.append(element)
                }
            }
            i += 1
        }
        print("Disallowed")
        print(disallowed)
        
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=parse&format=json&prop=text&page=Portal:Current_events/" + result).response{ response in
            if let data = response.data{
                let json = JSON(data)
                print(result)
                print(json["parse"]["text"]["*"])
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
                            var skip = false
                            let subelements = try element.select("ul").array().count
                            if(subelements == 0){
                                print(try element.text())
                                print("has no subelememnts")
                                let lasturl = try element.select("a").array().last?.attr("href").asURL() //check source here
                                for element in self.disallowed{
                                    print(element)
                                    print(lasturl)
                                    if (lasturl?.host != nil && (lasturl?.host?.contains(element))!){
                                        print("skipping")
                                        skip=true
                                    }
                                }
                                if(!skip){
                                    print("not skipping")
                                    self.headlines.append(try element.html())

                                    self.urls.append(lasturl!)
                                    print(lasturl)
                                    if(self.topics.count < self.headlines.count){
                                        let topic = try element.select("a").first()?.attr("href")
                                        if(topic?.contains("wiki"))!{
                                            self.topics.append(topic!)
                                        }
                                        else{
                                            self.topics.append("News")
                                        }
                                    }
                                }
                            }
                            else{
                                print("at else")
                                if(!skip){
                                    print("not skipping")
                                    if(self.topics.count < self.headlines.count + 1){
                                        let topic = try element.select("a").first()?.attr("href")
                                        if(topic?.contains("wiki"))!{
                                            self.topics.append(topic!)
                                        }
                                        else{
                                            self.topics.append("News")
                                        }
                                    }
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
                DispatchQueue.main.async() {
                    self.getImages()
                }
            }
        }
    }
    
    func getImages() {
        for element in self.topics.dropFirst(){
            let title = String(element.split(separator: "/").last!)
            self.getPageImage(title: title)
        }
    }
    
    func prefetchImages(){
        print("image dict")
        dump((images))
        let prefetcher = ImagePrefetcher(urls: Array(images.values)) {
            skippedResources, failedResources, completedResources in
            print("These resources have been prefetched: \(completedResources)")
            print("These resources were already prefetched: \(skippedResources)")
        }
        prefetcher.start()
        
        arrayLoaded = true
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("resetCache"), object: nil)
        
    }
    
    func imagedAdded(){
        count += 1
        if(count == topics.count - 1){
            prefetchImages()
        }
    }
    
    func getPageImage(title: String){
        let newtitle = title.split(separator: "#")[0]
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=" + newtitle + "&prop=pageimages&format=json&piprop=original").response{ response in
            if let data = response.data{
                let json = JSON(data)
                let dict = json["query"]["pages"].dictionaryValue
                let pageid: String = String(describing: dict.keys.first!)
                let image = json["query"]["pages"][pageid]["original"]["source"]
                DispatchQueue.main.async() {
                    if(image.string != nil){
                        if(image.string?.split(separator: ".").last! == "svg"){
                            print("Main image is an svg, parsing through the rest of the page")
                            self.findImageOnPage(title: title)
                        }
                        else{
                            print("Setting \(title) main page image from: ")
                            dump(image.string!)
                            images[title] = (image.url!)
                            self.imagedAdded()
                        }
                    }
                    else{
                        print("No main image, parsing through the rest of the page")
                        self.findImageOnPage(title: title)
                    }
                }
            }
        }
    }
    
    func findImageOnPage(title: String){
        let cleantitle = title.split(separator: "#")[0]
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=" + cleantitle + "&prop=images&redirects&format=json").response{ response in
            if let data = response.data{
                let json = JSON(data)
                let dict = json["query"]["pages"].dictionaryValue
                let pageid: String = String(describing: dict.keys.first!)
                let queryimages = json["query"]["pages"][pageid]["images"]
                var image = ""
                if(queryimages.count == 0){
                    image = ""
                }
                else{
                    for i in 0...queryimages.count-1{
                        let filepath = queryimages[i]["title"].string!
                        print("checking \(filepath)")
                        let filetype = filepath.split(separator: ".").last!
                        if(filetype != "svg" && filetype != "tif" && filetype != "webm"){
//                            image = "https://commons.wikimedia.org/wiki/Special:FilePath/" + filepath.split(separator: ":")[1].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                            image = filepath
                            break //this sucks
                        }
                    }
                }
                DispatchQueue.main.async() {
                    
                    if(image != ""){
                        print("Setting image from page with url \(image)")
                        self.tryForImage(filepath: image, title: title)
                    }
                    else{
                        print("no image")
                        images[title] = (URL(string: "notfound")!)
                        self.imagedAdded()
                    }
                }
            }
        }
    }
    
    func tryForImage(filepath: String, title: String){
        
        print("getting https://en.wikipedia.org/w/api.php?action=query&titles=" + filepath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! + "&prop=imageinfo&iiprop=url&format=json")
        
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=" + filepath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! + "&prop=imageinfo&iiprop=url&format=json").response{ response in
            if let data = response.data{

                let newjson = JSON(data)
                let dict = newjson["query"]["pages"].dictionaryValue
                let pageid: String = String(describing: dict.keys.first!)
                print("pageurlid: \(pageid)")
                dump(newjson)
                if let url = newjson["query"]["pages"][pageid]["imageinfo"][0]["url"].url{
                    print("image = \(url)")
                    images[title] = url
                    self.imagedAdded()
                }
                else{
                    print("no image")
                    images[title] = (URL(string: "notfound")!)
                    self.imagedAdded()
                }
            }
        }
    }
    

    func viewControllerAtIndex(_ index: Int, activityCleared: Bool, storyboard: UIStoryboard) -> DataViewController? {
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
            dataViewController.activityCleared = activityCleared
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
        else if(viewController.classForCoder == InterestsViewController.self){
            return nil
        }

        if (index == 0) {
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy_MMMM_d"
            let previous = Calendar.current.date(byAdding: .day, value: -1, to: date)
            let result = formatter.string(from: previous!)
            if(result == globalDate){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let interestsViewController = storyboard.instantiateViewController(withIdentifier: "InterestsViewController") as! InterestsViewController
                return interestsViewController
            }
        }
        else if(index == NSNotFound){
            return nil
        }
        
        if(index == NSNotFound){
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, activityCleared: true, storyboard: viewController.storyboard!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = topics.count
        if(viewController.classForCoder == DataViewController.self){
            index = self.indexOfViewController(viewController as! DataViewController)
        }
        else if(viewController.classForCoder == InterestsViewController.self){
            return self.viewControllerAtIndex(0, activityCleared: false, storyboard: viewController.storyboard!)

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

        return self.viewControllerAtIndex(index, activityCleared: false, storyboard: viewController.storyboard!)
    }
    
}

