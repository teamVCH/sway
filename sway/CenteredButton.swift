//
//  CenteredButton.swift
//  sway
//
//  Created by Christopher McMahon on 11/12/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

class CenteredButton: UIButton {
    
    let padding: CGFloat = 5
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        let rect = super.titleRectForContentRect(contentRect)
        let y = CGRectGetHeight(contentRect) - CGRectGetHeight(rect) + padding
        return CGRectMake(0, y,
            CGRectGetWidth(contentRect), CGRectGetHeight(rect))
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        let rect = super.imageRectForContentRect(contentRect)
        let titleRect = titleRectForContentRect(contentRect)
        
        return CGRectMake(CGRectGetWidth(contentRect)/2.0 - CGRectGetWidth(rect)/2.0,
            (CGRectGetHeight(contentRect) - CGRectGetHeight(titleRect))/2.0 - CGRectGetHeight(rect)/2.0,
            CGRectGetWidth(rect), CGRectGetHeight(rect))
    }
    
    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        
        if let image = imageView?.image {
            var labelHeight: CGFloat = 0.0
            
            if let size = titleLabel?.sizeThatFits(CGSizeMake(CGRectGetWidth(self.contentRectForBounds(self.bounds)), CGFloat.max)) {
                labelHeight = size.height
            }
            
            return CGSizeMake(size.width, image.size.height + labelHeight)
        }
        
        return size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        centerTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }
    
    private func centerTitleLabel() {
        self.titleLabel?.textAlignment = .Center
    }
}
