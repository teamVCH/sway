//
//  MainTunesViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let tuneToDetailSegue = "TuneToDetailSegue"

class MainTunesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TuneViewCellDelegate, TuneCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var searchBar: UISearchBar!

    var refreshControl:UIRefreshControl!
    var tunes:[Tune]?

    var selectedTune: Tune?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        addRefreshControl()
        
        tableView.registerNib(UINib(nibName: tuneViewCell, bundle: nil), forCellReuseIdentifier: tuneViewCell)
        tableView.registerNib(UINib(nibName: tuneCell, bundle: nil), forCellReuseIdentifier: tuneCell)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.sizeToFit()
        searchBar.delegate = self
    
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        parentViewController?.navigationItem.titleView = searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        searchBar.hidden = false
        renderTunes()
    }
    
    override func viewWillDisappear(animated: Bool) {
        searchBar.hidden = true
        
    }
    
    private func renderTunes() {
        ParseAPI.sharedInstance.getAllRecordings() { (tunes: [Tune]?, error: NSError?) -> () in
            dispatch_async(dispatch_get_main_queue(), {
                if tunes != nil {
                    self.tunes = tunes
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    }

    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    internal func refresh() {
        delay(1, closure: {
            // Parse will query cache first, render immediately,
            // then update from server if any changes
            self.renderTunes()
            self.refreshControl.endRefreshing()
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*
        let cell = tableView.dequeueReusableCellWithIdentifier(tuneViewCell, forIndexPath: indexPath) as! TuneViewCell
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.tune = tunes?[indexPath.row]
        cell.delegate = self
        */
        let cell = tableView.dequeueReusableCellWithIdentifier(tuneCell, forIndexPath: indexPath) as! TuneCell
        cell.tune = tunes?[indexPath.row]
        cell.delegate = self
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedTune = tunes![indexPath.row]
        self.performSegueWithIdentifier(tuneToDetailSegue, sender: nil)
        self.searchBar.resignFirstResponder()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tunes == nil {
            return 0
        } else {
            return tunes!.count
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let segueId = segue.identifier {
            if segueId == tuneToDetailSegue {
                var detailViewController: TrackDetailViewController!
                if let _ = segue.destinationViewController as? UINavigationController {
                    let destinationNavigationController = segue.destinationViewController as! UINavigationController
                    detailViewController = destinationNavigationController.topViewController as! TrackDetailViewController
                } else {
                    detailViewController = segue.destinationViewController as! TrackDetailViewController
                }
                detailViewController.tune = selectedTune
            } else if (segueId == "tuneToUserSegue") {
                let otherUserProfileViewController = segue.destinationViewController as! OtherUserProfileViewController
                //let senderAsTune : TuneViewCell = sender as! TuneViewCell
                let senderAsTune: TuneCell = sender as! TuneCell
                /*
                if (senderAsTune.tune.originalTune != nil) {
                    otherUserProfileViewController.user = User.init(object: senderAsTune.tune.originalTune!.originator!)
                } else {
                    otherUserProfileViewController.user = User.init(object: senderAsTune.tune.originator!)
                }
                */
                
                 otherUserProfileViewController.user = User.init(object: senderAsTune.tune.getOriginators().0)
            }
        }
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseAPI.sharedInstance.getRecordingsWithSearchTerm(searchText.lowercaseString) { (tunes, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if tunes != nil {
                    self.tunes = tunes
                    self.tableView.reloadData()
                }
            })
        }
        self.tableView.reloadData()
    }

    func profileTapped(tuneCell: TuneViewCell) {
       performSegueWithIdentifier("tuneToUserSegue", sender: tuneCell)
    }

    func onProfileTapped(tuneCell: TuneCell) {
        performSegueWithIdentifier("tuneToUserSegue", sender: tuneCell)
    }

    
}
