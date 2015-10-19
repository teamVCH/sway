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

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typeControl: UISegmentedControl!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var drafts = [Recording]()
    var selectedDraft: Recording?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: tuneViewCell, bundle: nil), forCellReuseIdentifier: tuneViewCell)

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadDrafts()
        
        tableView.reloadData()
        
        
    }
    
    private func loadDrafts() {
        
        do {
            let fetchRequest = NSFetchRequest(entityName: recordingEntityName)
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Recording] {
                print("Found \(fetchResults.count) drafts")
                drafts = fetchResults
            }
            
        } catch let error as NSError {
            print("Error loading drafts: \(error)")
        }
        
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if typeControl.selectedSegmentIndex == 0 {
            // public
            print("Not implemented") // TODO
        } else {
            // drafts
            rowCount = drafts.count
        }
        return rowCount
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tuneViewCell, forIndexPath: indexPath) as! TuneViewCell
        
        if typeControl.selectedSegmentIndex == 0 {
            // public
            print("Not implemented") // TODO
        } else {
            // drafts
            cell.recording = drafts[indexPath.row]
        }
        
        // hide user button from user profile page
        cell.userButton.hidden = true
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if typeControl.selectedSegmentIndex == 0 {
                // public
                print("Not implemented") // TODO
            } else {
                // drafts
                let draft = drafts[indexPath.row]
                managedObjectContext.deleteObject(draft)
                loadDrafts()
                tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if typeControl.selectedSegmentIndex == 0 {
            // public
            print("Not implemented") // TODO
        } else {
            // drafts
            performSegueWithIdentifier(loadDraftSegue, sender: self)
        
        }
        
        
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
        if segue.identifier == loadDraftSegue {
            let recordViewController = segue.destinationViewController as! RecordViewController
            recordViewController.recording = selectedDraft
        
        }
        
        
    }
    

}
