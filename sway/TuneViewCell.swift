//
//  TuneViewCell.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class TuneViewCell: UITableViewCell {

    @IBOutlet weak var WaveFormView: SCWaveformView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tuneTitle: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var collabCount: UILabel!
    @IBOutlet weak var replayCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var userButton: UIButton!
    
    var playing : Bool = false
    var audioPlayer : AVAudioPlayerExt?
    
    var tune : Tune! {
        didSet{
            //set stuff
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        setTrack(WaveFormView, url: tune.trackURL)
        setupWaveformView(WaveFormView)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWaveformView(waveformView: SCWaveformView) {
        // Setting the waveform colors
        waveformView.normalColor = UIColor.whiteColor()
        waveformView.progressColor = UIColor.lightGrayColor()
        
        // Use it inside a scrollView
        //SCScrollableWaveformView *scrollableWaveformView = [SCScrollableWaveformView new];
        //scrollableWaveformView.waveformView; // Access the waveformView from there
        
        // Set the precision, 1 being the maximum
        waveformView.precision = 1 // 0.25 = one line per four pixels
        
        // Set the lineWidth so we have some space between the lines
        waveformView.lineWidthRatio = 1
        
        // Show stereo if available
        //waveformView.channelStartIndex = 0//0;
        //waveformView.channelEndIndex = 0
        
        // Show only right channel
        waveformView.channelStartIndex = 0
        waveformView.channelEndIndex = 0
        
        // Add some padding between the channels
        waveformView.channelsPadding = 10;
        
    }
    
    @IBAction func playTapped(sender: AnyObject) {
        if (playing) {
            audioPlayer?.stop()
            playing = false
            playButton.setImage(UIImage(named: "UIBarButtonPlay_2x"), forState: UIControlState.Normal)
        } else {
            playing = true
            audioPlayer?.currentTime = 0
            
            WaveFormView.progressTime = CMTimeMakeWithSeconds(0, 10000)
            playButton.setImage(UIImage(named: "UIBarButtonPause_2x"), forState: UIControlState.Normal)
            audioPlayer?.play()
        }
    }
    
    func setBackingAudio(view: SCWaveformView, url: NSURL) {
////        rcView = view
//        do {
////            backingAudioUrl = url
//            
//            audioPlayer = try AVAudioPlayerExt(contentsOfURL: url)
//            audioPlayer!.prepareToPlay()
//            audioPlayer!.delegate = self
//            
//            backingWaveformView.asset = AVAsset(URL: url)
//            duration = backingWaveformView.asset.duration
//            backingWaveformView.timeRange = CMTimeRangeMake(kCMTimeZero, duration!)
//            backingWaveformView.layoutIfNeeded()
//            
//            
//        } catch let error as NSError {
//            print("setBackingAudio: Error = \(error.localizedDescription)")
//        }
//        
//        
        
        
    }

    
}
