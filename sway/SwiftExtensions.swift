//
//  SwiftExtensions.swift
//  sway
//
//  Created on 10/25/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import Foundation
import UIKit


// Miscellaneous extension collection

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

extension UIImageView {
    
    func setImageURLWithFade(url: NSURL, alpha: CGFloat, completion: ((image: UIImage) -> Void)?) {
        setImageURLWithFade(url, alpha: alpha, placeholder: nil, completion: completion)
    }
    
    func setImageURLWithFade(url: NSURL, alpha: CGFloat, placeholder: UIImage?, completion: ((image: UIImage) -> Void)?) {
        // aysnchronously load the image from cache if possible
        let urlRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60)
        setImageWithURLRequest(urlRequest, placeholderImage: placeholder, success: {
            (request:NSURLRequest,response:NSHTTPURLResponse?, image:UIImage!) -> Void in
            if response != nil {
                // if the image was fetched from the server, fade it in
                self.alpha = 0
                self.image = image
                self.setNeedsLayout()
                UIView.animateWithDuration(0.5, animations: {
                    self.alpha = alpha
                    }, completion: nil)
            } else {
                // if the image was fetched from cache, just display it
                self.image = image
                self.setNeedsLayout()
            }
            if completion != nil {
                completion!(image: image)
            }
            
            }, failure: {
                (request:NSURLRequest,response:NSHTTPURLResponse?, error:NSError) -> Void in
                self.image = nil
                self.cancelImageRequestOperation()
                self.setNeedsLayout()
        })
    }
    
    
    
    
    
}


extension UIViewController {
    
    func applyNavStyling() {
        if let _ = self.navigationController?.navigationBar {
            //nav.translucent = true
            //nav.barStyle = UIBarStyle.Black
            //nav.barTintColor = UIColor.whiteColor()
            //nav.tintColor = UIColor.blackColor()
        }
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    
    func showErrorAlert(title: String, message: String, error: NSError?) {
        
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    
    
}

extension UITableView {
    
    func openRows(section: Int, rowCount: Int, moveRows: [Int:Int]) {
        var indexesPathToInsert:[NSIndexPath] = []
        
        for var i = 0; i < rowCount; i++ {
            if !moveRows.values.contains(i) {
                indexesPathToInsert.append(NSIndexPath(forRow: i, inSection: section))
            }
        }
        
        if indexesPathToInsert.count > 0 {
            self.beginUpdates()
            for fromRow in moveRows.keys {
                let toRow = moveRows[fromRow]
                self.moveRowAtIndexPath(NSIndexPath(forRow: fromRow, inSection: section), toIndexPath: NSIndexPath(forRow: toRow!, inSection: section))
            }
            self.insertRowsAtIndexPaths(indexesPathToInsert, withRowAnimation: UITableViewRowAnimation.Middle)
            self.endUpdates()
        }
    }
    
    func closeRows(section: Int, rowCount: Int, keepRows: [Int]) {
        var indexesPathToDelete:[NSIndexPath] = []
        
        for var i = 0 ; i < rowCount; i++ {
            if !keepRows.contains(i) {
                indexesPathToDelete.append(NSIndexPath(forRow: i, inSection: section))
            }
        }
        
        if indexesPathToDelete.count > 0 {
            self.beginUpdates()
            self.deleteRowsAtIndexPaths(indexesPathToDelete, withRowAnimation: UITableViewRowAnimation.Middle)
            var toRow = 0
            for keepRow in keepRows {
                self.moveRowAtIndexPath(NSIndexPath(forRow: keepRow, inSection: section), toIndexPath: NSIndexPath(forRow: toRow++, inSection: section))
            }
            self.endUpdates()
        }
        
    }
    
}

extension UITableViewCell {
    
    func styleWithRoundedBorder() {
        layer.borderWidth = 1.0
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGrayColor().lighterColor().CGColor
    }
    
}

extension UIColor {
    
    func lighterColor() -> UIColor {
        return adjustedColor(0.2)
    }
    
    func darkerColor() -> UIColor {
        return adjustedColor(-0.2)
    }
    
    func adjustedColor(value: CGFloat) -> UIColor {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: max(r + value, 0.0), green: max(g + value, 0.0), blue: max(b + value, 0.0), alpha: a)
        } else {
            return UIColor()
        }
    }
    
}

extension UILabel {
    
    func highlightPattern(pattern: String, color: UIColor) {
        if let text = self.text {
            let attributed = NSMutableAttributedString(string: text)
            
            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            
            for match in regex.matchesInString(text, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSRange(location: 0, length: text.utf16.count)) as [NSTextCheckingResult] {
                attributed.addAttribute(NSForegroundColorAttributeName, value: color, range: match.range)
            }
            
            self.attributedText = attributed
            
        }
        
    }
    
    
}

extension Int {
    
    static func randomWithin(range: ClosedInterval<Int>) -> Int {
        return Int(arc4random_uniform(UInt32(range.end - range.start + 1))) + range.start
    }
    
}

extension String {
    
    func replace(pattern: String, replacement: String) -> String {
        let range = rangeOfString(pattern, options: .RegularExpressionSearch)
        if let range = range {
            return stringByReplacingCharactersInRange(range, withString: replacement)
        } else {
            return self
        }
    }
    
    var hexColor: UIColor {
        let hex = self.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clearColor()
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    /*
    Usage:
    
    "#f00".hexColor       // r 1.0 g 0.0 b 0.0 a 1.0
    "#be1337".hexColor    // r 0.745 g 0.075 b 0.216 a 1.0
    "#12345678".hexColor  // r 0.204 g 0.337 b 0.471 a 0.071
    */
    
    
}