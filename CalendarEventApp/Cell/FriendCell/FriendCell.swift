//
//  FriendCell.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class FriendCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet var name_label: UILabel!
    
    var name = String()
    var border_color = UIColor()
    
    override func awakeFromNib() {
        super.awakeFromNib() 
    }
    
    override func layoutSubviews() {
        if name == "" {
            name_label.text = "Invite"
            img.image = UIImage(named: "plus")
        } else {
            name_label.text = name
            img.layer.cornerRadius = img.layer.frame.height/2
            img.layer.masksToBounds = true
            img.layer.borderWidth = 1
            img.layer.borderColor = border_color.cgColor
        }
    }
}
