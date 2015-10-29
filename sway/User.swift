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
    var email: String?
    var userId: String?
    
    init(object: PFUser) {
        userId = object.objectId
        name = object.username
        profileImageURL = object.objectForKey("profileImageUrl") as? String
        email = object.email
        screenName = object.objectForKey("screenName") as? String
        tagLine = object.objectForKey("tagLine") as? String
    }
 }
