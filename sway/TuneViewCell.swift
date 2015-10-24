//
//  TuneViewCell.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let tuneViewCell = "TuneViewCell"

class TuneViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var waveFormView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tuneTitle: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var replayCount: UILabel!
    @IBOutlet weak var collabCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var statsView: UIView!
    
    var playing : Bool = false
    var audioItem : AVPlayerItem?
    var audioPlayer : AVPlayer?
    
    
    var tune : Tune! {
        didSet{
            setComposition(tune)
            replayCount.text = "\(tune.replayCount!)"
            likeCount.text = "\(tune.likeCount!)"
            collabCount.text = "\(tune.collaboratorCount!)"
        }
    }
    
    var recording: Recording! {
        didSet {
            setComposition(recording) // set basic values
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    
    func setComposition(composition: Composition) {
        let title = composition.title != nil ? composition.title! : "Untitled"
        if composition.lastModified != nil && composition.isDraft {
            let age = formatTimeElapsed(composition.lastModified!)
            tuneTitle.text =  "\(title) (\(age) ago)"
        } else {
            tuneTitle.text = title
        }
        statsView.hidden = composition.isDraft
        
        // remove the observer from a previous item
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if let audioUrl = composition.audioUrl {
            audioItem = AVPlayerItem(URL: audioUrl)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: audioItem!)
            audioPlayer = AVPlayer(playerItem: audioItem!)
        }
        
        if let length = composition.length {
            self.length.text = Recording.formatTime(Double(length), includeMs: false)
        } else {
            self.length.text = "0:00"
        }
        
        tags.text = getTagsAsString(composition.tagNames)

        
        // TODO: get waveform image
        //waveFormView.image = ...
        
    }
    
    func getTagsAsString(tags: [String]?) -> String {
        var tagString = ""
        if let tags = tags {
            for tag in tags {
                tagString += "#\(tag) "
            }
        }
        return tagString
    }
    
    
    // TODO: cache formatter
    func formatTimeElapsed(sinceDate: NSDate) -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle =  NSDateComponentsFormatterUnitsStyle.Abbreviated
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 1
        let interval = NSDate().timeIntervalSinceDate(sinceDate)
        return formatter.stringFromTimeInterval(interval)!
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    @IBAction func playTapped(sender: AnyObject) {
        if (playing) {
            audioPlayer?.pause()
            playing = false
            playButton.selected = false
        } else {
            playing = true
            //audioPlayer?.currentTime = 0
            //WaveFormView.progressTime = CMTimeMakeWithSeconds(0, 10000)
            playButton.selected = true
            audioPlayer?.play()
        }
    }
    
    func playerDidFinishPlaying(playerItem: AVPlayerItem) {
        playing = false
        playButton.selected = false
        audioPlayer?.seekToTime(CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
        
    }
    


    
}
