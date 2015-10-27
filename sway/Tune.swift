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
    let originalTune: Tune? = nil
    
    let isDraft = false // tunes are always public
    var audioUrl: NSURL? = nil
    
    var cachedAudioUrl: NSURL?
    
    init(object: PFObject) {
        id = object.objectId!
        title = object["title"] as? String
        replayCount = object["replays"] as? Int
        lastModified = object.updatedAt
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
        tagNames = object["tags"] as? [String]
        
        let waveform = object["waveform"] as? PFFile
        if let waveformUrlString = waveform?.url {
            waveformImageUrl = NSURL(string: waveformUrlString)
        } else {
            waveformImageUrl = nil
        }
        
        //originalTuneId = object["originalTuneId"] as? String
        print(object)
    }
    
    static func initArray(objectArray: [PFObject]) -> [Tune] {
        var tunes = [Tune]()
        for object in objectArray {
            tunes.append(Tune(object: object))
        }
        return tunes
    }

    func isCollaboration() -> Bool {
        return originalTune != nil
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
