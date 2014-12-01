//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Christian Romeyke on 27/11/14.
//  Copyright (c) 2014 Christian Romeyke. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    var feedArray: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let request = NSFetchRequest(entityName: "FeedItem")
        feedArray = managedObjectContext!.executeFetchRequest(request, error: nil)!
    }
    
    override func viewWillAppear(animated: Bool) {
        let request = NSFetchRequest(entityName: "FeedItem")
        feedArray = managedObjectContext!.executeFetchRequest(request, error: nil)!
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage]
        imagePickerController.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            var alertController = UIAlertController(title: "WTF?!", message: "What kind of shitty device is this?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }

    @IBAction func profileButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("profileSegue", sender: self)
    }
    
    // UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("feedCell", forIndexPath: indexPath) as FeedCell
        if indexPath.section == 0 {
            let feedItem = feedArray[indexPath.item] as FeedItem
            cell.imageView.image = UIImage(data: feedItem.image)
            cell.captionLabel.text = feedItem.caption
        }
        return cell
    }
    
    // UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let feedItem = feedArray[indexPath.item] as FeedItem
        let filterVc = FilterViewController()
        filterVc.feedItem = feedItem
        self.navigationController?.pushViewController(filterVc, animated: false)
        
    }
    
    // UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)

        feedItem.image = imageData
        feedItem.thumbNail = thumbNailData
        feedItem.caption = "my caption"
        
        appDelegate.saveContext()
        feedArray.append(feedItem)
    
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView.reloadData()
    }

}
