//
//  LoginViewController.swift
//  sway
//
//  Created by Vicki Chun on 10/17/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if (PFUser.currentUser() == nil) {
      presentLogin()
    } else {
      performSegueWithIdentifier("loginSegue", sender: self)
    }
  }

  private func presentLogin() {
    // TODO: Add custom logo and text
    let loginViewController = PFLogInViewController()
    loginViewController.delegate = self
    loginViewController.fields = PFLogInFields(rawValue: PFLogInFields.UsernameAndPassword.rawValue
      | PFLogInFields.LogInButton.rawValue
      | PFLogInFields.PasswordForgotten.rawValue
      | PFLogInFields.SignUpButton.rawValue
      | PFLogInFields.Twitter.rawValue)
    
    loginViewController.emailAsUsername = true
    
    let loginLogoTitle = UILabel()
    loginLogoTitle.text = "Sway"
    loginLogoTitle.font = UIFont.boldSystemFontOfSize(18.0)
    loginViewController.logInView?.logo = loginLogoTitle
    
    loginViewController.signUpController?.delegate = self
    
    let signUpLogoTitle = UILabel()
    signUpLogoTitle.text = "Sway"
    signUpLogoTitle.font = UIFont.boldSystemFontOfSize(18.0)
    
    loginViewController.signUpController?.signUpView?.logo = signUpLogoTitle
    loginViewController.signUpController?.delegate = self
    presentViewController(loginViewController, animated: false, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

//MARK: PFLoginViewControllerDelegate
extension LoginViewController : PFLogInViewControllerDelegate {
  func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
    dismissViewControllerAnimated(true, completion: nil)
    performSegueWithIdentifier("loginSegue", sender: self)
  }
  
  func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
    
    if (!username.isEmpty && !password.isEmpty) {
      return true
    } else {
      print("username or password empty")
      return false
    }
  }
  
  func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
    print("Failed to login \(error?.description)")
  }
}

//MARK: PFSignUpViewControllerDelegate
extension LoginViewController : PFSignUpViewControllerDelegate {
  func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
    self.dismissViewControllerAnimated(true, completion: nil)
    self.performSegueWithIdentifier("loginSegue", sender: self)
  }
  
  func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
    var isInfoComplete : Bool = true
    // TODO: show error message
    for (key, value) in info {
      let fieldValue: String? = value as? String
      if let fieldValue = fieldValue where fieldValue.isEmpty {
        isInfoComplete = false
        break;
      }
    }
    return isInfoComplete
  }
  
  func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
    print("Failed to signup \(error?.description)")
  }
  
}