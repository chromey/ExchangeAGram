//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Christian Romeyke on 29/11/14.
//  Copyright (c) 2014 Christian Romeyke. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var feedItem: FeedItem!
    var collectionView: UICollectionView!
    let kIntensity = 0.7
    var context: CIContext = CIContext(options: nil)
    var filters: [CIFilter] = []
    let placeHolderImage = UIImage(named: "Placeholder")
    let tmp = NSTemporaryDirectory()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150, height: 150)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "filterCell")
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as FilterCell
        cell.imageView.image = placeHolderImage
        
        let filterQueue: dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getCachedImage(indexPath.item)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })
        return cell
    }
    
    // UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        createUIAlertController(indexPath)
    }
    
    // helper function
    
    func photoFilters() -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    func filteredImage(#fromImage: NSData, filter: CIFilter) -> UIImage {
        
        var sourceImage = CIImage(data: fromImage)
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        let filteredImage: CIImage = filter.outputImage
        let extent = filteredImage.extent()
        let cgImage = context.createCGImage(filteredImage, fromRect: extent)
        
        return UIImage(CGImage: cgImage)!
    }
    
    // UIAlertController helper functions
    
    func createUIAlertController(indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        let textField = alert.textFields![0] as UITextField

        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Destructive) { (uiAlertAction) -> Void in
            self.shareToFacebook(indexPath)
            self.saveFilterToCoreData(indexPath, caption: textField.text)

        }
        alert.addAction(photoAction)
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting to Facebook", style: UIAlertActionStyle.Default) { (uiAlertAction) -> Void in
            self.saveFilterToCoreData(indexPath, caption: textField.text)
        }
        alert.addAction(saveFilterAction)
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (uiAlertAction) -> Void in
            
        }
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveFilterToCoreData(indexPath: NSIndexPath, caption: String) {
        let filteredImage = self.filteredImage(fromImage: feedItem.image, filter: filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filteredImage, 1.0)
        self.feedItem.image = imageData
        let thumbNailData = UIImageJPEGRepresentation(filteredImage, 0.1)
        self.feedItem.thumbNail = thumbNailData
        self.feedItem.caption = caption
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func shareToFacebook(indexPath: NSIndexPath) {
        let filteredImage = self.filteredImage(fromImage: feedItem.image, filter: filters[indexPath.row])
        let photos:NSArray = [filteredImage]
        var params = FBPhotoParams()
        params.photos = photos
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            if result != nil {
                println(result)
            } else {
                println(error)
            }
        }
    }
    
    // caching functions
    
    func cacheImage(imageNumber: Int) {
        let uniquePath = tmp.stringByAppendingPathComponent("\(imageNumber)")
        
        let image = filteredImage(fromImage: self.feedItem.thumbNail, filter: self.filters[imageNumber])
        UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        (UIApplication.sharedApplication().delegate as AppDelegate).cacheStatistics("Image \(imageNumber) added")
    }
    
    func getCachedImage(imageNumber: Int) -> UIImage {
        let uniquePath = tmp.stringByAppendingPathComponent("\(imageNumber)")
        var image: UIImage
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            self.cacheImage(imageNumber)
        }
        image = UIImage(contentsOfFile: uniquePath)!
        return image
    }

}
