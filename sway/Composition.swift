//
//  Composition.swift
//  sway
//
//  Created on 10/23/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import Foundation

// a Composition is either a Draft (non-public) or a Tune (public)
// the protocol establishes the common functionality between both
protocol Composition {
    
    var title: String? {get}
    var length: Double? {get}
    var isDraft: Bool {get}
    var audioUrl: NSURL? {get}
    var tagNames: [String]? {get}
    var lastModified: NSDate? {get}


}