//
//  PhotoCell.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/26/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var name_label: UILabel!
    @IBOutlet var mask_view: UIView!
    @IBOutlet var plus_view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
