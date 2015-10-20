//
//  TagCell.swift
//  sway
//
//  Created by Christopher McMahon on 10/20/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let tagCell = "TagCell"

class TagCell: UITableViewCell {

    @IBOutlet weak var tagLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
