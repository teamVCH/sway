//
//  RecordingTag.swift
//  sway
//
//  Created by Christopher McMahon on 10/23/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import Foundation
import CoreData

let recordingTagEntityName = "RecordingTag"

let defaultPartTags = [
    "melody", "harmony", "rhythm", "beat", "lead", "ambience", "accompaniment", "effects"
]

let defaultInstrumentTags = [
    "vocals", "guitar", "keyboard", "bass", "percussion", "strings"
]

let defaultFeelTags = [
    "slow", "fast", "medium", "quiet", "loud", "upbeat", "melancholy"
]

let needsTagPrefix = "needs_"


class RecordingTag: NSManagedObject {
    
    var isNeedsTag: Bool = false

    lazy var baseTag: String? = {
        [unowned self] in
        if let tag = self.tag {
            let asRange = tag.rangeOfString(needsTagPrefix)
            if let asRange = asRange where asRange.startIndex == tag.startIndex {
                self.isNeedsTag = true
                return tag.substringFromIndex(tag.startIndex.advancedBy(needsTagPrefix.characters.count))
            } else {
                return tag
            }
        } else {
            return nil
        }
    }()
    
    

}
