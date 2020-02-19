//
//  NotificationVC.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/16/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import FirebaseFirestore

class NotificationVC: UIViewController {

    @IBOutlet weak var friend_badge_label: UILabel!
    @IBOutlet weak var friend_view: UIView!
    @IBOutlet weak var event_view: UIView!
    @IBOutlet weak var event_badge_label: UILabel!
    @IBOutlet weak var chat_view: UIView!
    @IBOutlet weak var chat_badge_label: UILabel!
    @IBOutlet weak var activiy_view: UIView!
    @IBOutlet weak var activity_badge_label: UILabel!
    @IBOutlet weak var expense_view: UIView!
    @IBOutlet weak var expense_badge_label: UILabel!
    
    var userModel = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        
        read_data()
        init_UI()
    }
    
    func read_data() {
        //new friend invite
        ShareData.friendsNoti.removeAll()
        let ref = Firestore.firestore().collection("requests")
            ref.getDocuments(){(querySnapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    
                    badge.friend = 0
                    for doc in querySnapshot!.documents {
                        if doc.data()["received_id"] as! String == (self.userModel[user.uid] as! String) {
                            if doc.data()["status"] as! Int == 0 || doc.data()["status"] as! Int == 2 {
                                ShareData.friendsNoti.append(NotiFriendData(id: doc.data()["sent_id"] as? String, name: doc.data()["sent_name"] as? String, photo: doc.data()["sent_photo"] as? String, status: doc.data()["status"] as? Int, read: doc.data()["read"] as? Bool))
                                if !(doc.data()["read"] as! Bool) {
                                    badge.friend += 1
                                    self.change_badge()
                                }
                            }
                        }
                    }
                }
        }
            
            //new event invite
            ShareData.eventsNoti.removeAll()
            let ref1 = Firestore.firestore().collection("events")
            ref1.getDocuments(){(querySnapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    badge.event = 0
                    for doc in querySnapshot!.documents {
                        let ref11 = ref1.document(doc.documentID).collection("invite_list")
                        ref11.getDocuments(){(query, _ ) in
                            for doc1 in query!.documents {
                                if doc1.documentID == self.userModel[user.uid] as! String {
                                    if doc1.data()["status"] as! Int == 0 {
                                        //not determine accept/reject
                                        ShareData.eventsNoti.append(NotiEventData(id: doc.data()["id"] as? String, name: doc.data()[event.name] as? String, start_date: doc.data()[event.start_date] as? String, end_date: doc.data()[event.end_date] as? String, location: doc.data()[event.location] as? String, creator_id: doc.data()[event.creator_id] as? String, creator_name: doc.data()[event.creator_name] as? String, creator_photo: doc.data()[event.creator_photo] as? String, status: doc1.data()["status"] as? Int, read: doc1.data()["read"] as? Bool))
                                    }
                                    // unread
                                    if !(doc1.data()["read"] as! Bool) {
                                        badge.event += 1
                                        self.change_badge()
                                    }
                                }
                            }
                        }
                    }
            }
        }
        
        //new activity adding
        ShareData.activitiesNoti.removeAll()
        let ref2 = Firestore.firestore().collection("events")
        ref2.getDocuments(){(querySnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                badge.activity = 0
                for doc in querySnapshot!.documents {
                    //if i am in accepted users
                    if (doc.data()[event.accept] as! String).contains(self.userModel[user.name] as! String) || (ShareData.friends.contains(where: { $0.uid == doc.data()[event.creator_id] as? String}) && !(doc.data()[event.isPrivate] as! Bool)){
                        let ref21 = ref2.document(doc.documentID).collection("activity")
                        ref21.getDocuments(){(query, _ ) in
                            var unread_activites = 0
                            var isRead = Bool()
                            for doc1 in query!.documents {
                                //if i am not in read users of this activity
                                if !(doc1.data()[activity.status] as! String).contains(self.userModel[user.uid] as! String) {
                                    unread_activites += 1
                                    if (doc1.data()[activity.read] as! String).contains(self.userModel[user.uid] as! String) {
                                        isRead = true
                                    } else {
                                        isRead = false
                                    }
                                }
                            }
                            if unread_activites > 0 {
                                if !isRead {
                                    badge.activity += 1
                                }
                                ShareData.activitiesNoti.append(NotiActivityData(event_id: doc.data()[event.id] as? String, event_name: doc.data()[event.name] as? String, creator_id: doc.data()[event.creator_id] as? String, creator_name: doc.data()[event.creator_name] as? String, creator_photo: doc.data()[event.creator_photo] as? String, activity_count: unread_activites, read: isRead))
                                self.change_badge()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func change_badge() {
        if badge.friend == 0 {
            self.friend_badge_label.alpha = 0
        } else {
            self.friend_badge_label.alpha = 1
        }
        self.friend_badge_label.text = "\(badge.friend)"
        
        if badge.event == 0 {
            self.event_badge_label.alpha = 0
        } else {
            self.event_badge_label.alpha = 1
        }
        self.event_badge_label.text = "\(badge.event)"
        if badge.activity == 0 {
            self.activity_badge_label.alpha = 0
        } else {
            self.activity_badge_label.alpha = 1
        }
        self.activity_badge_label.text = "\(badge.activity)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        change_badge()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func friend_invite_btn_click(_ sender: Any) {
        if ShareData.friendsNoti.count == 0 {
            ShareData().doneAlert("", "There is no new friend request.", "Done", {})
        } else {
            let vc = NotiDetailsVC()
            vc.type = notiType.friend
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func event_invite_btn_click(_ sender: Any) {
        if ShareData.eventsNoti.count == 0 {
            ShareData().doneAlert("", "There is no new event invitation.", "Done", {})
        } else {
            let vc = NotiDetailsVC()
            vc.type = notiType.event
            self.navigationController?.pushViewController(vc, animated: true)
        }
     }
    
    @IBAction func chat_poll_btn_click(_ sender: Any) {
        ShareData().doneAlert("", "There is no new chat poll.", "Done", {})
//        let vc = NotiDetailsVC()
//        vc.type = notiType.chat
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func activity_added_btn_click(_ sender: Any) {
        if ShareData.activitiesNoti.count == 0 {
            ShareData().doneAlert("", "There is no new added activity.", "Done", {})
        } else {
            let vc = NotiDetailsVC()
            vc.type = notiType.activity
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func expense_btn_click(_ sender: Any) {
        ShareData().doneAlert("", "There is no new expense.", "Done", {})
//        let vc = NotiDetailsVC()
//        vc.type = notiType.expense
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func init_UI() {
        self.navigationController?.isNavigationBarHidden = true
        
        friend_view.layer.cornerRadius = 10
        friend_view.layer.borderColor = UIColor.blue.cgColor
        friend_view.layer.borderWidth = 1.5
        friend_badge_label.layer.cornerRadius = friend_badge_label.layer.frame.height/2
        friend_badge_label.layer.masksToBounds = true 
        
        event_view.layer.cornerRadius = 10
        event_view.layer.borderColor = UIColor.blue.cgColor
        event_view.layer.borderWidth = 1.5
        event_badge_label.layer.cornerRadius = event_badge_label.layer.frame.height/2
        event_badge_label.layer.masksToBounds = true
        
        chat_view.layer.cornerRadius = 10
        chat_view.layer.borderColor = UIColor.blue.cgColor
        chat_view.layer.borderWidth = 1.5
        chat_badge_label.layer.cornerRadius = chat_badge_label.layer.frame.height/2
        chat_badge_label.layer.masksToBounds = true
        
        activiy_view.layer.cornerRadius = 10
        activiy_view.layer.borderColor = UIColor.blue.cgColor
        activiy_view.layer.borderWidth = 1.5
        activity_badge_label.layer.cornerRadius = activity_badge_label.layer.frame.height/2
        activity_badge_label.layer.masksToBounds = true
        
        expense_view.layer.cornerRadius = 10
        expense_view.layer.borderColor = UIColor.blue.cgColor
        expense_view.layer.borderWidth = 1.5
        expense_badge_label.layer.cornerRadius = expense_badge_label.layer.frame.height/2
        expense_badge_label.layer.masksToBounds = true
    }
}
