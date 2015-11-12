//
//  RecordViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/17/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

let saveRecordingSegue = "saveRecordingSegue"
let darkBlueColor = UIColor(hue: 0.5917, saturation: 0.39, brightness: 0.58, alpha: 1.0) /* #597394 */

class RecordViewController: UIViewController, AVAudioPlayerExtDelegate, AVAudioRecorderDelegate {
    
    static var showHeadphonesWarning = true
    
    @IBOutlet weak var backingWaveformView: SCWaveformView!
    @IBOutlet weak var recordingWaver: Waver!
    @IBOutlet weak var recordingWaveformView: SCWaveformView!
    @IBOutlet weak var recordingToggleView: UIView!
    @IBOutlet weak var recordingCompletionView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var acceptRecordingButton: UIButton!
    @IBOutlet weak var rejectRecordingButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var headphonesButton: UIButton!
    @IBOutlet weak var playButton: PlayPauseButton!
    @IBOutlet weak var saveButton: UIButton!

    
    var helper: AVFoundationHelper!
    
    var backingAudioPlayer, recordingAudioPlayer: AVAudioPlayerExt?
    var recorder: AVAudioRecorderExt!
 
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
    
    var isHeadsetConnected: Bool = false {
        didSet {
            print("isHeadsetConnected: \(isHeadsetConnected)")
            headphonesButton.selected = isHeadsetConnected
            headphonesButton.tintColor = headphonesButton.selected ? UIColor.blueColor() : UIColor.blackColor()
        }
    }
    
    var currentTime: NSTimeInterval = 0 {
        didSet {
            currentTimeLabel.text = Recording.formatTime(currentTime, includeMs: true)
        }
    }
    
    var duration: NSTimeInterval? {
        didSet {
            recording.duration = duration
            
        }
    }
   
    var hasBackingAudio: Bool = false {
        didSet {
            updatePlayButton()
        }
    }
    
    var hasRecordingAudio: Bool = false {
        didSet {
            updatePlayButton()
        }
    }

    var isNew = true
    var recording: Recording!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.helper = AVFoundationHelper.init(completion: { (allowed) -> () in
            if allowed {
                print("Audio recording is allowed")
            } else {
                print("Audio recording is NOT allowed")
            }
        })
//        recordingWaver.backgroundColor = UIColor.darkGrayColor()

        let image = UIImage(named: "headphones")?.imageWithRenderingMode(.AlwaysTemplate)
        headphonesButton.setImage(image, forState: .Normal)
        headphonesButton.setImage(image, forState: .Selected)
        
        playButton.layer.borderWidth = 2.0
        playButton.layer.borderColor = darkBlueColor.CGColor
        playButton.layer.cornerRadius = 32
        
        backingWaveformView.normalColor = UIColor.blackColor()
        backingWaveformView.progressColor = UIColor.lightGrayColor()

        recordingWaveformView.normalColor = UIColor.whiteColor()
        recordingWaveformView.progressColor = UIColor.lightGrayColor()
        recordingWaveformView.alpha = 0.45
        
        
        
    }
    
  
    override func viewWillAppear(animated: Bool) {
        if let recording = recording {
            isNew = false
            updateBackingAudio()
            updateRecordingAudio()
            print("Base: \(recording.baseUrl.path!)")
            print("Bounced: \(recording.bouncedAudioPath)")
            
            if recording.originalTune != nil {
                title = "New Collaboration"
            } else {
                title = "Recording"
            }
            
            if hasRecordingAudio {
                enablePostRecordingFunctions(true)
            } else {
                enablePostRecordingFunctions(false)
            }
            
        } else {
             // if it wasn't set in the segue, make a new one
            recording = NSEntityDescription.insertNewObjectForEntityForName(recordingEntityName, inManagedObjectContext: managedObjectContext) as! Recording
            enablePostRecordingFunctions(false)
            prepareToRecord()
            
            title = "New Recording"
        }

        updatePlayButton()
        
        // headphone detection does not work on the simulator
        if !Platform.isSimulator {
            headphonesButton.hidden = true
            if helper.isHeadsetConnected() {
                isHeadsetConnected = true
            } else {
                isHeadsetConnected = false
                if RecordViewController.showHeadphonesWarning {
                    RecordViewController.showHeadphonesWarning = false
                    let message = "For best results, we recommend connecting headphones to prevent audio from the speakers bleeding into the microphone."
                    let alertView = UIAlertController(title: "Headphones Recommended", message: message, preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                    presentViewController(alertView, animated: true, completion: nil)
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioRouteChangeListener:", name: AVAudioSessionRouteChangeNotification, object: nil)

    }

    override func viewWillDisappear(animated: Bool) {
        if isRecording {
            stopRecording()
        }
        stopPlaying()
        NSNotificationCenter.defaultCenter().removeObserver(self)

        
    }
    
    dynamic private func audioRouteChangeListener(notification:NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
            case AVAudioSessionRouteChangeReason.NewDeviceAvailable.rawValue: isHeadsetConnected = true
            case AVAudioSessionRouteChangeReason.OldDeviceUnavailable.rawValue: isHeadsetConnected = false
            default: break
        }
    }
    
    private func enablePostRecordingFunctions(enabled: Bool) {
        //rcView.bounceButton.enabled = enabled
        let fromView = enabled ? recordingToggleView : recordingCompletionView
        let toView = enabled ? recordingCompletionView : recordingToggleView
        
        dispatch_async(dispatch_get_main_queue(),{
    
            UIView.transitionFromView(fromView, toView: toView, duration: 0.1, options: [UIViewAnimationOptions.TransitionCrossDissolve, UIViewAnimationOptions.ShowHideTransitionViews, UIViewAnimationOptions.AllowUserInteraction], completion: nil)
        })
        
        //recordingToggleView.hidden = enabled
        //recordingCompletionView.hidden = !enabled
        
        //recordingWaveformView.alpha = enabled ? 0.5 : 1.0
        
    }
    

    private func updatePlayButton() {
        playButton.enabled = hasRecordingAudio || hasBackingAudio
        saveButton.enabled = hasRecordingAudio || hasBackingAudio
    }
    
    
    @IBAction func onTapAcceptRecording(sender: UIButton) {
        stopPlaying()
        recording.bounce(true, completion: { (bouncedAudioUrl: NSURL?, status: AVAssetExportSessionStatus?, error: NSError?) -> Void in
            self.updateRecordingAudio()
            self.updateBackingAudio()
            self.enablePostRecordingFunctions(false)
        })
    }
    
    @IBAction func onTapRejectRecording(sender: UIButton) {
        stopPlaying()
        recording.newAudioUrl(.Recording)
        self.updateRecordingAudio()
        self.enablePostRecordingFunctions(false)
    
    }

    @IBAction func onTapRecord(sender: UIButton) {
        print("onTapRecord")
        if sender.selected {
            stopRecording()
            isRecording = false
        } else {
            startRecording(isHeadsetConnected)
            isRecording = true
        }
    }
    
    
    @IBAction func onTapHeadphones(sender: UIButton) {
        print("headphones: \(sender.selected)")
        isHeadsetConnected = !sender.selected
        //sender.selected = !sender.selected
        
    }
    
    
    @IBAction func onTapPlay(sender: UIButton) {
        //UIBarButtonPause_2x
        if sender.selected {
            stopPlaying()
            isPlaying = false
        } else {
            startPlaying()
            isPlaying = true
        }
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
            //recordingWaver.hidden = false
            //recordingWaveformView.hidden = true
            
            resetPositions()
            
            return recorder.prepareToRecord()
        
        } catch let error as NSError {
            print("Error: \(error)")
            return false
        }
    }
    
    
    func startRecording(playBackingAudio: Bool) {
        //rcView = view
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
    
    func stopRecording() {
        recorder.stop()
        backingAudioPlayer?.stop()
        
        //recordingWaver.hidden = true
        //recordingWaveformView.hidden = false
        //UIView.transitionFromView(recordingWaver, toView: recordingWaveformView, duration: 0.1, options: [UIViewAnimationOptions.TransitionCrossDissolve, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
        
        
        
        updateRecordingAudio()
        
        enablePostRecordingFunctions(true)
        print("stopRecording")

    }
    
    func updateRecordingAudio() {
        if let recordingUrl = recording.getAudioUrl(.Recording, create: false) {
            if recordingUrl.checkResourceIsReachableAndReturnError(nil) {
                
                //rcView.bounceButton.enabled = true
                
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
                
                hasRecordingAudio = true
            } else {
                hasRecordingAudio = false
                enablePostRecordingFunctions(false)
                clearRecording()
            }
            
        } else {
            clearRecording()
            hasRecordingAudio = false
        }
    }
    
    private func clearRecording() {

        dispatch_async(dispatch_get_main_queue(),{
            //self.recordingWaveformView.hidden = true
            //self.recordingWaver.hidden = false
            self.recordingAudioPlayer = nil
            self.enablePostRecordingFunctions(false)
        })
    }
    
    
    func startPlaying() {
        //rcView = view
    
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
 
        currentTime = 0
        
    }
    
    
    func trackRecorder() {
        currentTime = recorder.currentTime
        
    }
    
    
    func stopPlaying() {
        backingAudioPlayer?.stop()
        recordingAudioPlayer?.stop()
    }
    
    func audioPlayerUpdateTime(player: AVAudioPlayer) {
        currentTime = player.currentTime
        
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
            isPlaying = false
            resetPositions()
        }
        
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finishRecording")
        isRecording = false
        stopRecording()
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
                
                hasBackingAudio = true
                
            } catch let error as NSError {
                print("setBackingAudio: Error = \(error.localizedDescription)")
            }
        } else {
            hasBackingAudio = false
        }
    }
    
    
    func setBackingAudio(url: NSURL) {
        //rcView = view
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