//
//  MainTunesViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let tuneToDetailSegue = "TuneToDetailSegue"

class MainTunesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl:UIRefreshControl!
    var tunes:[Tune]?

    var selectedTune: Tune?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        refresh()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        tableView.registerNib(UINib(nibName: tuneViewCell, bundle: nil), forCellReuseIdentifier: tuneViewCell)

        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        
        renderTunes()
        
    }
    
    
    internal func renderTunes() {
        RestManager.sharedInstance.getAllRecordings() { (tunes: [Tune]?, error: NSError?) -> () in
            dispatch_async(dispatch_get_main_queue(), {
                if tunes != nil {
                    self.tunes = tunes
                    self.tableView.reloadData()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
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
    

}
