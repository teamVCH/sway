//
//  SaveViewController.swift
//  sway
//
//  Created by Hina Sakazaki on 10/19/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class SaveViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var tunePreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let preView = UINib(nibName: "TuneViewCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! TuneViewCell
        preView.frame = tunePreview.bounds
        tunePreview.addSubview(preView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAsDraft(sender: AnyObject) {
    }

    @IBAction func share(sender: AnyObject) {
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
