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
    
    var backingAudioUrl, recordingAudioUrl, bouncedAudioUrl: NSURL?
    var publishedDate: NSDate?
    
    func isDraft() -> Bool {
        return publishedDate != nil
    }
    
    func writeAudioFiles() -> Bool {
        let backingResult = writeAudioFile(backingAudio, audioUrl: backingAudioUrl)
        let recordingResult = writeAudioFile(recordingAudio, audioUrl: recordingAudioUrl)
        let bouncedResult = writeAudioFile(bouncedAudio, audioUrl: bouncedAudioUrl)
        return backingResult && recordingResult && bouncedResult
    }
    
    func writeAudioFile(audioData: NSData?, audioUrl: NSURL?) -> Bool {
        if let audioData = audioData {
            if let audioUrl = audioUrl {
                return writeToUrl(audioUrl, data: audioData)
            } else {
                print("audioData was not null but audioUrl was")
                return false
            }
        }
        return true
    }
    
    func readAudioFiles() {
        backingAudio = readAudioFile(backingAudioUrl)
        recordingAudio = readAudioFile(recordingAudioUrl)
        bouncedAudio = readAudioFile(bouncedAudioUrl)
     }
    
    func readAudioFile(audioUrl: NSURL?) -> NSData? {
        var audioData: NSData?
        if let audioUrl = audioUrl {
            if audioUrl.checkResourceIsReachableAndReturnError(nil) {
                audioData = readFromUrl(audioUrl)
            }
        }
        return audioData
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

    
    static func formatTime(interval: NSTimeInterval, includeMs: Bool) -> String {
        let ti = NSInteger(interval)
        let ms = Int((interval % 1) * 1000)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        if includeMs {
            return String(format: "%0.2d:%0.2d.%0.2d", minutes, seconds, ms)
        } else {
            return String(format: "%0.2d:%0.2d", minutes, seconds)
        }
    }
    
    
    
    
}