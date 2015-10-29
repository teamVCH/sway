//
//  Tune.swift
//  sway
//
//  Created by Hina Sakazaki on 10/18/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let tempDirectoryUrl = AppDelegate.createTempDirectory()!

class Tune: NSObject, Composition {
    
    
    let object: PFObject
    
    var id: String?
    let title: String?
    var replayCount: Int? {
        get {
            return object[kReplays] as? Int
        }
        set(replays) {
            object[kReplays] = replays
            object.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                print("replaysUpdated")
                
            }
        }
    }
    var likers: [PFUser]?
    
    
    //var likeCount: Int? = 0
    var collaborators: [PFUser]?
    var collaboratorCount: Int? = 0
    var length : Double? = 0
    let originator: PFUser?
    var tagNames: [String]? = []
    let lastModified: NSDate?
    let tuneProfileImageUrl : String?
    let waveformImageUrl: NSURL?
    let originalTune: Tune?
    
    let isDraft = false // tunes are always public
    var audioUrl: NSURL? = nil
    
    var cachedAudioUrl: NSURL?
    
    init(object: PFObject) {
        self.object = object
        id = object.objectId!
        title = object[kTitle] as? String

        lastModified = object.updatedAt
        originator = object[kOriginator] as? PFUser
        tuneProfileImageUrl = originator?.objectForKey(kProfileImageUrl) as? String
        
        let audioData = object[kAudioData] as? PFFile
        if let audioUrlString = audioData?.url {
            audioUrl = NSURL(string: audioUrlString)
        }
        
        likers = object[kLikers] as? [PFUser]

        if let collaborators = object[kCollaborators] as? [PFUser] {
            self.collaborators = collaborators
            self.collaboratorCount = collaborators.count
        }
        
        length = object[kLength] as? Double
        tagNames = object[kTags] as? [String]
        
        let waveform = object[kWaveform] as? PFFile
        if let waveformUrlString = waveform?.url {
            waveformImageUrl = NSURL(string: waveformUrlString)
        } else {
            waveformImageUrl = nil
        }
        
        if let originalTune = object[kOriginalTune] as? PFObject {
            self.originalTune = Tune(object: originalTune)
        } else {
            self.originalTune = nil
        }
    }
    
    static func initArray(objectArray: [PFObject]) -> [Tune] {
        print("creating \(objectArray.count) tunes")

        var tunes = [Tune]()
        for object in objectArray {
            tunes.append(Tune(object: object))
        }
        return tunes
    }

    func isCollaboration() -> Bool {
        return originalTune != nil
    }
    
    func like(status: Bool) {
        let user = PFUser.currentUser()!
        if likers == nil {
            likers = [PFUser]()
        }
        if status {
            if !isLiked() {
                likers!.append(user)
            }
            
        } else {
            for liker in likers! {
                if liker.objectId == user.objectId {
                    self.likers!.remove(liker)
                }
            }
        }

        object[kLikers] = likers
        object.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            print("likersUpdated")
            
        }
        
    }
    
    func isLiked() -> Bool {
        let user = PFUser.currentUser()!
        if let likers = likers {
            for liker in likers {
                if liker.objectId == user.objectId {
                    return true
                }
            }
        }
        return false
    }
    
    // get the featured / inset originator
    func getOriginators() -> (PFUser, PFUser?) {
        let owner = originator!
        if let collaborators = collaborators {
            return (collaborators[0], owner)
        } else {
            return (owner, nil)
        }
    }

    // get all the collaborators to display other than the featured originator
    func getCollaborators() -> [PFUser]? {
        if let collaborators = collaborators {
            if collaborators.count > 1 {
                var collabs = [PFUser]()
                for index in 1..<collaborators.count {
                    let collab = collaborators[index]
                    if !collabs.contains(collab) {
                        collabs.append(collab)
                    }
                }
                collabs.append(originator!)
                return collabs
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    func downloadAndCacheAudio(completion: (NSURL?, NSError?) -> Void) {
        let request = NSURLRequest(URL: audioUrl!)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            if error != nil {
                print("Fetch error: \(error)")
                completion(nil, error)
            } else if data != nil {
                self.cachedAudioUrl = self.createTempUrl(self.audioUrl!)
                data!.writeToURL(self.cachedAudioUrl!, atomically: true)
                completion(self.cachedAudioUrl, nil)
            } else {
                print("NSURLSessionDataTask returned neither data nor error")
                completion(nil, nil)
            }
        });
        
        task.resume()
    }
    
    
    private func createTempUrl(remoteUrl: NSURL) -> NSURL {
        //let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
        // TODO: needs to be unique?
        let uniqueFileName = remoteUrl.lastPathComponent
        return tempDirectoryUrl.URLByAppendingPathComponent(uniqueFileName!)
    }
    
    
}
