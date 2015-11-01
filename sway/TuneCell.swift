//
//  TuneCell.swift
//  sway
//
//  Created by Christopher McMahon on 11/1/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let tuneCell = "TuneCell"

@objc protocol TuneCellDelegate {
    optional func onProfileTapped(tuneCell: TuneCell)
}

class TuneCell: UITableViewCell {
    
    @IBOutlet weak var waveFormView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tuneTitle: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var replayCount: UILabel!
    @IBOutlet weak var collabCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var collaboratorImageView: UIImageView!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!
    
    var playing : Bool = false
    var audioItem : AVPlayerItem?
    var audioPlayer : AVPlayer?
    
    weak var delegate : TuneCellDelegate?
    
    var tune : Tune! {
        didSet{
            setComposition(tune)
            if let replays = tune.replayCount {
                replayCount.text = "\(replays)"
            }
            let likerCount = tune.likers != nil ? tune.likers!.count : 0
            
            likeCount.text = "\(likerCount)"
            collabCount.text = "\(tune.collaboratorCount!)"
            
            let originators = tune.getOriginators()
            if let url = originators.0.objectForKey(kProfileImageUrl) as? String {
                userImageView.setImageURLWithFade(NSURL(string: url)!, alpha: CGFloat(1.0), completion: nil)
            } else {
                userImageView.image = defaultUserImage
            }
            
            usernameLabel.text = originators.0.objectForKey("username") as? String
            
            if let insetOriginator = originators.1 {
                if insetOriginator.objectId! != originators.0.objectId! {
                    collaboratorImageView.hidden = false
                    if let url = insetOriginator.objectForKey(kProfileImageUrl) as? String {
                        collaboratorImageView.setImageURLWithFade(NSURL(string: url)!, alpha: CGFloat(1.0), completion: nil)
                    } else {
                        collaboratorImageView.image = defaultUserImage
                    }
                } else {
                    collaboratorImageView.hidden = true
                }
                
            } else {
                collaboratorImageView.hidden = true
            }
            
            publishedAtLabel.text = formatTimeElapsed(tune.createDate!,style: .Full) + " ago"
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
            let age = formatTimeElapsed(composition.lastModified!, style: .Abbreviated)
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
        
        
        if let waveformImageUrl = composition.waveformImageUrl {
            waveFormView.setImageURLWithFade(waveformImageUrl, alpha: 0.25, completion: nil)
        }
        
    }
    
    func getTagsAsString(tags: [String]?) -> String {
        var tagString = ""
        if let tags = tags {
            for tag in tags {
                tagString += "#\(tag) "
            }
        }
        /*
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
        */
        return tagString
    }
    
    
    func formatTimeElapsed(sinceDate: NSDate, style: NSDateComponentsFormatterUnitsStyle) -> String {
        formatter.unitsStyle = style
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 1
        let interval = NSDate().timeIntervalSinceDate(sinceDate)
        return formatter.stringFromTimeInterval(interval)!
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero

        selectionStyle = UITableViewCellSelectionStyle.None
        
        let profileImageTapRecognizer = UITapGestureRecognizer(target:self, action:Selector("profileTapped:"))
        userImageView.userInteractionEnabled = true
        userImageView.addGestureRecognizer(profileImageTapRecognizer)
    }
    

    func profileTapped (sender: AnyObject){
        delegate?.onProfileTapped!(self)
    }
    
    @IBAction func playTapped(sender: AnyObject) {
        if (playing) {
            audioPlayer?.pause()
            playing = false
            playButton.selected = false
        } else {
            playing = true
            
            playButton.selected = true
            audioPlayer?.play()
            if let tune = tune {
                if let replayCount = tune.replayCount {
                    let newCount = replayCount + 1
                    tune.replayCount = newCount
                    self.replayCount.text = "\(newCount)"
                }
            }
        }
    }
    
    func playerDidFinishPlaying(playerItem: AVPlayerItem) {
        playing = false
        playButton.selected = false
        audioPlayer?.seekToTime(CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
        
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    
}