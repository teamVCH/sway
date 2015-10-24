//
//  ParseAPI.swift
//  sway
//
//  Created by Vicki Chun on 10/23/15.
//  Copyright © 2015 VCH. All rights reserved.
//

class ParseAPI: NSObject {
    static let sharedInstance = ParseAPI()
    
    func getAllRecordings(onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let query = PFQuery(className:"Recordings")
        query.includeKey("originator")
        query.includeKey("tags")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) recordings.")
                var tunes = [Tune]()
                if let objects = objects {
                    for object in objects {
                        let tune = Tune(object: object)
                        tunes.append(tune)
                    }
                    onCompletion(tunes: tunes, error: nil)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                onCompletion(tunes: nil, error: error)
            }
        }
    }

    func getRecordingsWithTagNames(tagNames: [String], onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let tagQuery = PFQuery(className: "Tags")
        tagQuery.whereKey("name", containedIn:tagNames)
        tagQuery.findObjectsInBackgroundWithBlock({ (tags: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // Get recordings for these tags
                let recordingsQuery = PFQuery(className:"Recordings")
                recordingsQuery.includeKey("originator")
                recordingsQuery.whereKey("tags", containsAllObjectsInArray: tags!)
                recordingsQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) recordings.")
                        var tunes = [Tune]()
                        if let objects = objects {
                            for object in objects {
                                let tune = Tune(object: object)
                                tunes.append(tune)
                            }
                            onCompletion(tunes: tunes, error: nil)
                        }
                    }
                })
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
                onCompletion(tunes: nil, error: error)
            }
        })
    }
    
    
}