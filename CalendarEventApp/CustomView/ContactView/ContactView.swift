//
//  ContactView.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/23/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import MessageUI

class ContactView: UIView, MFMailComposeViewControllerDelegate{
    @IBOutlet var collectionView: UICollectionView!
    
    var selectIndex = [Int]()
    var index = Int()
    
    override func awakeFromNib() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(UINib(nibName: "FriendCell", bundle: nil), forCellWithReuseIdentifier: "FriendCell")
    }
    
    func send_invite(_ index: Int) {
        if ShareData.contacts[index].emails!.count == 0 {
            ShareData().doneAlert(ShareData.appTitle, "No email saved for \(ShareData.contacts[index].name!).", "Done", {})
        } else {
            var emails = String()
            for i in 0..<ShareData.contacts[index].emails!.count{
                emails += ShareData.contacts[index].emails![i] + " , "
            }
            emails = emails.substring(to: emails.count-3)
            ShareData().selectAlert(ShareData.appTitle, "Please send invitation of using this app. \n Saved email(s): \(emails).", 2, ["OK", "Cancel"], [.blue, .blue], [.white, .white], self, [#selector(send_email(_ :)), #selector(blank_action(_:))])
        }
    }
    
    @objc func send_email(_ sender: UIButton) {
        self.send_messages_email(ShareData.contacts[index].emails!)
    }
    
    @objc func blank_action(_ sender: UIButton) {
        return
    }
    
    func send_messages_email(_ emails: [String]) {
        var dict = [String: [String]]()
        dict["emails"] = emails
        NotificationCenter.default.post(name: .send_email, object: nil, userInfo: dict)
        self.removeFromSuperview()
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.removeFromSuperview()
    }
}

extension ContactView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShareData.contacts.count
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
        
        cell.name = ShareData.contacts[indexPath.row].name!
        if UIImage(data: ShareData.contacts[indexPath.row].photo!) != nil {
            cell.img.image = UIImage(data: ShareData.contacts[indexPath.row].photo!)
        } else {
            cell.img.image = UIImage(named: "non_profile")
        }
        cell.border_color = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        if selectIndex.contains(indexPath.row) {
            if let index = self.selectIndex.index(of: indexPath.row) {
                self.selectIndex.remove(at: index)
            }
        } else {
            selectIndex.append(indexPath.row)
        }
        self.send_invite(indexPath.row)
    }
}
