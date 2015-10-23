//
//  Recording.swift
//  sway
//
//  Created by Christopher McMahon on 10/18/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import Foundation
import CoreData

let documentsFolderUrl = AppDelegate.getDocumentsFolderUrl()!

let recordingEntityName = "Recording"

let defaultAudioExtension = "m4a"

enum AudioTrack {
    case Backing
    case Recording
    case Bounced
}


class Recording: NSManagedObject {
    
    var audioPaths = Set<String>()
    
    lazy var baseUrl: NSURL = {
        [unowned self] in
        /*
        let pathName = "\(self.objectID)"
        let basePathUrl = documentsFolderUrl.URLByAppendingPathComponent(pathName)
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.createDirectoryAtURL(basePathUrl, withIntermediateDirectories: true, attributes: nil)
        return basePathUrl
        */
        return documentsFolderUrl
    }()
    
    func getAudioUrl(audioTrack: AudioTrack, create: Bool = false) -> NSURL? {
        if let audioPath = getAudioPath(audioTrack) {
            return baseUrl.URLByAppendingPathComponent(audioPath)
        } else if create {
            let audioUrl = createAudioUrl(audioTrack)
            setAudioUrl(audioTrack, audioUrl: audioUrl)
            return audioUrl
        } else {
            return nil
        }
    }

    func newAudioUrl(audioTrack: AudioTrack) -> NSURL {
        let audioUrl = createAudioUrl(audioTrack)
        setAudioUrl(audioTrack, audioUrl: audioUrl)
        return audioUrl
    }
    
    
    func setAudioUrl(audioTrack: AudioTrack, audioUrl: NSURL?) {
        if let audioUrl = audioUrl {
            setAudioPath(audioTrack, audioPath: audioUrl.lastPathComponent!)
        } else {
            setAudioPath(audioTrack, audioPath: nil)
        }
    }
    
    func cleanup(unusedOnly: Bool = true) {
        if !audioPaths.isEmpty {
            var paths = Set<String>(audioPaths)
            
            if unusedOnly {
                if let recordingAudioPath = recordingAudioPath {
                    paths.remove(recordingAudioPath)
                }
                if let backingAudioPath = backingAudioPath {
                    paths.remove(backingAudioPath)
                }
                if let bouncedAudioPath = bouncedAudioPath {
                    paths.remove(bouncedAudioPath)
                }
            }
            
            let fileManager = NSFileManager.defaultManager()
            for unusedPath in paths {
                do {
                    try fileManager.removeItemAtURL(baseUrl.URLByAppendingPathComponent(unusedPath))
                    audioPaths.remove(unusedPath)
                } catch let error as NSError {
                    print("Error cleaning up unused file: \(unusedPath): \(error)")
                }
            }
            
        }
    }
    
    
    
    private func createAudioUrl(audioTrack: AudioTrack) -> NSURL {
        let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
        let uniqueFileName = "\(audioTrack)_\(uniqueId).\(defaultAudioExtension)"
        let audioUrl = documentsFolderUrl.URLByAppendingPathComponent(uniqueFileName)
        audioPaths.insert(audioUrl.lastPathComponent!)
        return audioUrl
    }
    
    private func getAudioPath(audioTrack: AudioTrack) -> String? {
        switch (audioTrack) {
            case .Backing: return backingAudioPath
            case .Recording: return recordingAudioPath
            case .Bounced: return bouncedAudioPath
        }
    }
    
    private func setAudioPath(audioTrack: AudioTrack, audioPath: String?) {
        switch (audioTrack) {
            case .Backing: backingAudioPath = audioPath
            case .Recording: recordingAudioPath = audioPath
            case .Bounced: bouncedAudioPath = audioPath
        }
    }
    
    func isDraft() -> Bool {
        return publishedDate == nil
    }

    func bounce(updateWorkingAudio: Bool, completion: (NSURL?, AVAssetExportSessionStatus?, NSError?) -> Void) {
        if let recordingAudioUrl = getAudioUrl(.Recording, create: false) {
            let fileManager = NSFileManager.defaultManager()
            let bouncedAudioUrl = newAudioUrl(.Bounced)
            do {
                if let backingAudioUrl = getAudioUrl(.Backing, create: false) {
                    print("bounce \(recordingAudioPath) -> \(backingAudioPath)")
                    AVFoundationHelper.bounce(backingAudioUrl, recordingAudioUrl: recordingAudioUrl, outputAudioUrl: bouncedAudioUrl, completion: { (status: AVAssetExportSessionStatus, error: NSError?) -> Void in
                        switch status {
                            case AVAssetExportSessionStatus.Failed: print("bounce failed \(error!)")
                            case AVAssetExportSessionStatus.Cancelled: print("bounce cancelled \(error!)")
                            default:
                                if updateWorkingAudio {
                                    self.setAudioUrl(.Backing, audioUrl: bouncedAudioUrl)
                                    self.setAudioUrl(.Recording, audioUrl: nil)
                                }
                                completion(bouncedAudioUrl, status, error)
                            }
                    })
                } else {
                    // no backing track, just make the recording the backing track
                    try fileManager.copyItemAtURL(recordingAudioUrl, toURL: bouncedAudioUrl)
                    if updateWorkingAudio {
                        setAudioUrl(.Backing, audioUrl: bouncedAudioUrl)
                        setAudioUrl(.Recording, audioUrl: nil)
                    }
                    completion(bouncedAudioUrl, nil, nil)
                }

            } catch let error as NSError {
                print("bounce i/o error = \(error)")
                completion(nil, nil, error)
            }
        } else {
            print("Nothing to bounce")
            completion(nil, nil, nil)
        }
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

    
    static func formatTime(interval: Double, includeMs: Bool) -> String {
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