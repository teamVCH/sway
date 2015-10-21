//
//  MainTunesViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class MainTunesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl:UIRefreshControl!
    var tunes:[Tune]!

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
    RestManager.sharedInstance.getAllRecordings() { (json) -> () in
      dispatch_async(dispatch_get_main_queue(), {
        let results : JSON = json["results"]
        print("Results:\(results)")
        // TODO: convert each json result to a Tune
/*        for result in results {
          var tune = Tune(result)
          tunes.append(tune)
        }

        self.tableView?.reloadData()
*/
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TuneViewCell", forIndexPath: indexPath) as! TuneViewCell
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.tune = tunes?[indexPath.row]
        let tapGesture = UITapGestureRecognizer(target:self, action: Selector("handleTap"))
        cell.addGestureRecognizer(tapGesture)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      //  return tunes.count
        return 21
    }

    func handleTap(){
        self.performSegueWithIdentifier("TuneToDetailSegue", sender: nil)
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
