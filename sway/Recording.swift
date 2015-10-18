//
//  Recording.swift
//  sway
//
//  Created by Christopher McMahon on 10/18/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import Foundation
import CoreData

let recordingEntityName = "Recording"

class Recording: NSManagedObject {

    var backingAudioUrl, recordingAudioUrl: NSURL?

    
    func writeAudioFiles() -> Bool {
        var backingResult = true
        var recordingResult = true
        
        if let backingAudio = backingAudio {
            if let backingAudioUrl = backingAudioUrl {
                backingResult = writeToUrl(backingAudioUrl, data: backingAudio)
            }
        }
        
        if let recordingAudio = recordingAudio {
            if let recordingAudioUrl = recordingAudioUrl {
                recordingResult = writeToUrl(recordingAudioUrl, data: recordingAudio)
            }
        }
        
        return backingResult && recordingResult
    }
    
    func readAudioFiles() -> Bool {
        var backingResult = true
        var recordingResult = true
        
        if let backingAudioUrl = backingAudioUrl {
            if backingAudioUrl.checkResourceIsReachableAndReturnError(nil) {
                backingAudio = readFromUrl(backingAudioUrl)
                backingResult = backingAudio != nil
            }
        }
        
        if let recordingAudioUrl = recordingAudioUrl {
            if recordingAudioUrl.checkResourceIsReachableAndReturnError(nil) {
                recordingAudio = readFromUrl(recordingAudioUrl)
                recordingResult = recordingAudio != nil
            }
        }
        
        return backingResult && recordingResult
    }
    
    
    
    func writeToUrl(outputUrl: NSURL, data: NSData) -> Bool {
        return data.writeToURL(outputUrl, atomically: true)
    }
    
    func readFromUrl(url: NSURL) -> NSData? {
        do {
            return try NSData(contentsOfURL: url, options: NSDataReadingOptions.MappedRead)
        } catch let error as NSError {
            print("Error reading \(url): \(error)")
            return nil
        }
    }
    
    
    

}
