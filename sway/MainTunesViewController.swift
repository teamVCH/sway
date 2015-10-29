//
//  MainTunesViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let tuneToDetailSegue = "TuneToDetailSegue"

class MainTunesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var refreshControl:UIRefreshControl!
    var tunes:[Tune]?

    var selectedTune: Tune?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        addRefreshControl()
        renderTunes()
        
        tableView.registerNib(UINib(nibName: tuneViewCell, bundle: nil), forCellReuseIdentifier: tuneViewCell)

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        searchBar.delegate = self
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
        let cell = tableView.dequeueReusableCellWithIdentifier(tuneViewCell, forIndexPath: indexPath) as! TuneViewCell
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.tune = tunes?[indexPath.row]
        //let tapGesture = UITapGestureRecognizer(target:self, action: Selector("handleTap"))
        //cell.addGestureRecognizer(tapGesture)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedTune = tunes![indexPath.row]
        self.performSegueWithIdentifier(tuneToDetailSegue, sender: nil)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tunes == nil {
            return 0
        } else {
            return tunes!.count
        }
    }

    func handleTap(){
        //self.performSegueWithIdentifier(tuneToDetailSegue, sender: nil)
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
        ParseAPI.sharedInstance.getRecordingsWithSearchTerm(searchText) { (tunes, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if tunes != nil {
                    self.tunes = tunes
                    self.tableView.reloadData()
                }
            })
        }
        self.tableView.reloadData()
    }


}
