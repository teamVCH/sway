//
//  RecordingControlView.swift
//  AudioTest
//
//  Created by Christopher McMahon on 10/16/15.
//  Copyright © 2015 codepath. All rights reserved.
//

import UIKit

protocol RecordingControlViewDelegate {
    
    func setBackingAudio(view: RecordingControlView, url: NSURL)
    func startRecording(view: RecordingControlView, playBackingAudio: Bool)
    func stopRecording(view: RecordingControlView)
    func startPlaying(view: RecordingControlView)
    func stopPlaying(view: RecordingControlView)
    func bounce(view: RecordingControlView)
    
}

class RecordingControlView: UIView {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playBackingAudioWhileRecordingSwitch: UIButton!
    @IBOutlet weak var bounceButton: UIButton!
    
    
    var delegate: RecordingControlViewDelegate?
    
    var isRecording: Bool = false {
        didSet {
            recordButton.selected = isRecording
            playButton.enabled = !isRecording
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            playButton.selected = isPlaying
            recordButton.enabled = !isPlaying
        }
    }
    
    var currentTime: NSTimeInterval = 0 {
        didSet {
            currentTimeLabel.text = Recording.formatTime(currentTime, includeMs: true)
        }
    }
    
    
    @IBAction func onTapRecord(sender: UIButton) {
        if sender.selected {
            delegate?.stopRecording(self)
            isRecording = false
        } else {
            delegate?.startRecording(self, playBackingAudio: playBackingAudioWhileRecordingSwitch.selected)
            isRecording = true
        }
    }

    
    @IBAction func onTapHeadphones(sender: UIButton) {
        print("headphones: \(sender.selected)")
        sender.selected = !sender.selected
        sender.tintColor = sender.selected ? UIColor.blueColor() : UIColor.blackColor()
    }
    

    @IBAction func onTapPlay(sender: UIButton) {
        //UIBarButtonPause_2x
        if sender.selected {
            delegate?.stopPlaying(self)
            isPlaying = false
        } else {
            delegate?.startPlaying(self)
            isPlaying = true
        }
    }
    
    @IBAction func onTapBounce(sender: UIButton) {
        delegate?.bounce(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let image = UIImage(named: "headphones")?.imageWithRenderingMode(.AlwaysTemplate)
        playBackingAudioWhileRecordingSwitch.setImage(image, forState: .Normal)
        playBackingAudioWhileRecordingSwitch.setImage(image, forState: .Selected)

        
    }
    
    
    /*
    
    // just for demo purposes; this will happen automatically in collaborate mode
    @IBAction func loadBackingTrack(sender: AnyObject) {
        delegate?.setBackingAudio(self, url: defaultBackingAudio)
        
        
    }
    */
}
