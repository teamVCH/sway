//
//  Tune.swift
//  sway
//
//  Created by Hina Sakazaki on 10/18/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class Tune: NSObject, Composition {
    let json : JSON
    
    let tuneId: String?
    let title: String?
    let replayCount: Int?
    let likeCount: Int?
    let collaboratorCount: Int?
    
    let isDraft = false // tunes are always public
    
    let length : Double? = 0 // TODO: get from json
    let audioUrl: NSURL? = nil // TODO: get from json
    let tagNames: [String]? = ["lovesong", "happy"] // TODO: get from json
    let lastModified: NSDate? = nil // TODO: get from json
    
    //let originator: User?
    //let tags: [String]?
    //let publisher: User?
    
    init(json: JSON) {
        self.json = json
        
        self.tuneId = json["objectID"].stringValue
        self.title = json["title"].stringValue
        self.replayCount = json["replays"].intValue
        self.likeCount = json["likers"].count
        self.collaboratorCount = json["collaborators"].count
    }
    
    convenience init(jsonData: AnyObject) {
        self.init(json: JSON(jsonData))
    }
    
    static func initArray(jsonDataArray: [AnyObject]) -> [Tune] {
        var tunes = [Tune]()
        for jsonData in jsonDataArray {
            tunes.append(Tune(jsonData: jsonData))
        }
        return tunes
    }

}
