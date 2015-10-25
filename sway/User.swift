//
//  User.swift
//  sway
//
//  Created by Hina Sakazaki on 10/18/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var profileImageURL: String?
    var screenName: String?
    var tagLine: String?
    
    static var _currentUser: User?
    
    init(object: PFUser) {
        print("user init")
        
        // If twitter user then get
        // profileImageURL and screenName
        if PFTwitterUtils.isLinkedWithUser(object) {
            print("is twitter user")
            // TODO: Query for twitter info
            let authToken = PFTwitterUtils.twitter()?.authToken
            screenName = PFTwitterUtils.twitter()?.screenName
        }
        else {
            name = object["username"] as? String
        }

    }
    
 }
