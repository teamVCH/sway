//
//  WaveformPlayerView.swift
//  sway
//
//  Created by Christopher McMahon on 10/25/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class WaveformView: SCWaveformView {
    
    var audioUrl: NSURL? {
        didSet {
            dispatch_async(dispatch_get_main_queue(),{
                if let audioUrl = self.audioUrl {
                    self.asset = AVAsset(URL: audioUrl)
                    self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration)
                } else {
                    self.asset = nil
                }
                self.setNeedsLayout()
                self.layoutIfNeeded()
            })
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Set the precision, 1 being the maximum
        precision = 1 // 0.25 = one line per four pixels
        
        // Set the lineWidth so we have some space between the lines
        lineWidthRatio = 1
        
        // Show stereo if available
        //waveformView.channelStartIndex = 0//0;
        //waveformView.channelEndIndex = 0
        
        // Show only right channel
        channelStartIndex = 0
        channelEndIndex = 0
        
    }
    
    func updateTime(currentTime: NSTimeInterval) {
        progressTime = CMTimeMakeWithSeconds(currentTime, 10000)
    }
    

}
