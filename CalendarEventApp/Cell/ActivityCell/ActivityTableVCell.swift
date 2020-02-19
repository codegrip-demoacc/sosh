//
//  ActivityTableVCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/23/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class ActivityTableVCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.borderColor = UIColor.green.cgColor
        self.contentView.layer.borderWidth = 1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
