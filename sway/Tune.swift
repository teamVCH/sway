//
//  Tune.swift
//  sway
//
//  Created by Hina Sakazaki on 10/18/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class Tune: NSObject, Composition {
    
    let title: String?
    var replayCount: Int? = 0
    var likeCount: Int? = 0
    var collaboratorCount: Int? = 0
    var length : Double? = 0
    let originator: PFUser?
    let tagNames: [String]? = []
    let lastModified: NSDate?
    let tuneProfileImageUrl : String?
    
    let isDraft = false // tunes are always public
    var audioUrl: NSURL? = nil
    
    init(object: PFObject) {
        title = object["title"] as? String
        replayCount = object["replays"] as? Int
        lastModified = object["updatedAt"] as? NSDate
        originator = object["originator"] as? PFUser
        tuneProfileImageUrl = originator?.objectForKey("profileImageUrl") as? String
        let audioData = object["audioData"] as? PFFile
        if let audioUrlString = audioData?.url {
            audioUrl = NSURL(string: audioUrlString)
        }
        
        if let likers = object["likers"] {
            likeCount = likers.count
        }
        
        if let collaborators = object["collaborators"] {
            collaboratorCount = collaborators.count
        }
        
        length = object["length"] as? Double
        if let tags = object["tags"] as? [PFObject] {
            for tag in tags {
                let tagName = tag.objectForKey("name") as! String
                tagNames?.append(tagName)
            }
        }
        
    }
    
    static func initArray(objectArray: [PFObject]) -> [Tune] {
        var tunes = [Tune]()
        for object in objectArray {
            tunes.append(Tune(object: object))
        }
        return tunes
    }

}
