//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Christian Romeyke on 05/12/14.
//  Copyright (c) 2014 Christian Romeyke. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
        var error: NSError?
        let itemArray = appDelegate.managedObjectContext?.executeFetchRequest(request, error: &error)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
