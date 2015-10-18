//
//  RecordViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/17/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController, RecordingControlViewDelegate, AVAudioPlayerExtDelegate, AVAudioRecorderDelegate {

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelRecord(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var backingWaveformView: SCWaveformView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var recordingWaver: Waver!
    @IBOutlet weak var recordingWaveformView: SCWaveformView!
    
    var helper: AVFoundationHelper!
    
    var backingAudioPlayer, recordingAudioPlayer: AVAudioPlayerExt?
    var recorder: AVAudioRecorderExt!
    var rcView: RecordingControlView!
    var duration: CMTime?
    var backingAudioUrl, recordingAudioUrl, bouncedAudioUrl: NSURL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor(hue: 0.4694, saturation: 0.04, brightness: 0.92, alpha: 1.0) /* #e2edeb */
        
        let rcView = UINib(nibName: "RecordingControlView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! RecordingControlView
        rcView.frame = controlView.bounds
        controlView.addSubview(rcView)
        
        
        self.helper = AVFoundationHelper.init(completion: { (allowed) -> () in
            if allowed {
                print("Audio recording is allowed")
            } else {
                print("Audio recording is NOT allowed")
            }
        })
        
        
        rcView.delegate = self
        
        setupWaveformView(backingWaveformView)
        setupWaveformView(recordingWaveformView)
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
    
    func startRecording(view: RecordingControlView, playBackingAudio: Bool) {
        rcView = view
        do {
            recordingAudioUrl = helper.getDocumentUrl(defaultRecordingAudioName)
            recorder = try AVAudioRecorderExt(URL: recordingAudioUrl!, settings: helper.audioRecordingSettings())
            
            guard let recorder = recorder else {
                return
            }
            
            recorder.delegate = self
            recorder.meteringEnabled = true
            /* Prepare the recorder and then start the recording */
            
            recordingWaver.waverLevelCallback = {
                (waver: Waver!) -> Void in
                if let recorder = self.recorder {
                    //print("update")
                    recorder.updateMeters()
                    let normalizedValue = CGFloat(pow (10, recorder.averagePowerForChannel(0) / 50))
                    waver.level = normalizedValue
                }
            }
            recordingWaver.hidden = false
            recordingWaveformView.hidden = true
            
            if recorder.prepareToRecord() {
                if playBackingAudio {
                    backingAudioPlayer?.play()
                }
                recorder.record()
            } else {
                print("Failed to record.")
            }
            
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        
        
    }
    
    func stopRecording(view: RecordingControlView) {
        recorder.stop()
        backingAudioPlayer?.stop()
        
        recordingWaver.hidden = true
        recordingWaveformView.hidden = false
        
        updateRecordingAudio()
    }
    
    func updateRecordingAudio() {
        
        
        if let recordingUrl = recordingAudioUrl {
            if recordingUrl.checkResourceIsReachableAndReturnError(nil) {
                recordingWaveformView.asset = AVAsset(URL: recordingUrl)
                if let duration = duration {
                    recordingWaveformView.timeRange = CMTimeRangeMake(kCMTimeZero, duration)
                }
                
                do {
                    recordingAudioPlayer = try AVAudioPlayerExt(contentsOfURL: recordingUrl)
                    recordingAudioPlayer!.delegate = self
                    recordingAudioPlayer!.prepareToPlay()
                } catch let error as NSError {
                    print("Error = \(error)")
                }
                
            }
        } else {
            recordingWaveformView.hidden = true
            recordingWaver.hidden = false
            recordingAudioPlayer = nil
            
            
            
        }
    }
    
    
    func startPlaying(view: RecordingControlView) {
        rcView = view
        
        backingAudioPlayer?.currentTime = 0
        recordingAudioPlayer?.currentTime = 0
        
        backingWaveformView.progressTime = CMTimeMakeWithSeconds(0, 10000)
        recordingWaveformView.progressTime = CMTimeMakeWithSeconds(0, 10000)
        
        backingAudioPlayer?.play()
        recordingAudioPlayer?.play()
    }
    
    
    func trackRecorder() {
        rcView.currentTime = recorder.currentTime
        
    }
    
    
    func stopPlaying(view: RecordingControlView) {
        backingAudioPlayer?.stop()
        recordingAudioPlayer?.stop()
    }
    
    func audioPlayerUpdateTime(player: AVAudioPlayer) {
        rcView.currentTime = player.currentTime
        
        if let backingAudioPlayer = backingAudioPlayer {
            if backingAudioPlayer == player {
                backingWaveformView.progressTime = CMTimeMakeWithSeconds(player.currentTime, 10000)
            }
        }
        
        if let recordingAudioPlayer = recordingAudioPlayer {
            if recordingAudioPlayer == player {
                recordingWaveformView.progressTime = CMTimeMakeWithSeconds(player.currentTime, 10000)
            }
        }
        
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        if let extPlayer = player as? AVAudioPlayerExt {
            extPlayer.invalidate()
        }
        
        var allStop = true
        if let backingAudioPlayer = backingAudioPlayer {
            if backingAudioPlayer.playing {
                allStop = false
            }
        }
        
        if let recordingAudioPlayer = recordingAudioPlayer {
            if recordingAudioPlayer.playing {
                allStop = false
            }
        }
        
        if allStop {
            rcView.isPlaying = false
        }
        
    }
    
    
    func bounce(view: RecordingControlView) {
        if let recordingAudioUrl = recordingAudioUrl {
            let fileManager = NSFileManager.defaultManager()
            
            let bouncedAudioUrl = helper.getDocumentUrl(defaultBouncedAudioName)
            
            do {
                
                if let backingAudioUrl = backingAudioUrl {
                    helper.bounce(backingAudioUrl, recordingAudioUrl: recordingAudioUrl, outputAudioUrl: bouncedAudioUrl, completion: { (status: AVAssetExportSessionStatus, error: NSError?) -> Void in
                        switch status {
                        case AVAssetExportSessionStatus.Failed: print("bounce failed \(error!)")
                        case AVAssetExportSessionStatus.Cancelled: print("bounce cancelled \(error!)")
                        default:
                            print("bounce completed")
                            self.setBackingAudio(view, url: bouncedAudioUrl)
                            
                        }
                    })
                } else {
                    // no backing track, just make the recording the backing track
                    try fileManager.copyItemAtURL(recordingAudioUrl, toURL: bouncedAudioUrl)
                    setBackingAudio(view, url: bouncedAudioUrl)
                }
                
                
                
            } catch let error as NSError {
                print("bounce i/o error = \(error)")
            }
            
            
            
            self.recordingAudioUrl = nil
            updateRecordingAudio()
        } else {
            print("Nothing to bounce")
        }
    }
    
    
    func setBackingAudio(view: RecordingControlView, url: NSURL) {
        rcView = view
        do {
            backingAudioUrl = url
            
            backingAudioPlayer = try AVAudioPlayerExt(contentsOfURL: url)
            backingAudioPlayer!.prepareToPlay()
            backingAudioPlayer!.delegate = self
            
            backingWaveformView.asset = AVAsset(URL: url)
            duration = backingWaveformView.asset.duration
            backingWaveformView.timeRange = CMTimeRangeMake(kCMTimeZero, duration!)
            backingWaveformView.layoutIfNeeded()
            
            
        } catch let error as NSError {
            print("setBackingAudio: Error = \(error.localizedDescription)")
        }
        
        
        
        
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