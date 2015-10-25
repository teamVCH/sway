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
    
    
    func getRecordings(recordingIds: [String], onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let query = PFQuery(className:"Recordings")
        query.includeKey("originator")
        query.includeKey("tags")
        query.whereKey("objectId", containedIn: recordingIds)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
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
    
    func getRecordingsForUser(user: PFUser, onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let query = PFQuery(className:"Recordings")
        query.includeKey("originator")
        query.includeKey("tags")
        query.whereKey("originator", equalTo: user)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
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
    
    func deleteRecording(tune: Tune, onCompletion: (error: NSError?) -> Void) {
        let query = PFQuery(className: "Recordings")
        query.getObjectInBackgroundWithId(tune.id!) { (recording: PFObject?, error: NSError?) -> Void in
            if error == nil {
                recording?.deleteInBackgroundWithBlock({ (deleted: Bool, error: NSError?) -> Void in
                    onCompletion(error: error)
                })
            }
        }
    }
    
    func publishRecording(user: PFUser?, recording: Recording, onCompletion: (tune: Tune?, error: NSError?) -> Void) {

        let user = user ?? PFUser.currentUser()
        
        if let audioUrl = recording.getAudioUrl(.Bounced) {
            if let data = recording.readFromUrl(audioUrl) {

                let tune = PFObject(className: "Recordings")
                tune.setValue(recording.title, forKey: "title")
                tune.setValue(user, forKey: "originator")
                tune.setValue("Original", forKey: "type")
                tune.setValue(PFFile(name: audioUrl.lastPathComponent, data: data), forKey: "audioData")
                
                if let waveformUrl = recording.waveformImageUrl {
                    if let waveformData = recording.readFromUrl(waveformUrl) {
                        tune.setValue(PFFile(name: waveformUrl.lastPathComponent, data: waveformData), forKey: "waveform")
                    }
                    
                }
                tune.setValue(recording.length, forKey: "length")
                tune.setValue(1, forKey: "replays")
                tune.saveInBackgroundWithBlock { (success, error ) -> Void in
                    print("Recording published: \(success)")
                    if success {
                        let query = PFQuery(className: "Recordings")
                        query.getObjectInBackgroundWithId(tune.objectId!) {
                            (tune: PFObject?, error: NSError?) -> Void in
                            if let tune = tune {
                                onCompletion(tune: Tune(object: tune), error: error)
                            } else {
                                onCompletion(tune: nil, error: error)
                            }
                        }
                    } else {
                        onCompletion(tune: nil, error: error)
                    }
                }
                
            } else {
                let error = NSError(domain: "sway", code: 123, userInfo: ["message" : "Unable to read audio data from \(audioUrl)"])
                onCompletion(tune: nil, error: error)
            }
        } else {
            let error = NSError(domain: "sway", code: 123, userInfo: ["message" : "Unable to get URL for bounced audio"])
            onCompletion(tune: nil, error: error)
            
        }

    }
    
    func fetchAndSaveTwitterUser(user: PFUser) {
        if PFTwitterUtils.isLinkedWithUser(user) {
            let screenName = PFTwitterUtils.twitter()?.screenName
            let requestString = ("https://api.twitter.com/1.1/users/show.json?screen_name=" + screenName!)
            
            let verify: NSURL = NSURL(string: requestString)!
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: verify)
            PFTwitterUtils.twitter()?.signRequest(request)
            
            let sess = NSURLSession.sharedSession()
            sess.dataTaskWithRequest(request, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = error {
                        print("error requesting twitter data")
                        return
                    }
                    else {
                        do {
                            let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            let names = result.objectForKey("name") as! String
                            PFUser.currentUser()?.setObject(names, forKey: "username")
                            
                            let screenName = result.objectForKey("screen_name") as! String
                            PFUser.currentUser()?.setObject(screenName, forKey: "screenName")
                            
                            let urlString = result.objectForKey("profile_image_url_https") as! String
                            PFUser.currentUser()?.setObject(urlString, forKey: "profileImageUrl")
                      
                            /*let hiResUrlString = urlString.stringByReplacingOccurrencesOfString("_normal", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            print("twitter: \(hiResUrlString)")*/
                            
                            let description = result.objectForKey("description") as! String
                            PFUser.currentUser()?.setObject(description, forKey: "tagLine")
                            
                            PFUser.currentUser()?.saveInBackground()

                        } catch {
                            print("exception getting twitter data")
                        }
                    }
                }
            }).resume()

        }
    }
}