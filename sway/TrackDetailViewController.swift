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
let favoriteImage = UIImage(named: "favorite")
let favoriteOutlineImage = UIImage(named: "favorite_outline")

class TrackDetailViewController: UIViewController, AVAudioPlayerExtDelegate {

    @IBOutlet weak var waveformView: WaveformView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originatorImage: UIImageView!
    
    @IBOutlet weak var originatorName: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var publishedOnLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var originatorImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var collaboratorCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var replayCount: UILabel!
    @IBOutlet weak var collabButton: UIButton!
    @IBOutlet weak var collaboratorsView: UIView!
    
    
    var tune: Tune!
    
    var audioPlayer: AVAudioPlayerExt?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        originatorImage.layer.cornerRadius = 18
        originatorImage.clipsToBounds = true
        collabButton.layer.cornerRadius = 4
        collabButton.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        if let tune = tune {
            titleLabel.text = tune.title!
            
            let originator = tune.getOriginators().0
            if let url = originator.objectForKey(kProfileImageUrl) as? String {
                originatorImage.setImageURLWithFade(NSURL(string: url)!, alpha: CGFloat(1.0), completion: nil)
            } else {
                originatorImage.image = defaultUserImage
            }
            
            if let name = originator.objectForKey("username") as? String {
                self.originatorName.text = name
            }
            

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
            }
            
            if let date = tune.createDate {
                publishedOnLabel.text = "Published " + formatTimeElapsed(date) + " ago"
            }
            
            if let length = tune.length {
                lengthLabel.text = Recording.formatTime(Double(length), includeMs: false)
            } else {
                lengthLabel.text = "0:00"
            }
            
            renderCounts()
            renderCollaborators()
            tagsLabel.text = getTagsAsString(tune.tagNames)
            
            if tune.isLiked() {
                likeButton.setImage(favoriteImage, forState: .Normal)
            } else {
                likeButton.setImage(favoriteOutlineImage, forState: .Normal)
            }
        }
    }
    
    private func renderCollaborators() {
        if let collaborators = tune.getCollaborators() {
            let imageviews = collaboratorsView.subviews as! [UIImageView]
            for (index, elem) in collaborators.reverse().enumerate() {
                if (index < 5) {
                    imageviews[index].hidden = false
                    if let url = elem.objectForKey(kProfileImageUrl) as? String {
                        imageviews[index].setImageURLWithFade(NSURL(string: url)!, alpha: CGFloat(1.0), completion: nil)
                    } else {
                        imageviews[index].image = defaultUserImage
                    }
                    imageviews[index].layer.cornerRadius = 12
                    imageviews[index].clipsToBounds = true
                }
            }
        }
    }
    
    private func renderCounts() {
        if let replays = tune.replayCount {
            replayCount.text = (replays == 1) ? "\(replays) replay" : "\(replays) replays"
        }
        
        let likerCount = tune.likers != nil ? tune.likers!.count : 0
        likeCount.text = (likerCount == 1) ? "\(likerCount) like" : "\(likerCount) likes"
        collaboratorCount.text = (tune.collaboratorCount == 1) ?
            "\(tune.collaboratorCount!) collaborator" : "\(tune.collaboratorCount!) collaborators"

    }
    
    private func getTagsAsString(tags: [String]?) -> String {
        var tagString = ""
        if let tags = tags {
            for tag in tags {
                tagString += "#\(tag) "
            }
        }
        if tune != nil {
            if let collaborator = tune.getOriginators().1 {
                if let username = collaborator.objectForKey("username") as? String {
                    if tagString.characters.count > 0 {
                        tagString += "\n\n" //TODO: this is a hack
                    }
                    tagString += "\(username) contributed new audio"
                }
                
            }
        }
        
        return tagString
    }
    
    
    private func formatTimeElapsed(sinceDate: NSDate) -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle =  NSDateComponentsFormatterUnitsStyle.Full
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 1
        let interval = NSDate().timeIntervalSinceDate(sinceDate)
        return formatter.stringFromTimeInterval(interval)!
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
                if let replayCount = tune.replayCount {
                    let newCount = replayCount + 1
                    tune.replayCount = newCount
                    self.replayCount.text = (newCount == 1) ? "\(newCount) replay" : "\(newCount) replays"
                }
            }
        }
    }
    
    @IBAction func onTapLike(sender: UIButton) {
        let previouslyLiked = tune.isLiked()
        var count = tune.likers != nil ? tune.likers!.count : 0
        
        // Like or unlike
        tune.like(!previouslyLiked)
        
        // Update UI immediately
        previouslyLiked ? sender.setImage(favoriteOutlineImage, forState: .Normal) : sender.setImage(favoriteImage, forState: .Normal)
        count = previouslyLiked ? count - 1 : count + 1
        likeCount.text = (count == 1) ? "\(count) like" : "\(count) likes"
        
        // TODO: Need delegate to update like count for main view
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
                //recording.originalTuneId = tune.id!
                recording.originalTune = tune
                
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
