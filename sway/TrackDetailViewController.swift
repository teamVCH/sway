//
//  TrackDetailViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class TrackDetailViewController: UIViewController, AVAudioPlayerExtDelegate {

    @IBOutlet weak var waveformView: WaveformView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var publishedOnLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var originatorImageView: UIImageView!
    
    
    var tune: Tune!
    
    var audioPlayer: AVAudioPlayerExt?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let tune = tune {
            titleLabel.text = tune.title!
            if let audioUrl = tune.audioUrl {
                
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
