//
//  PollCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/6/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class PollCell: UITableViewCell {

    
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var num_label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        num_label.layer.cornerRadius = num_label.layer.frame.height/2
        num_label.clipsToBounds = true
        num_label.layer.borderWidth = 2
        num_label.layer.borderColor = UIColor.blue.cgColor
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setCollectionViewDataSourceDelegate <D: UICollectionViewDataSource & UICollectionViewDelegate> (dataSourceDelegate: D, forRow section: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellWithReuseIdentifier: "QuestionCell")
        collectionView.isPagingEnabled = true
        collectionView.tag = section 
    }
    
    var collectionViewOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }
        set {
            collectionView.contentOffset.x = newValue
        }
    }
 }
