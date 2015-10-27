//
//  PlayPauseButton.swift
//  sway
//
//  Created by Christopher McMahon on 10/27/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit

let playImage = UIImage(named: "play", inBundle: NSBundle(forClass: PlayPauseButton.self), compatibleWithTraitCollection: nil)

let pauseImage = UIImage(named: "pause", inBundle: NSBundle(forClass: PlayPauseButton.self), compatibleWithTraitCollection: nil)


@IBDesignable class PlayPauseButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setImage(playImage, forState: UIControlState.Normal)
        setImage(pauseImage, forState: UIControlState.Selected)
        
    }

}
