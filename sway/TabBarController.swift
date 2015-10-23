//
//  TabBarController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/17/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let recordTabTitle = "Record"
let recordModalSegue = "RecordModalSegue"
let savedDraft = "savedDraft"
let publishedTune = "publishedTune"


class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var lastIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSavedDraft", name: savedDraft, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onPublishedTune", name: publishedTune, object: nil)
        
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (item.title == recordTabTitle) {
            performSegueWithIdentifier(recordModalSegue, sender: nil)
        } else {
            lastIndex = selectedIndex
        }
    }
    */

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        print("shouldSelect")
        // This will break if the modal view controller is not the second tab
        let modalController = viewControllers![1] //as! UIViewController
        
        // Check if the view about to load is the second tab and if it is, load the modal form instead.
        if viewController == modalController {
            let storyboard = UIStoryboard(name: "Record", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()
            presentViewController(vc!, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    func onSavedDraft() {
        showUserProfile(false)
        
    }
    
    func onPublishedTune() {
        showUserProfile(true)
        
    }
    
    func showUserProfile(publishedTunes: Bool) {
        let userProfileVC = viewControllers![2] as! UserProfileViewController
        userProfileVC.selectedType = publishedTunes ? 0 : 1
        selectedViewController = userProfileVC
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
