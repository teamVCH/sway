//
//  RecordingTag+CoreDataProperties.swift
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

extension RecordingTag {

    @NSManaged var tag: String?
    @NSManaged var recording: Recording?

}
