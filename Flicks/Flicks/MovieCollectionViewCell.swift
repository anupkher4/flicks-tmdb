//
//  MovieCollectionViewCell.swift
//  Flicks
//
//  Created by Anup Kher on 4/2/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //titleLabel.center = posterImageView.center
        //titleLabel.bounds.size.width = posterImageView.bounds.size.width
    }
}
