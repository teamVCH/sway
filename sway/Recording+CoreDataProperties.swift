//
//  Recording+CoreDataProperties.swift
//  sway
//
//  Created by Christopher McMahon on 10/18/15.
//  Copyright © 2015 VCH. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Recording {

    @NSManaged var backingAudio: NSData?
    @NSManaged var lastModified: NSDate?
    @NSManaged var recordingAudio: NSData?
    @NSManaged var bouncedAudio: NSData?
    @NSManaged var title: String?

}
