//
//  UserView.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/19/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class UserView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var userModel = [String: Any]()
    var selectIndex = [Int]()
    
    override func awakeFromNib() {
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        ShareData.selected_users.removeAll()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(UINib(nibName: "FriendCell", bundle: nil), forCellWithReuseIdentifier: "FriendCell")
    } 
    
    @IBAction func done_btn_click(_ sender: Any) {
        NotificationCenter.default.post(name: .invite_list, object: nil)
        self.removeFromSuperview()
    }
    
    @IBAction func blankTouchAction(_ sender: Any) {
        self.removeFromSuperview()
    }
}

extension UserView {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShareData.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  20
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
        
            cell.name = ShareData.users[indexPath.row].name!
            if let photo_url = ShareData.users[indexPath.row].photo {
                let url = URL(string: photo_url)
                let processor = DownsamplingImageProcessor(size: cell.img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 25)
                cell.img.kf.indicatorType = .activity
                cell.img.kf.setImage(with: url, placeholder: UIImage(named: "non_profile"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
            }
            cell.border_color = .white
            if selectIndex.contains(indexPath.row) {
                cell.img.alpha = 0.7
            } else {
                cell.img.alpha = 1
            }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        if selectIndex.contains(indexPath.row) {
            if let index = self.selectIndex.index(of: indexPath.row) {
                self.selectIndex.remove(at: index)
                ShareData.selected_users.remove(at: index)
            }
        } else {
            selectIndex.append(indexPath.row)
            ShareData.selected_users.append(ShareData.users[indexPath.row])
        }
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
