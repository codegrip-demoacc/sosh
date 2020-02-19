//
//  EventFriendCell.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/26/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class EventFriendCell: UITableViewCell {

    @IBOutlet var photo_img: UIImageView!
    @IBOutlet var name_label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func layoutSubviews() {
        photo_img.layer.cornerRadius = photo_img.layer.frame.height/2
        photo_img.layer.masksToBounds = true
        photo_img.layer.borderWidth = 1
        photo_img.layer.borderColor = UIColor.white.cgColor
    }
}
