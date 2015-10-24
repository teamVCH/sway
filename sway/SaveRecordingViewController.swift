//
//  SaveRecordingViewController.swift
//  sway
//
//  Created by Christopher McMahon on 10/20/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit
import CoreData

class SaveRecordingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveTypeControl: UISegmentedControl!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var addTagButton: UIButton!
    @IBOutlet weak var waveformView: SCWaveformView!
    
    var recording: Recording!
    var tags = [RecordingTag]()
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        recording.bounce(false, completion: { (bouncedAudioUrl: NSURL?, status: AVAssetExportSessionStatus?, error: NSError?) -> Void in
            if let bouncedAudioUrl = bouncedAudioUrl {
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.waveformView.asset = AVAsset(URL: bouncedAudioUrl)
                    self.setupWaveformView()

                    self.waveformView.layoutIfNeeded()
                    
                    
                })

            }
            
        })
        if let title = recording.title {
            titleField.text = title
        }
        if let tags = recording.tags {
            for tag in tags {
                self.tags.append(tag as! RecordingTag)
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let waveformImage = SaveRecordingViewController.getImageFromView(waveformView)
        SaveRecordingViewController.saveImage(waveformImage, fileName: "waveform.png")
        
    }
    
    private func setupWaveformView() {
        // Setting the waveform colors
        waveformView.normalColor = UIColor.darkGrayColor()
        waveformView.progressColor = UIColor.lightGrayColor()
        
        // Set the precision, 1 being the maximum
        waveformView.precision = 1 // 0.25 = one line per four pixels
        
        // Set the lineWidth so we have some space between the lines
        waveformView.lineWidthRatio = 1
        
        // Show only right channel
        waveformView.channelStartIndex = 0
        waveformView.channelEndIndex = 0
    }
    
    static func getImageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenShot
    }
    
    static func saveImage(image: UIImage, fileName: String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let destinationPath = (documentsPath as AnyObject).stringByAppendingPathComponent(fileName)
        print("\(destinationPath)")
        UIImagePNGRepresentation(image)!.writeToFile(destinationPath, atomically: true)
    }
    
    
    @IBAction func onTapAdd(sender: AnyObject) {
        if let tag = tagField.text {
            let recordingTag = NSEntityDescription.insertNewObjectForEntityForName(recordingTagEntityName, inManagedObjectContext: managedObjectContext) as! RecordingTag
            recordingTag.tag = tag
            
            tags.append(recordingTag)
            tableView.reloadData()
        }
    }
    
    @IBAction func onTapDone(sender: UIBarButtonItem) {
        do {
            recording.lastModified = NSDate()
            recording.title = titleField.text ?? "Untitled"
            
            
            recording.tags = Set(tags)
            
            
            
            recording.cleanup()
            
            if saveTypeControl.selectedSegmentIndex == 0 {
                recording.publishedDate = NSDate()
            } else {
                // draft
                
            }

            try managedObjectContext.save()

        } catch let error as NSError {
            print("Error saving recording: \(error)")
        }
        
        
        NSNotificationCenter.defaultCenter().postNotificationName(saveTypeControl.selectedSegmentIndex == 0 ? publishedTune: savedDraft, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tagCell, forIndexPath: indexPath) as! TagCell
        cell.tagLabel.text = tags[indexPath.row].tag!
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            tags.removeAtIndex(indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()
        }
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
