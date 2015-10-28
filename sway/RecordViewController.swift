//
//  RecordViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/17/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit
import CoreData

let saveRecordingSegue = "saveRecordingSegue"

class RecordViewController: UIViewController, RecordingControlViewDelegate, AVAudioPlayerExtDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var backingWaveformView: SCWaveformView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var recordingWaver: Waver!
    @IBOutlet weak var recordingWaveformView: SCWaveformView!
    
    var helper: AVFoundationHelper!
    
    var backingAudioPlayer, recordingAudioPlayer: AVAudioPlayerExt?
    var recorder: AVAudioRecorderExt!
    var rcView: RecordingControlView!
    var duration: NSTimeInterval? {
        didSet {
            recording.duration = duration
            
        }
    }

    var isNew = true
    var recording: Recording!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.view.backgroundColor = UIColor(hue: 0.4694, saturation: 0.04, brightness: 0.92, alpha: 1.0) /* #e2edeb */
        
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
        
        
        recordingWaver.backgroundColor = UIColor.darkGrayColor()
        /*
        if let recordingId = recordingId {
            do {
                self.recording = try managedObjectContext.existingObjectWithID(recordingId) as! Recording
            } catch let error as NSError {
                print("Error loading draft \(recordingId): \(error)")
            }
            
        } else {
            self.recording = NSEntityDescription.insertNewObjectForEntityForName(recordingEntityName, inManagedObjectContext: managedObjectContext) as! Recording
        }
        */
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let recording = recording {
            isNew = false
            updateBackingAudio()
            updateRecordingAudio()
            print("Base: \(recording.baseUrl.path!)")
            print("Bounced: \(recording.bouncedAudioPath)")
        } else {
             // if it wasn't set in the segue, make a new one
            recording = NSEntityDescription.insertNewObjectForEntityForName(recordingEntityName, inManagedObjectContext: managedObjectContext) as! Recording
            prepareToRecord()
        }
        
        // headphone detection does not work on the simulator
        if !Platform.isSimulator {
            if helper.isHeadsetConnected() {
                rcView.playBackingAudioWhileRecordingSwitch.on = true
            } else {
                let message = "For best results, we recommend connecting headphones"
                let alertView = UIAlertController(title: "Headphones Recommended", message: message, preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                presentViewController(alertView, animated: true, completion: nil)
            }
        }
        
        
        
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
    
    func prepareToRecord() -> Bool {
        do {
            
            recorder = try AVAudioRecorderExt(URL: recording.getAudioUrl(.Recording, create: true)!, settings: helper.audioRecordingSettings())
            
            guard let recorder = recorder else {
                return false
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
            
            resetPositions()
            
            return recorder.prepareToRecord()
        
        } catch let error as NSError {
            print("Error: \(error)")
            return false
        }
    }
    
    
    func startRecording(view: RecordingControlView, playBackingAudio: Bool) {
        rcView = view

            if prepareToRecord() {
                let shortStartDelay: NSTimeInterval = 0.01
                let now = recorder.deviceCurrentTime
                
                 if playBackingAudio {
                    backingAudioPlayer?.playAtTime(now + shortStartDelay)
                }
                if let duration = duration {
                    print("willRecord for duration: \(duration)")
                    let delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(duration) * Double(NSEC_PER_SEC)))
                    dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), {
                        self.recorder!.stop()
                    })
                }
                recorder.recordAtTime(now + shortStartDelay)
                
            } else {
                print("Failed to record.")
            }

        
        
    }
    
    func stopRecording(view: RecordingControlView) {
        recorder.stop()
        backingAudioPlayer?.stop()
        
        recordingWaver.hidden = true
        recordingWaveformView.hidden = false
        
        updateRecordingAudio()
        print("stopRecording")

    }
    
    func updateRecordingAudio() {
        if let recordingUrl = recording.getAudioUrl(.Recording, create: false) {
            if recordingUrl.checkResourceIsReachableAndReturnError(nil) {
                
                dispatch_async(dispatch_get_main_queue(),{
                    print("updateRecordingAudio")
                    self.recordingWaveformView.asset = AVAsset(URL: recordingUrl)
                    if let asset = self.recordingWaveformView.asset {
                        self.recordingWaveformView.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
                    }
                    if let backing = self.backingWaveformView.asset {
                        self.recordingWaveformView.timeRange = CMTimeRangeMake(kCMTimeZero, backing.duration)
                    }
                    self.recordingWaveformView.setNeedsLayout()
                    self.recordingWaveformView.layoutIfNeeded()
        
                    
                    
                })
                
                

                
                do {
                    recordingAudioPlayer = try AVAudioPlayerExt(contentsOfURL: recordingUrl)
                    recordingAudioPlayer!.delegate = self
                    recordingAudioPlayer!.prepareToPlay()
                } catch let error as NSError {
                    print("Error = \(error)")
                }
                
            }
        } else {
            dispatch_async(dispatch_get_main_queue(),{
                self.recordingWaveformView.hidden = true
                self.recordingWaver.hidden = false
                self.recordingAudioPlayer = nil
            })
        }
    }
    
    
    func startPlaying(view: RecordingControlView) {
        rcView = view
    
        resetPositions()
    
        if backingAudioPlayer != nil && recordingAudioPlayer != nil {
            let shortStartDelay: NSTimeInterval = 0.01
            let now = backingAudioPlayer?.deviceCurrentTime
            backingAudioPlayer?.playAtTime(now! + shortStartDelay)
            recordingAudioPlayer?.playAtTime(now! + shortStartDelay)
        } else {
            backingAudioPlayer?.play()
            recordingAudioPlayer?.play()
        }
        
        

    }
    
    
    func resetPositions() {
        backingAudioPlayer?.currentTime = 0
        recordingAudioPlayer?.currentTime = 0
        
        backingWaveformView.progressTime = CMTimeMakeWithSeconds(0, 10000)
        recordingWaveformView.progressTime = CMTimeMakeWithSeconds(0, 10000)
        
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
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finishRecording")
        rcView.isRecording = false
        stopRecording(rcView)
    }

    func bounce(view: RecordingControlView) {
        recording.bounce(true, completion: { (bouncedAudioUrl: NSURL?, status: AVAssetExportSessionStatus?, error: NSError?) -> Void in
            self.updateRecordingAudio()
            self.updateBackingAudio()
        })
    }
    
    
    
    func updateBackingAudio() {
        if let url = recording.getAudioUrl(.Backing, create: false) {
            do {
                backingAudioPlayer = try AVAudioPlayerExt(contentsOfURL: url)
                backingAudioPlayer!.prepareToPlay()
                backingAudioPlayer!.delegate = self
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.backingWaveformView.asset = AVAsset(URL: url)
                    //duration = backingWaveformView.asset.duration
                    self.duration = self.backingAudioPlayer!.duration
                    print("backingAudioDuration: \(self.duration!)")
                    self.backingWaveformView.timeRange = CMTimeRangeMake(kCMTimeZero, self.backingWaveformView.asset.duration)
                    self.backingWaveformView.layoutIfNeeded()
                    
                    
                })
                
            } catch let error as NSError {
                print("setBackingAudio: Error = \(error.localizedDescription)")
            }
        }
    }
    
    
    func setBackingAudio(view: RecordingControlView, url: NSURL) {
        rcView = view
        recording.setAudioUrl(.Backing, audioUrl: url)
        updateBackingAudio()

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelRecord(sender: AnyObject) {
        if isNew {
            managedObjectContext.deleteObject(recording)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let segueId = segue.identifier {
            if segueId == saveRecordingSegue {
                var saveViewController: SaveRecordingViewController!
                if let _ = segue.destinationViewController as? UINavigationController {
                    let destinationNavigationController = segue.destinationViewController as! UINavigationController
                    saveViewController = destinationNavigationController.topViewController as! SaveRecordingViewController
                } else {
                    saveViewController = segue.destinationViewController as! SaveRecordingViewController
                }
                saveViewController.recording = recording
            }
        }
    }
    
}