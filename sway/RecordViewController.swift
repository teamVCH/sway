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
    var duration: NSTimeInterval?

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
            // create temp files
            if recording.backingAudio != nil {
                recording.backingAudioUrl = helper.getDocumentUrl(defaultBackingAudioName)
            }
            if recording.recordingAudio != nil {
                recording.recordingAudioUrl = helper.getDocumentUrl(defaultRecordingAudioName)
            }
            if recording.bouncedAudio != nil {
                recording.bouncedAudioUrl = helper.getDocumentUrl(defaultBouncedAudioName)
            }
            
            // write any stored audio data to the filesystem
            recording.writeAudioFiles()
            updateBackingAudio()
            updateRecordingAudio()
            
        } else {
             // if it wasn't set in the segue, make a new one
            recording = NSEntityDescription.insertNewObjectForEntityForName(recordingEntityName, inManagedObjectContext: managedObjectContext) as! Recording
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
    
    func startRecording(view: RecordingControlView, playBackingAudio: Bool) {
        rcView = view
        do {
            recording.recordingAudioUrl = helper.getDocumentUrl(defaultRecordingAudioName)
            recorder = try AVAudioRecorderExt(URL: recording.recordingAudioUrl!, settings: helper.audioRecordingSettings())
            
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
            
            resetPositions()
            
            if recorder.prepareToRecord() {
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
        print("stopRecording")

    }
    
    func updateRecordingAudio() {
        
        
        if let recordingUrl = recording.recordingAudioUrl {
            if recordingUrl.checkResourceIsReachableAndReturnError(nil) {
                recordingWaveformView.asset = AVAsset(URL: recordingUrl)
                if let asset = backingWaveformView.asset {
                    recordingWaveformView.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
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
        
        resetPositions()
        
        let shortStartDelay: NSTimeInterval = 0.01
        if let recorder = recorder {
            let now = recorder.deviceCurrentTime
        
            backingAudioPlayer?.playAtTime(now + shortStartDelay)
            recordingAudioPlayer?.playAtTime(now + shortStartDelay)
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
        if let recordingAudioUrl = recording.recordingAudioUrl {
            let fileManager = NSFileManager.defaultManager()
            
            let bouncedAudioUrl = helper.getDocumentUrl(defaultBouncedAudioName)
            
            do {
                
                if let backingAudioUrl = recording.backingAudioUrl {
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
            
            
            
            recording.recordingAudioUrl = nil
            updateRecordingAudio()
        } else {
            print("Nothing to bounce")
        }
    }
    
    func updateBackingAudio() {
        if let url = recording.backingAudioUrl {
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
        recording.backingAudioUrl = url
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
    
    @IBAction func doneRecording(sender: UIButton) {
        do {
            recording.lastModified = NSDate()
            recording.readAudioFiles()
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Error saving recording: \(error)")
        }
//        self.dismissViewControllerAnimated(true, completion: nil)
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