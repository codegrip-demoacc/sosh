//
//  EventListTableVCell.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class EventListTableVCell: UITableViewCell {

    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet var back_mask: UIView!
    
    @IBOutlet var name_label: UILabel!
    @IBOutlet var date_label: UILabel!
    @IBOutlet var bottom_left_label: UILabel!
    @IBOutlet var bottom_right_stackView: UIStackView!
    
    @IBOutlet var bottom_right_location_label: UILabel!
    @IBOutlet var yes_num_label: UILabel!
    @IBOutlet var no_num_label: UILabel!
    @IBOutlet var tbd_num_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.back_img.layer.cornerRadius = 5
        self.back_img.layer.masksToBounds = true
        self.back_mask.layer.cornerRadius = 5
        self.back_mask.layer.masksToBounds = true
        
        self.contentView.layer.borderColor = UIColor.blue.cgColor
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
