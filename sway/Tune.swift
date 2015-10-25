//
//  Tune.swift
//  sway
//
//  Created by Hina Sakazaki on 10/18/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class Tune: NSObject, Composition {
    
    var id: String?
    let title: String?
    var replayCount: Int? = 0
    var likeCount: Int? = 0
    var collaboratorCount: Int? = 0
    var length : Double? = 0
    let originator: PFUser?
    var tagNames: [String]? = []
    let lastModified: NSDate?
    let tuneProfileImageUrl : String?
    let waveformImageUrl: NSURL?
    
    let isDraft = false // tunes are always public
    var audioUrl: NSURL? = nil
    
    init(object: PFObject) {
        id = object.objectId! as? String
        title = object["title"] as? String
        replayCount = object["replays"] as? Int
        lastModified = object["updatedAt"] as? NSDate
        originator = object["originator"] as? PFUser
        
        let originatorUser = User(object: originator!)
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
        tagNames = object["tags"] as? [String]
        
        let waveform = object["waveform"] as? PFFile
        if let waveformUrlString = waveform?.url {
            waveformImageUrl = NSURL(string: waveformUrlString)
        } else {
            waveformImageUrl = nil
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
