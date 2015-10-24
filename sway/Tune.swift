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
    let lastModified: NSDate? = nil // TODO: get from json
    let originatorProfileImageUrl : String?
    
    let isDraft = false // tunes are always public
    let audioUrl: NSURL? = nil // TODO: get from json
    
    init(object: PFObject) {
        title = object["title"] as? String
        replayCount = object["replays"] as? Int
        originator = object["originator"] as? PFUser
        originatorProfileImageUrl = originator?.objectForKey("profileImageUrl") as? String
        
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
    
   /* static func initArray(jsonDataArray: [AnyObject]) -> [Tune] {
        var tunes = [Tune]()
        for jsonData in jsonDataArray {
            tunes.append(Tune(jsonData: jsonData))
        }
        return tunes
    }*/

}
