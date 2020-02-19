//
//  NotiCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/22/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class NotiCell: UITableViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var name_label: UILabel!
    @IBOutlet var detail_label: UILabel!
    @IBOutlet var badge: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        badge.layer.cornerRadius = badge.layer.frame.height/2
        img.layer.cornerRadius = img.layer.frame.height/2
        img.layer.masksToBounds = true
        img.layer.borderWidth = 1
        img.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
