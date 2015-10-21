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
    @IBOutlet weak var playBackingAudioWhileRecordingSwitch: UISwitch!
    
    var delegate: RecordingControlViewDelegate?
    
    var isRecording: Bool = false {
        didSet {
            recordButton.selected = isRecording
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            playButton.selected = isPlaying
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
            delegate?.startRecording(self, playBackingAudio: playBackingAudioWhileRecordingSwitch.on)
            isRecording = true
        }
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
    

    
    
    
    
    // just for demo purposes; this will happen automatically in collaborate mode
    @IBAction func loadBackingTrack(sender: AnyObject) {
        delegate?.setBackingAudio(self, url: defaultBackingAudio)
        
        
    }
    
}
