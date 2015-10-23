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

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var lastIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
