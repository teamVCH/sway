//
//  TagCell.swift
//  sway
//
//  Created by Christopher McMahon on 10/24/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let tagCell = "TagCell"
let kLabelVerticalInsets: CGFloat = 2.0
let kLabelHorizontalInsets: CGFloat = 2.0

let tagCellDeselectedColor = UIColor(hue: 0.25, saturation: 0, brightness: 0.94, alpha: 1.0) /* #efefef */
let tagCellSelectedColor = UIColor(hue: 0.6194, saturation: 0.31, brightness: 1, alpha: 1.0) /* #afc6ff */

class TagCell: UICollectionViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    
    
    override var selected: Bool {
        didSet {
            super.selected = selected
            if self.selected {
                backgroundColor = tagCellSelectedColor
            } else {
                backgroundColor = tagCellDeselectedColor
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Need set autoresizingMask to let contentView always occupy this view's bounds, key for iOS7
        self.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        //self.layer.masksToBounds = true
    }
    
    // In layoutSubViews, need set preferredMaxLayoutWidth for multiple lines label
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set what preferredMaxLayoutWidth you want
        tagLabel.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
    }
    
    func configCell(tag: String) {
        tagLabel.text = tag
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    
    
}
