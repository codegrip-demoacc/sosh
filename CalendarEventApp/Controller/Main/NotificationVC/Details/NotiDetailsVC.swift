//
//  NotiDetailsVC.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/22/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class NotiDetailsVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var userModel = [String: Any]()
    var type = String()
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        init_UI()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        tableView.register(UINib(nibName: "NotiCell", bundle: nil), forCellReuseIdentifier: "NotiCell")
        tableView.isScrollEnabled = true
        
        tableView.reloadData()
    }
    
    //-------------------- friend request -----------------------------
    @objc func acceptFriendRequest(_ sender: UIButton) {
        let docId = ShareData.friendsNoti[index].id! + (self.userModel[user.uid] as! String)
        let ref = Firestore.firestore().collection("requests").document(docId)
        ref.updateData(["status": 1, "read": true]){(error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                ShareData.isFriendChange = true
                ShareData.isEventChange = true
                ShareData.friendsNoti.remove(at: self.index)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func rejectFriendRequest(_ sender: UIButton) {
        let docId = ShareData.friendsNoti[index].id! + (self.userModel[user.uid] as! String)
        let ref = Firestore.firestore().collection("requests").document(docId)
        ref.updateData(["status": -1, "read": true]){(error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                ShareData.isFriendChange = true
                ShareData.friendsNoti.remove(at: self.index)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func skipFriendRequest(_ sender: UIButton) {
        let docId = ShareData.friendsNoti[index].id! + (self.userModel[user.uid] as! String)
        let ref = Firestore.firestore().collection("requests").document(docId)
        ref.updateData(["read": true]){(error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("read friend request but skipped.")
            }
        }
    }
    
    @objc func readUnfriendRequest(_ indexPath: IndexPath) {
        let docId = ShareData.friendsNoti[index].id! + (self.userModel[user.uid] as! String)
        Firestore.firestore().collection("requests").document(docId).delete(){(error) in
            if let err = error{
                print(err.localizedDescription)
            } else {
                ShareData.friendsNoti.remove(at: self.index)
                ShareData.isFriendChange = true
                ShareData.isEventChange = true
                self.tableView.reloadData()
            }
        }
    }
    
//-------------------- event invitation -----------------------------
    @objc func acceptEventInvitation(_ sender: UIButton) {
        let docId = ShareData.eventsNoti[index].id!
        let ref = Firestore.firestore().collection("events").document(docId)
        var yes = Int()
        var tbd = Int()
        var accept = String()
        ref.getDocument{(document , error) in
            if let document = document , document.exists {
                yes = document.data()![event.yes] as! Int
                tbd = document.data()![event.tbd] as! Int
                accept = document.data()![event.accept] as! String
                
                if accept == "" {
                    accept = self.userModel[user.name] as! String
                } else {
                    accept += " , " + (self.userModel[user.name] as! String)
                }
                ref.updateData([event.yes: yes+1, event.tbd: tbd-1, event.accept: accept]){(err) in
                    if let err = err {
                        print(err.localizedDescription)
                    } else {
                        ref.collection("invite_list").document(self.userModel[user.uid] as! String).updateData(["status": 1, "read": true]) {(err) in
                            if let err = err {
                                print(err.localizedDescription)
                            } else {
                                print("accepted event invitation.")
                                ShareData.isEventChange = true
                                ShareData.eventsNoti.remove(at: self.index)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                print("No exist document")
            }
        }
    }
    
    @objc func rejectEventInvitation(_ sender: UIButton) {
        let docId = ShareData.eventsNoti[index].id!
        let ref = Firestore.firestore().collection("events").document(docId)
        var no = Int()
        var tbd = Int()
        ref.getDocument{(document , error) in
            if let document = document , document.exists {
                no = document.data()![event.no] as! Int
                tbd = document.data()![event.tbd] as! Int
                    
                ref.updateData([event.no: no+1, event.tbd: tbd-1]){(error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        ref.collection("invite_list").document(self.userModel[user.uid] as! String).updateData(["status": -1, "read": true]) {(err) in
                            if let err = err {
                                print(err.localizedDescription)
                            } else {
                                print("rejected event invitation.")
                                ShareData.isEventChange = true
                                ShareData.eventsNoti.remove(at: self.index)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                print("No exist document")
            }
        }
    }
    
    @objc func skipEventInvitation(_ sender: UIButton) {
        let docId = ShareData.eventsNoti[index].id!
        let ref = Firestore.firestore().collection("events").document(docId).collection("invite_list").document(self.userModel[user.uid] as! String)
        ref.updateData(["read": true]) {(err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("read but skipped.")
            }
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func init_UI() {
        self.navigationController?.isNavigationBarHidden = true 
    }
}

extension NotiDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch type {
        case notiType.friend:
            return ShareData.friendsNoti.count
        case notiType.event:
            return ShareData.eventsNoti.count
        case notiType.activity:
            return ShareData.activitiesNoti.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NotiCell") as! NotiCell
        
        switch type {
        case notiType.friend:
            if let photo_url = ShareData.friendsNoti[indexPath.section].photo {
                let url = URL(string: photo_url)
                let processor = DownsamplingImageProcessor(size: cell.img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 25)
                cell.img.kf.indicatorType = .activity
                cell.img.kf.setImage(with: url, placeholder: UIImage(named: "non_profile"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
            }
            
            cell.name_label.text = ShareData.friendsNoti[indexPath.section].name
            
            if ShareData.friendsNoti[indexPath.section].status == 0 {
                cell.detail_label.text = "You have a new friend request."
            } else if ShareData.friendsNoti[indexPath.section].status == 2 {
                cell.detail_label.text = "You have a unfriend request."
            }
            
            if ShareData.friendsNoti[indexPath.section].read! {
                cell.badge.alpha = 0
            } else {
                cell.badge.alpha = 1
            }
        case notiType.event:
            if let photo_url = ShareData.eventsNoti[indexPath.section].creator_photo {
                let url = URL(string: photo_url)
                let processor = DownsamplingImageProcessor(size: cell.img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 25)
                cell.img.kf.indicatorType = .activity
                cell.img.kf.setImage(with: url, placeholder: UIImage(named: "non_profile"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
            }
            
            cell.name_label.text = ShareData.eventsNoti[indexPath.section].creator_name
            cell.detail_label.text = "You have a new event invitation."
            
            if ShareData.eventsNoti[indexPath.section].read! {
                cell.badge.alpha = 0
            } else {
                cell.badge.alpha = 1
            }
        case notiType.activity:
            if let photo_url = ShareData.activitiesNoti[indexPath.section].creator_photo {
                let url = URL(string: photo_url)
                let processor = DownsamplingImageProcessor(size: cell.img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 25)
                cell.img.kf.indicatorType = .activity
                cell.img.kf.setImage(with: url, placeholder: UIImage(named: "non_profile"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
            }
            
            cell.name_label.text = ShareData.activitiesNoti[indexPath.section].creator_name
            cell.detail_label.text = "\(ShareData.activitiesNoti[indexPath.section].creator_name!) added new activites."
            if ShareData.activitiesNoti[indexPath.section].read! {
                cell.badge.alpha = 0
            } else {
                cell.badge.alpha = 1
            }
        default:
            break;
        }
        
        cell.layer.cornerRadius = 5
        cell.backgroundColor = .lightGray
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NotiCell") as! NotiCell
        index = indexPath.section
        switch type {
        case notiType.friend:
            
            if !ShareData.friendsNoti[index].read! {
                badge.friend -= 1
            }
            ShareData.friendsNoti[index].read = true
            
            if ShareData.friendsNoti[index].status == 0 {
                //new friend request
                ShareData().selectAlert(ShareData.friendsNoti[index].name!, "\(ShareData.friendsNoti[index].name!) sent you a friend request. \n Do you want to accept friend request?", 3, ["Accept", "Reject", "Not Now"], [.blue, .red, .blue], [.white, .white, .white], self, [#selector(acceptFriendRequest(_:)), #selector(rejectFriendRequest(_:)), #selector(skipFriendRequest(_:))])
            } else if ShareData.friendsNoti[index].status == 2 {
                //unfriend request
                ShareData().doneAlert(ShareData.friendsNoti[index].name!, "\(ShareData.friendsNoti[index].name!) sent unfriend request", "Done", {
                    self.readUnfriendRequest(indexPath)
                })
            }
        case notiType.event:
            if !ShareData.eventsNoti[index].read! {
                badge.event -= 1
            }
            ShareData.eventsNoti[index].read = true
            
            ShareData().selectAlert(ShareData.eventsNoti[index].name!, "\(ShareData.eventsNoti[index].creator_name!) sent you a new event invitation.\n Start at \(ShareData.eventsNoti[index].start_date!.monthAndDay()) \n End at \(ShareData.eventsNoti[index].end_date!.monthAndDay()) \n Do you want to accept this event invitation?", 3, ["Accept", "Reject", "Not Now"], [.blue, .red, .blue], [.white, .white, .white], self, [#selector(acceptEventInvitation(_:)), #selector(rejectEventInvitation(_:)), #selector(skipEventInvitation(_:))])
        case notiType.activity:
            ShareData().doneAlert(ShareData.appTitle, "\(ShareData.activitiesNoti[indexPath.section].creator_name!) added \(ShareData.activitiesNoti[indexPath.section].activity_count!) activities in \(ShareData.activitiesNoti[indexPath.section].event_name!).", "Done", {})
            if !ShareData.activitiesNoti[indexPath.section].read! {
                badge.activity -= 1
                ShareData.activitiesNoti[indexPath.section].read = true
               let ref = Firestore.firestore().collection("events").document(ShareData.activitiesNoti[indexPath.section].event_id!).collection("activity")
                ref.getDocuments() {(querySnapshot, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        for doc in querySnapshot!.documents {
                            var read_noti_users = doc.data()[activity.read] as! String
                            read_noti_users += " , " + (self.userModel[user.uid] as! String)
                            ref.document(doc.documentID).updateData([activity.read:read_noti_users])
                        }
                    }
                }
            }
        default:
            break
        }
        self.tableView.reloadData()
    }
}
