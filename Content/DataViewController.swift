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

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [kCIContextWorkingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

class DataViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""
    var headlineSnippet: String = ""
    var index: Int?

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

        topLabel.backgroundColor = UIColor.black
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
    
    
    
    func setBackground(){
        print("setting background at index \(index!)")

        animatedView.kf.indicatorType = .activity
        animatedView.kf.setImage(with: gifURLs[index!])

//        if let nextGif = [gifURLs[index!+1]]{
//            let prefetcher = ImagePrefetcher(urls: [nextGif]) {
//                skippedResources, failedResources, completedResources in
//                print("Prefetched: \(completedResources.count)")
//                print("Skipped: \(skippedResources.count)")
//                print("Failed: \(failedResources.count)")
//            }
//            prefetcher.start()
//        }


    }


}

