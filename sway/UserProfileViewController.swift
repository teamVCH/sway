//
//  UserProfileViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/17/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit
import CoreData

let loadDraftSegue = "loadDraftSegue"

protocol UserProfileViewControllerDelegate {
    
    var detailSegue: String {get}
    
    func load()
    func rowCount() -> Int
    func setComposition(cell: TuneViewCell, indexPath: NSIndexPath)
    func deleteComposition(indexPath: NSIndexPath)
    func prepareForSegue(destinationViewController: UIViewController, indexPath: NSIndexPath)
    
}

class DraftRecordingsUserProfileViewControllerDelegate: UserProfileViewControllerDelegate {
    
    let detailSegue = loadDraftSegue
    
    var drafts = [Recording]()

    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    func load() {
        do {
            let fetchRequest = NSFetchRequest(entityName: recordingEntityName)
            fetchRequest.predicate = NSPredicate(format: "publishedDate == nil")
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Recording] {
                print("Found \(fetchResults.count) drafts")
                drafts = fetchResults
            }
        } catch let error as NSError {
            print("Error loading drafts: \(error)")
        }
    }
    
    func rowCount() -> Int {
        return drafts.count
    }
    
    func setComposition(cell: TuneViewCell, indexPath: NSIndexPath) {
        cell.recording = drafts[indexPath.row]
        cell.userButton.hidden = true
        cell.accessoryType = UITableViewCellAccessoryType.None
        
    }
    
    func deleteComposition(indexPath: NSIndexPath) {
        let draft = drafts[indexPath.row]
        draft.cleanup(false)
        managedObjectContext.deleteObject(draft)
        try! managedObjectContext.save()
        
    }

    func prepareForSegue(destinationViewController: UIViewController, indexPath: NSIndexPath) {
        let recordViewController = destinationViewController as! RecordViewController
        recordViewController.recording = drafts[indexPath.row]
    }
    
    
}

class PublishedTunesUserProfileViewControllerDelegate: UserProfileViewControllerDelegate {
    
    let detailSegue = "showTuneDetail" // TODO
    
    func load() {
        // TODO
    }
    
    func rowCount() -> Int {
        return 0 // TODO
    }
    
    func setComposition(cell: TuneViewCell, indexPath: NSIndexPath) {
        // TODO
    }
    
    func deleteComposition(indexPath: NSIndexPath) {
        // TODO
    }
    
    func prepareForSegue(destinationViewController: UIViewController, indexPath: NSIndexPath) {
        // TODO
    }
    
    
}



class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userInstrumentsLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typeControl: UISegmentedControl!
    
    var delegates: [UserProfileViewControllerDelegate] = [
        PublishedTunesUserProfileViewControllerDelegate(),
        DraftRecordingsUserProfileViewControllerDelegate()
    ]
    
    var selectedIndex: NSIndexPath?
    var selectedType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: tuneViewCell, bundle: nil), forCellReuseIdentifier: tuneViewCell)

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        // TODO: set from user object
        displayNameLabel.text = "Display Name"
        userNameLabel.text = "@username"
        userInstrumentsLabel.text = "Instrument1, Instrument2, Instrument3"
        userDescriptionLabel.text = "A short message or description of the user"
    }
    
    override func viewWillAppear(animated: Bool) {
        typeControl.selectedSegmentIndex = selectedType
        delegate().load()
        tableView.reloadData()
    }
    
    @IBAction func onSwitchType(sender: UISegmentedControl) {
        delegate().load()
        tableView.reloadData()
    }
    
    private func delegate() -> UserProfileViewControllerDelegate {
        return delegates[typeControl.selectedSegmentIndex]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate().rowCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tuneViewCell, forIndexPath: indexPath) as! TuneViewCell
        
        delegate().setComposition(cell, indexPath: indexPath)

        // hide user button from user profile page
        return cell
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            delegate().deleteComposition(indexPath)
            delegate().load()
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        performSegueWithIdentifier(delegate().detailSegue, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let segueId = segue.identifier {
            if segueId == delegate().detailSegue {
                if let _ = segue.destinationViewController as? UINavigationController {
                    let destinationNavigationController = segue.destinationViewController as! UINavigationController
                    delegate().prepareForSegue(destinationNavigationController.topViewController!, indexPath: selectedIndex!)
                } else {
                    delegate().prepareForSegue(segue.destinationViewController, indexPath: selectedIndex!)
                }
            }
        }
    }
    

}
