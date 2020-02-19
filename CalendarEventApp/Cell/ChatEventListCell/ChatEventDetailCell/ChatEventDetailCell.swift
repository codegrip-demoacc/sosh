//
//  ChatEventDetailCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/7/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class ChatEventDetailCell: UITableViewCell {

    @IBOutlet weak var tag_view: UIView!
    @IBOutlet weak var detail_label: UILabel!
    @IBOutlet weak var plus_img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tag_view.layer.cornerRadius = tag_view.layer.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
