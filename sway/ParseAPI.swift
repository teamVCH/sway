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
                let tunes = Tune.initArray(objects!)
                onCompletion(tunes: tunes, error: nil)
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
            if error == nil && tags?.count > 0 {
                // Get recordings for these tags
                let recordingsQuery = PFQuery(className:"Recordings")
                recordingsQuery.includeKey("originator")
                recordingsQuery.whereKey("tags", containsAllObjectsInArray: tags!)
                recordingsQuery.findObjectsInBackgroundWithBlock({
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) recordings.")
                        let tunes = Tune.initArray(objects!)
                        onCompletion(tunes: tunes, error: nil)
                    }
                })
            } else {
                print("Error: \(error!) \(error!.userInfo)")
                onCompletion(tunes: nil, error: error)
            }
        })
    }
    
    func getPublishedRecordings(user: PFUser?, onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let user = user ?? PFUser.currentUser()
        let recordings = user?.objectForKey("recordings") as? [PFObject]
        
        print("User has \(recordings!.count) published recordings.")
        let tunes = Tune.initArray(recordings!)
        onCompletion(tunes: tunes, error: nil)
    }
}