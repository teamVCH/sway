//
//  OtherUserProfileViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/28/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit
import CoreData

protocol OtherUserProfileViewControllerDelegate {
    
    var detailSegue: String {get}
    
    func load(onCompletion: () -> ())
    func rowCount() -> Int
    func setComposition(cell: TuneCell, indexPath: NSIndexPath)
    func deleteComposition(indexPath: NSIndexPath)
    func prepareForSegue(destinationViewController: UIViewController, indexPath: NSIndexPath)
    
}


class OtherUserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var tuneCell: TuneCell!
    var selectedIndex: NSIndexPath?

    var tunes : [Tune] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var user : User! {
        didSet{
        }
    }
    

    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        tableView.registerNib(UINib(nibName: "TuneCell", bundle: nil), forCellReuseIdentifier: "TuneCell")

        super.viewDidLoad()
        if (user != nil) {
            self.userName.text = user.name

            if let profileImageUrl = user.profileImageURL {
                let imageData = NSData(contentsOfURL: NSURL(string: profileImageUrl)!)
                let profileImage = UIImage(data:imageData!)
                userProfileImage.image = profileImage
                userProfileImage.layer.cornerRadius = 36.5
                userProfileImage.clipsToBounds = true
            }
            
            if (user.screenName != nil){
                self.userHandle.text = "@\(user.screenName!)"
            } else {
                self.userHandle.text = ""
            }
            self.userDescription.text = user.tagLine
            
            load({ () -> () in
                //do stuff
                self.tableView.reloadData()
            })
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(onCompletion: () -> ()) {
        ParseAPI.sharedInstance.getRecordingsForUserId(user.userId!) { (tunes: [Tune]?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if tunes != nil {
                    self.tunes = tunes!
                    print(tunes)
                    onCompletion()
                }
                if (error != nil) {
                    print("Error in getting user's recordings \(error)")
                }
            })
        }
    }

    
//    private func delegate() -> UserProfileViewControllerDelegate {
//        return delegates[typeControl.selectedSegmentIndex]
//    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tunes.count > 0) {
            return tunes.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TuneCell", forIndexPath: indexPath) as! TuneCell

        cell.setTune(tunes[indexPath.row])
        //cell.userImageView.hidden = true
        //cell.collaboratorImageView.hidden = true

        cell.accessoryType = UITableViewCellAccessoryType.None

        return cell
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        performSegueWithIdentifier("tuneToDetail", sender: indexPath)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let segueId = segue.identifier {
            if segueId == "tuneToDetail" {
                if let _ = segue.destinationViewController as? UINavigationController {
                    let destinationNavigationController = segue.destinationViewController as! UINavigationController
                    if let tuneDetailViewController = destinationNavigationController.topViewController! as? TrackDetailViewController {
                        tuneDetailViewController.tune = tunes[sender!.row]
                    }
                } else {
                    if let tuneDetailViewController = segue.destinationViewController as? TrackDetailViewController {
                        tuneDetailViewController.tune = tunes[sender!.row]
                    }
                }
            }
        }

    }


}
