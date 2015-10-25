//
//  SaveRecordingViewController.swift
//  sway
//
//  Created by Christopher McMahon on 10/20/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit
import CoreData

class SaveRecordingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let kHorizontalInsets: CGFloat = 3.0
    let kVerticalInsets: CGFloat = 5.0
    
    @IBOutlet weak var saveTypeControl: UISegmentedControl!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var waveformView: SCWaveformView!
    @IBOutlet weak var tagsTextView: UITextView!
    @IBOutlet weak var tagsTypeControl: UISegmentedControl!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    var recording: Recording!
    var tags : [[String:RecordingTag]] = [[:], [:]]
    
    var defaultTags = [String]()
    var token: dispatch_once_t = 0
    var sizingCell: TagCell?
    
    let xib = UINib(nibName: tagCell, bundle: nil)
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultTags.appendContentsOf(defaultPartTags)
        defaultTags.appendContentsOf(defaultInstrumentTags)
        defaultTags.appendContentsOf(defaultFeelTags)
        
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.registerNib(xib, forCellWithReuseIdentifier: tagCell)
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
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
                let rTag = tag as! RecordingTag
                let baseTag = rTag.baseTag!
                print("baseTag: \(baseTag)")
                let index = rTag.isNeedsTag ? 1 : 0
                self.tags[index][baseTag] = rTag
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let waveformImage = SaveRecordingViewController.getImageFromView(waveformView)
        let waveformUrl = recording.getAudioUrl(.Waveform, create: true)
        SaveRecordingViewController.saveImage(waveformImage, fileUrl: waveformUrl!)
    }
    
    private func currentTags() -> [String:RecordingTag] {
        return tags[tagsTypeControl.selectedSegmentIndex]
        
    }
    
    private func removeTag(tag: String) {
        let rTag: RecordingTag = tags[tagsTypeControl.selectedSegmentIndex][tag]!
        managedObjectContext.delete(rTag)
        tags[tagsTypeControl.selectedSegmentIndex].removeValueForKey(tag)
    }
    
    private func addTag(tag: String) {
        let rTag = NSEntityDescription.insertNewObjectForEntityForName(recordingTagEntityName, inManagedObjectContext: managedObjectContext) as! RecordingTag
        if tagsTypeControl.selectedSegmentIndex == 1 {
            rTag.tag = "\(needsTagPrefix)_\(tag)"
        } else {
            rTag.tag = tag
        }
        
        tags[tagsTypeControl.selectedSegmentIndex][tag] = rTag
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
    
    static func saveImage(image: UIImage, fileUrl: NSURL) {
        UIImagePNGRepresentation(image)!.writeToURL(fileUrl, atomically: true)
    }

    
    @IBAction func onTapDone(sender: UIBarButtonItem) {
        do {
            var tagSet = Set<RecordingTag>()
            for index in 0...1 {
                for rTag in tags[index].values {
                    tagSet.insert(rTag)
                }
            }
            
            recording.lastModified = NSDate()
            if let title = titleField.text {
                recording.title = title
            } else {
                recording.title = "Untitled"
            }
            
            recording.tags = tagSet
            recording.cleanup()
            
            if saveTypeControl.selectedSegmentIndex == 0 {
                recording.publishedDate = NSDate()
                ParseAPI.sharedInstance.publishRecording(nil, recording: recording, onCompletion: { (tune, error) -> Void in
                    print("completion")
                    
                })
                
                
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

    @IBAction func onChangeTagType(sender: UISegmentedControl) {
        tagsCollectionView.reloadData()
    }
    // MARK: - UICollectionViewDataSource
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaultTags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(tagCell, forIndexPath: indexPath) as! TagCell
        let tag = defaultTags[indexPath.item]
        cell.configCell(tag, selected: currentTags().keys.contains(tag))
        return cell
    }
    
    // MARK: - UICollectionViewFlowLayout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        dispatch_once(&token) {
            self.sizingCell = self.xib.instantiateWithOwner(nil, options: nil)[0] as? TagCell
        }
        
        sizingCell!.configCell(defaultTags[indexPath.item], selected: false)
        sizingCell!.setNeedsLayout()
        sizingCell!.layoutIfNeeded()
        var size: CGSize = sizingCell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        size.height = size.height + 1.0
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(kVerticalInsets, kHorizontalInsets, kVerticalInsets, kHorizontalInsets)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kHorizontalInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kVerticalInsets
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tag = defaultTags[indexPath.item]
        addTag(tag)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCell
        cell.backgroundColor = tagCellSelectedColor
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let tag = defaultTags[indexPath.item]
        removeTag(tag)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCell
        cell.backgroundColor = tagCellDeselectedColor
        
        
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
