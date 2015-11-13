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
let userTuneDetailSegue = "userToTuneDetailSegue"

protocol UserProfileViewControllerDelegate {
    
    var detailSegue: String {get}
    
    func load(onCompletion: () -> ())
    func rowCount() -> Int
    func setComposition(cell: TuneCell, indexPath: NSIndexPath)
    func deleteComposition(indexPath: NSIndexPath)
    func prepareForSegue(destinationViewController: UIViewController, indexPath: NSIndexPath)
    
}

class DraftRecordingsUserProfileViewControllerDelegate: UserProfileViewControllerDelegate {
    
    let detailSegue = loadDraftSegue
    
    var drafts = [Recording]()
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    func load(onCompletion: () -> ()) {
        do {
            let fetchRequest = NSFetchRequest(entityName: recordingEntityName)
            let sortDescriptor = NSSortDescriptor(key: "lastModified", ascending: false)
            let sortDescriptors = [sortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let predicate1 = NSPredicate(format: "tuneId == nil")
            let predicate2 = NSPredicate(format: "userId = %@", PFUser.currentUser()!.objectId!)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
            
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Recording] {
                print("Found \(fetchResults.count) drafts")
                drafts = fetchResults
                onCompletion()
            }
        } catch let error as NSError {
            print("Error loading drafts: \(error)")
        }
    }
    
    func rowCount() -> Int {
        return drafts.count
    }
    
    func setComposition(cell: TuneCell, indexPath: NSIndexPath) {
        cell.setRecording(drafts[indexPath.row])
        //cell.userImageView.hidden = true
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
        let draft = drafts[indexPath.row]
        if let originalTuneId = draft.originalTuneId {
            ParseAPI.sharedInstance.getRecordings([originalTuneId], onCompletion: { (tunes, error) -> Void in
                if let tunes = tunes {
                    if !tunes.isEmpty {
                        draft.originalTune = tunes[0]
                    }
                }
            })
        }
        recordViewController.recording = draft
    }
    
    
}

class PublishedTunesUserProfileViewControllerDelegate: UserProfileViewControllerDelegate {
    
    let detailSegue = userTuneDetailSegue
    var published = [Tune]()
    
    func load(onCompletion: () -> ()) {
        ParseAPI.sharedInstance.getRecordingsForUser(PFUser.currentUser()!) { (tunes: [Tune]?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if tunes != nil {
                    self.published = tunes!
                    onCompletion()
                }
            })
        }
    }
    
    func rowCount() -> Int {
        return published.count
    }
    
    func addTune(tune: Tune) {
        published.append(tune)
    }
    
    func setComposition(cell: TuneCell, indexPath: NSIndexPath) {
        cell.setTune(published[indexPath.row])
        //cell.userImageView.hidden = true
        //cell.collaboratorImageView.hidden = true
        cell.accessoryType = UITableViewCellAccessoryType.None
    }
    
    func deleteComposition(indexPath: NSIndexPath) {
        ParseAPI.sharedInstance.deleteRecording(published[indexPath.row]) { (error) -> Void in
            if (error != nil) {
                print("error while deleting: \(error)")
            }
        }
        // Remove immediately
        published.removeAtIndex(indexPath.row)
    }
    
    func prepareForSegue(destinationViewController: UIViewController, indexPath: NSIndexPath) {
        if let tuneDetailViewController = destinationViewController as? TrackDetailViewController {
            tuneDetailViewController.tune = published[indexPath.row]
        }
    }
}



class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userInstrumentsLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typeControl: UISegmentedControl!

    let logoutButton = UIBarButtonItem()

    var delegates: [UserProfileViewControllerDelegate] = [
        PublishedTunesUserProfileViewControllerDelegate(),
        DraftRecordingsUserProfileViewControllerDelegate()
    ]
    
    var selectedIndex: NSIndexPath?
    var selectedType: Int = 0
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("user profile load")
        tableView.registerNib(UINib(nibName: tuneCell, bundle: nil), forCellReuseIdentifier: tuneCell)

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        user = User(object: PFUser.currentUser()!) // TODO: always current user for now
        displayNameLabel.text = user!.name
        if let screenName = user!.screenName {
            userNameLabel.text = "@\(screenName)"
        } else if let email = user!.email {
            userNameLabel.text = "\(email)"
        }
        
        userDescriptionLabel.text = user!.tagLine
        
        let profileImageUrl = PFUser.currentUser()?.objectForKey("profileImageUrl")
        if let profileImageUrl = profileImageUrl as? String {
            let imageData = NSData(contentsOfURL: NSURL(string: profileImageUrl)!)
            let userProfileImage = UIImage(data:imageData!)
            profileImageView.image = userProfileImage
            profileImageView.layer.cornerRadius = 36.5
            profileImageView.clipsToBounds = true
        }
        

        logoutButton.title = "Sign Out"
        logoutButton.action = Selector("logout")
        logoutButton.target = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        parentViewController?.navigationItem.rightBarButtonItem = logoutButton
        typeControl.selectedSegmentIndex = selectedType
        delegate().load { () -> () in
            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        parentViewController?.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func onSwitchType(sender: UISegmentedControl) {
        delegate().load { () -> () in
            self.tableView.reloadData()
        }
    }
    
    private func delegate() -> UserProfileViewControllerDelegate {
        return delegates[typeControl.selectedSegmentIndex]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate().rowCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tuneCell, forIndexPath: indexPath) as! TuneCell
        
        delegate().setComposition(cell, indexPath: indexPath)

        // hide user button from user profile page
        return cell
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            delegate().deleteComposition(indexPath)
            if typeControl.selectedSegmentIndex == 0 {
                tableView.reloadData()
            } else {
                delegate().load { () -> () in
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelect: \(indexPath)")
        selectedIndex = indexPath
        performSegueWithIdentifier(delegate().detailSegue, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func logout() {
        NSNotificationCenter.defaultCenter().postNotificationName(loggedOut, object: nil, userInfo: nil)
        
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
