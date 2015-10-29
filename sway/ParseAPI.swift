//
//  ParseAPI.swift
//  sway
//
//  Created by Vicki Chun on 10/23/15.
//  Copyright © 2015 VCH. All rights reserved.
//

let kRecordings = "Recordings"
let kOriginator = "originator"
let kOriginalTune = "originalTune"
let kLikers = "likers"
let kCreatedAt = "createdAt"
let kTags = "tags"
let kTitle = "title"
let kType = "type"
let kLength = "length"
let kAudioData = "audioData"
let kReplays = "replays"
let kWaveform = "waveform"
let kProfileImageUrl = "profileImageUrl"
let kCollaborators = "collaborators"

class ParseAPI: NSObject {
    
    static let sharedInstance = ParseAPI()
   
    private func newRecordingsQuery(useCache: Bool = true) -> PFQuery {
        let query = PFQuery(className: kRecordings)
        query.includeKey(kOriginator)
        query.includeKey(kOriginalTune)
        query.includeKey("\(kOriginalTune).\(kOriginator)")
        query.includeKey(kLikers)
        query.includeKey(kCollaborators)
        query.orderByDescending(kCreatedAt)
        if useCache {
            query.cachePolicy = .CacheThenNetwork
        }
        return query
    }
    
    func getAllRecordings(onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let query = newRecordingsQuery()
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) recordings.")
                let tunes = Tune.initArray(objects!)
                onCompletion(tunes: tunes, error: nil)
            } else {
                // Error could occur on first pass if no cached data
                print("Error: \(error!) \(error!.userInfo)")
                return
            }
        }
    }
    
    func getRecordingsWithSearchTerm(searchTerm: String?, onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let query = newRecordingsQuery()
        if let searchTerm = searchTerm {
            let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
            if searchTerm.stringByTrimmingCharactersInSet(whitespaceSet) != "" {
                let searchArray: [String] = searchTerm.componentsSeparatedByString(" ")
                query.whereKey(kTags, containedIn: searchArray)
            }
        }
        query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) recordings.")
                let tunes = Tune.initArray(objects!)
                onCompletion(tunes: tunes, error: nil)
            } else {
                print("Error: \(error!) \(error!.userInfo)")
                onCompletion(tunes: nil, error: error)
            }
        })
    }
    
    
    func getRecordingsForUser(user: PFUser, onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let query = newRecordingsQuery()
        query.whereKey(kOriginator, equalTo: user)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) recordings.")
                let tunes = Tune.initArray(objects!)
                onCompletion(tunes: tunes, error: nil)
            } else {
                // Error could occur on first pass when non cached data
                print("Error: \(error!) \(error!.userInfo)")
                return
            }
        }
    }
    
    func getRecordingsForUserId(userId : String, onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let query = newRecordingsQuery()
        query.whereKey(kOriginator, equalTo: userId)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) recordings.")
                let tunes = Tune.initArray(objects!)
                onCompletion(tunes: tunes, error: nil)
            } else {
                // Error could occur on first pass when non cached data
                print("Error: \(error!) \(error!.userInfo)")
                return
            }
        }
    }
    
    func getRecordings(recordingIds: [String], onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let query = newRecordingsQuery()
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
    
    func deleteRecording(tune: Tune, onCompletion: (error: NSError?) -> Void) {
        let query = PFQuery(className: kRecordings)
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

                let tune = PFObject(className: kRecordings)
                tune.setValue(recording.title, forKey: kTitle)
                tune.setValue(user, forKey: kOriginator)
                
                tune.setValue(PFFile(name: audioUrl.lastPathComponent, data: data), forKey: kAudioData)
                
                if let waveformUrl = recording.waveformImageUrl {
                    if let waveformData = recording.readFromUrl(waveformUrl) {
                        tune.setValue(PFFile(name: waveformUrl.lastPathComponent, data: waveformData), forKey: kWaveform)
                    }
                }
                
                if let tags = recording.tags {
                    var tagNames = [String]()
                    for tag in tags {
                        let rTag = tag as! RecordingTag
                        tagNames.append(rTag.tag!)
                    }
                    tune.setValue(tagNames, forKey: kTags)
                }
                
                
                tune.setValue(recording.originalTuneId != nil ? "Collaboration" : "Original", forKey: kType)
                
                if let originalTune = recording.originalTune {
                    var collaborators = [PFUser]()
                    if let previousCollaborators = originalTune.collaborators {
                        collaborators.appendContentsOf(previousCollaborators)
                    }
                    collaborators.append(originalTune.originator!)
                    tune.setValue(originalTune.object, forKey: kOriginalTune)
                    tune.setValue(collaborators, forKey: kCollaborators)
                }
                
                if let length = recording.length {
                    tune.setValue(length, forKey: kLength)
                }
                
                tune.setValue(1, forKey: kReplays)
                
                tune.saveInBackgroundWithBlock { (success, error ) -> Void in
                    print("Recording published: \(success)")
                    if success {
                        let query = PFQuery(className: kRecordings)
                        query.includeKey(kOriginator)
                        query.getObjectInBackgroundWithId(tune.objectId!) {
                            (tune: PFObject?, error: NSError?) -> Void in
                            if let tune = tune {
                                onCompletion(tune: Tune(object: tune), error: nil)
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
                            let hiResUrlString = urlString.stringByReplacingOccurrencesOfString("_normal", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            PFUser.currentUser()?.setObject(hiResUrlString, forKey: "profileImageUrl")
                            
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
