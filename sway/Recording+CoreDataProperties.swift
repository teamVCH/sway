//
//  Recording+CoreDataProperties.swift
//  sway
//
//  Created by Christopher McMahon on 10/23/15.
//  Copyright © 2015 VCH. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Recording {

    @NSManaged var backingAudioPath: String?
    @NSManaged var bouncedAudioPath: String?
    @NSManaged var lastModified: NSDate?
    @NSManaged var recordingAudioPath: String?
    @NSManaged var title: String?
    @NSManaged var publishedDate: NSDate?
    @NSManaged var duration: NSNumber?
    @NSManaged var tags: NSSet?

}
