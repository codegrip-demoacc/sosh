//
//  AnswerCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/6/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class AnswerCell: UITableViewCell {

    @IBOutlet weak var circle_view: UIView!
    @IBOutlet weak var answer_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circle_view.layer.cornerRadius = circle_view.layer.frame.height/2
        circle_view.layer.borderWidth = 1.5
        circle_view.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
