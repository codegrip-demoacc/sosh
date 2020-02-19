//
//  ChatMsgCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class ChatMsgCell: UICollectionViewCell {

    @IBOutlet var image: UIImageView!
    @IBOutlet var background: UIView!
    @IBOutlet var msg: UILabel!
    @IBOutlet var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
