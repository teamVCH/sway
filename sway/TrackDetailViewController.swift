//
//  TrackDetailViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit
import CoreData

let collaborateSegue = "collaborateSegue"

// Retreive the managedObjectContext from AppDelegate
let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

class TrackDetailViewController: UIViewController, AVAudioPlayerExtDelegate {

    @IBOutlet weak var waveformView: WaveformView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var publishedOnLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var originatorImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    
    var tune: Tune!
    
    var audioPlayer: AVAudioPlayerExt?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let tune = tune {
            titleLabel.text = tune.title!
            if let _ = tune.audioUrl {
                tune.downloadAndCacheAudio({ (cachedUrl: NSURL?, error: NSError?) -> Void in
                    do {
                        try self.audioPlayer = AVAudioPlayerExt(contentsOfURL: cachedUrl!)
                        self.audioPlayer!.delegate = self
                        self.audioPlayer!.prepareToPlay()
                    } catch let error as NSError {
                        print("Error loading audio player: \(error)")
                    }
                    self.waveformView.audioUrl = cachedUrl!
                })
                
                // TODO: use published date & format properly
                if let date = tune.lastModified {
                    publishedOnLabel.text = "Published on \(date)"
                }
                
            }
            

            likeButton.selected = tune.isLiked()
            
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let audioPlayer = audioPlayer {
            if audioPlayer.playing {
                audioPlayer.stop()
            }
        }
    }
    
    @IBAction func onTapPlayPause(sender: UIButton) {
        if let audioPlayer = audioPlayer {
            if audioPlayer.playing {
                audioPlayer.stop()
                sender.selected = false
            } else {
                audioPlayer.play()
                sender.selected = true
            }
        }
    }
    
    @IBAction func onTapLike(sender: UIButton) {
        tune.like(!sender.selected)
        sender.selected = !sender.selected
    }

    func audioPlayerUpdateTime(player: AVAudioPlayer) {
        waveformView.updateTime(audioPlayer!.currentTime)
        
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.selected = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let segueId = segue.identifier {
            if segueId == collaborateSegue {
                var recordViewController: RecordViewController!
                if let _ = segue.destinationViewController as? UINavigationController {
                    let destinationNavigationController = segue.destinationViewController as! UINavigationController
                    recordViewController = destinationNavigationController.topViewController as! RecordViewController
                } else {
                    recordViewController = segue.destinationViewController as! RecordViewController
                }
                let recording = NSEntityDescription.insertNewObjectForEntityForName(recordingEntityName, inManagedObjectContext: managedObjectContext) as! Recording
                recording.originalTuneId = tune.id!
                
                let backingAudioUrl = recording.getAudioUrl(.Backing, create: true)
                
                try! NSFileManager.defaultManager().copyItemAtURL(tune.cachedAudioUrl!, toURL: backingAudioUrl!)

                if let title = tune.title {
                    recording.title = title
                }
                
                if let tags = tune.tagNames {
                    var rTags = Set<RecordingTag>()
                    for tag in tags {
                        let rTag = NSEntityDescription.insertNewObjectForEntityForName(recordingTagEntityName, inManagedObjectContext: managedObjectContext) as! RecordingTag
                        rTag.tag = tag
                        rTag.recording = recording
                        rTags.insert(rTag)
                    }
                    
                    recording.tags = rTags
                }
                
                recordViewController.recording = recording
            }
        }
    }

}
