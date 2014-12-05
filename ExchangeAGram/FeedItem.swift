//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Christian Romeyke on 06/12/14.
//  Copyright (c) 2014 Christian Romeyke. All rights reserved.
//

import Foundation
import CoreData

@objc (FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber

}
