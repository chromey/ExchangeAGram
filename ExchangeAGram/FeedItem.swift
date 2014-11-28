//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Christian Romeyke on 29/11/14.
//  Copyright (c) 2014 Christian Romeyke. All rights reserved.
//

import Foundation
import CoreData

@objc (FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
