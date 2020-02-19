//
//  MainChatChatVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Kingfisher
import FirebaseFirestore
import NVActivityIndicatorView
import UserNotifications

class MainChatChatVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var chat_frame: UIView!
    @IBOutlet var msg_text: UITextField!
    @IBOutlet var msg_send_btn: UIButton!
    @IBOutlet var event_name_label: UILabel!
    @IBOutlet var chat_frame_bottom_con: NSLayoutConstraint!
    
    
    var userModel = [String: Any]()
    
    var selectEvent = [String: Any]()
    var msgLists = [[String: Any]]()
    var chat_listener : ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        
        setupTableView()
        self.setupCollectionView()
        
        if ShareData.isEventChange {
            read_events()
        } else {
            self.tableView.reloadData()
        }
        
        init_UI()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 40
        tableView.register(UINib(nibName: "EventNameCell", bundle: nil), forCellReuseIdentifier: "EventNameCell")
        tableView.isScrollEnabled = true
        
        tableView.reloadData()
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ChatMsgCell", bundle: nil), forCellWithReuseIdentifier: "ChatMsgCell")
    }
    
//--------------------- get available all events -------------------
    func read_events() {
        
        self.startAnimating(CGSize(width: 50, height: 50), message: "Loading...", type: ShareData.progressDlgs[23], color: .white, fadeInAnimation: nil)
        ShareData.events.removeAll()
        ShareData.arrangedEvents.removeAll()
        let ref = Firestore.firestore().collection("events")
        var isShow = false
        DispatchQueue.main.async {
            ref.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.stopAnimating(nil)
                    print("Error getting documents: \(err)");
                } else {
                    for document in querySnapshot!.documents {
                        if document.data()[event.creator_id] as! String == self.userModel[user.uid] as! String {
                            // if i created this event
                            isShow = true
                        } else {
                            // if creator is my friend and this event is public
                            if ShareData.friends.contains(where: { $0.uid == document.data()[event.creator_id] as? String }) && !(document.data()[event.isPrivate] as? Bool)! {
                                isShow = true
                            }
                            //if my name is in accepted users
                            if (document.data()[event.accept] as! String).contains(self.userModel[user.name] as! String) {
                                isShow = true
                            }
                        }
                        if isShow {
                            ShareData.events.append(document.data())
                            isShow = false
                        }
                    }
                    self.stopAnimating(nil)
                    self.rearrange_events()
                    ShareData.isEventChange = false
                }
            }
        }
    }
    
    func rearrange_events() {
        if ShareData.events.count == 0 {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        ShareData.events = ShareData.events.sorted {
            guard let date1 = dateFormatter.date(from:$0["start_date"] as! String), let date2 = dateFormatter.date(from:$1["start_date"] as! String) else { return false}
            return date1 > date2
        }
        
        var firstArray = [[String: Any]]()
        firstArray.append(ShareData.events[0])
        let calendar = Calendar(identifier: .gregorian)
        for i in 1..<ShareData.events.count {
            let prevDate = dateFormatter.date(from: ShareData.events[i-1][event.start_date] as! String)!
            let nextDate = dateFormatter.date(from: ShareData.events[i][event.start_date] as! String)!
            if !calendar.isDate(prevDate, equalTo: nextDate, toGranularity: .month) {
                ShareData.arrangedEvents.append(firstArray)
                firstArray.removeAll()
            }
            firstArray.append(ShareData.events[i])
        }
        if firstArray.count > 0 {ShareData.arrangedEvents.append(firstArray)}
        self.tableView.reloadData()
    }
    
// ------------------ chatting frame -----------------
    @IBAction func backAction(_ sender: Any) {
        self.chat_frame.isHidden = true
        self.chat_listener.remove()
    }
    
    @IBAction func msg_send_btn_click(_ sender: Any) {
        if self.msg_text.text == "" {
            return
        }
        self.msg_send()
    }
    
    func read_messages() {
        
        chat_listener = Firestore.firestore().collection("events").document(selectEvent[event.id] as! String).collection("chat").addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else { return }
            self.msgLists.removeAll()
            for document in (querySnapshot?.documents)!{
                self.msgLists.append(document.data())
            }
            
            self.collectionView.reloadData()
            self.collectionView.scrollToLast()
        }
    }
    
    func msg_send() {
        let text = self.msg_text.text!
        self.msg_text.text = ""
        let time = Timestamp()
        let ref = Firestore.firestore().collection("events").document(self.selectEvent[event.id] as! String).collection("chat").document("\(time)")
        let registerData = [message.sender_id: self.userModel[user.uid] as! String, message.sender_name: self.userModel[user.name] as! String, message.sender_photo: self.userModel[user.photo] as! String, message.text: text, message.time: time] as [String : Any]
        ref.setData(registerData){ (error) in
            if let err = error {
                print("Error adding document: \(err.localizedDescription)")
            } else {
                print("successfully saved message")
            }
        }
    }
    
    func init_UI() {
        self.navigationController?.isNavigationBarHidden = true
        self.hideKeyboardWhenTappedAround()
        self.chat_frame.isHidden = true
        
        msg_send_btn.layer.borderColor = UIColor.blue.cgColor
        msg_send_btn.layer.borderWidth = 1
        msg_send_btn.layer.cornerRadius = msg_send_btn.layer.frame.height/2
        msg_send_btn.clipsToBounds = true
        
        msg_text.setLeftPaddingPoints(15)
        msg_text.layer.borderColor = UIColor.lightGray.cgColor
        msg_text.layer.borderWidth = 1
        msg_text.layer.cornerRadius = msg_text.layer.frame.height/2
        msg_text.delegate = self
        msg_text.placeholder = "Write a message..."
        msg_text.returnKeyType = .send
    }
}

extension MainChatChatVC: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.msg_text.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.msg_send()
        return true
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.chat_frame_bottom_con?.constant = 0.0
            } else {
                self.chat_frame_bottom_con?.constant = (endFrame?.size.height)! * -1 + 180
            }
            UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: {
                self.view.layoutIfNeeded()
                self.collectionView.reloadData()
                self.collectionView.scrollToLast()
            }, completion: nil)
        }
    }
}

extension MainChatChatVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ShareData.events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "EventNameCell") as! EventNameCell
        cell.name_label.text = ShareData.events[indexPath.section][event.name] as? String
        cell.badge_label.alpha = 0
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chat_frame.isHidden = false
        self.selectEvent = ShareData.events[indexPath.section]
        self.event_name_label.text = self.selectEvent[event.name] as? String
        self.read_messages()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

extension MainChatChatVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return msgLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont.systemFont(ofSize: 15)
        let msgDefaultWidth = UIScreen.main.bounds.width / 2 + 40
        let msgWidth = (msgLists[indexPath.section][message.text] as! String).widthOfString(font: font)
        let msgHeight = (msgLists[indexPath.section][message.text] as! String).heightOfString(font: font)
        let width = UIScreen.main.bounds.width
        var height: CGFloat = 0.0
        var lines: Int = 0
        
        if msgWidth > msgDefaultWidth {
            lines = Int(msgWidth / msgDefaultWidth) + 1
        } else {
            lines = 1
        }
        
        height = msgHeight * CGFloat(lines)
        return CGSize(width: width, height: height + 27)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatMsgCell", for: indexPath) as! ChatMsgCell
        
        let font = UIFont.systemFont(ofSize: 15)
        let msgDefaultWidth = UIScreen.main.bounds.width / 2 + 40
        let msgWidth = (self.msgLists[indexPath.section][message.text] as! String).widthOfString(font: font)
        let msgHeight = (self.msgLists[indexPath.section][message.text] as! String).heightOfString(font: font)
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        var lines: Int = 0
        var frame = CGRect()
        
        if msgWidth > msgDefaultWidth {
            width = msgDefaultWidth
            lines = Int(msgWidth / msgDefaultWidth) + 1
            
        } else {
            width = msgWidth
            lines = 1
        }
        height = msgHeight * CGFloat(lines)
        
        var time_str = ""
        if let time = self.msgLists[indexPath.section][message.time] as? Timestamp {
            let formater = DateFormatter()
            formater.dateFormat = "yyyy MMM dd, hh:mm:ss a"
            time_str = formater.string(from: time.dateValue()).chatHistoryTime("yyyy MMM dd, hh:mm:ss a")
            cell.time.text = time_str
        }
        
        let time_str_width = time_str.widthOfString(font: UIFont.systemFont(ofSize: 10))
        let time_str_height = time_str.heightOfString(font: UIFont.systemFont(ofSize: 10))
        
        if (self.msgLists[indexPath.section][message.sender_id] as! String) == (self.userModel[user.uid] as! String) {
            //if message that i sent
            cell.image.isHidden = true
            
            cell.background.frame = CGRect(x: cell.frame.width - width - 20, y: 0, width: width + 10, height: height + 10)
            cell.background.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 12)
            cell.background.clipsToBounds = true
            cell.background.backgroundColor = ShareData.main_back_blue
            //                cell.background.layer.borderWidth = 1
            //                cell.background.layer.borderColor = UIColor.blue.cgColor
            cell.background.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
            
            frame = CGRect(x: cell.frame.width - width - 15, y: 5, width: width, height: height)
            cell.time.frame = CGRect(x: cell.background.frame.maxX - time_str_width - 5, y: cell.background.frame.maxY + 2, width: time_str_width, height: time_str_height)
            cell.time.textAlignment = .right
            cell.msg.textColor = UIColor.white
        } else {
            //if message that other user sent
            cell.image.isHidden = false
            cell.image.frame = CGRect(x: 5, y: height - 15, width: 25, height: 25)
            let photo_url = self.msgLists[indexPath.section][message.sender_photo] as! String
            let url = URL(string: photo_url)
            let processor = DownsamplingImageProcessor(size: cell.image.frame.size) >> RoundCornerImageProcessor(cornerRadius: 12.5)
            cell.image.kf.indicatorType = .activity
            cell.image.kf.setImage(with: url, placeholder: UIImage(named: "non_profile"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
            
            cell.background.frame = CGRect(x: 40, y: 0, width: width + 10, height: height + 10)
            cell.background.roundCorners(corners: [.topLeft, .topRight, .bottomRight], radius: 12)
            //                cell.background.layer.borderWidth = 1
            //                cell.background.layer.borderColor = UIColor.blue.cgColor
            cell.background.clipsToBounds = true
            cell.background.backgroundColor = ShareData.main_back_green
            //                cell.background.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
            
            frame = CGRect(x: 45, y: 5, width: width, height: height)
            cell.time.frame = CGRect(x: cell.background.frame.minX + 5, y: cell.background.frame.maxY + 2, width: time_str_width, height: time_str_height)
            cell.time.textAlignment = .left
            cell.msg.textColor = UIColor.white
        }
        
        cell.msg.numberOfLines = lines
        cell.msg.lineBreakMode = .byWordWrapping
        cell.msg.frame = frame
        
        cell.msg.text = self.msgLists[indexPath.section][message.text] as? String
        
        return cell
    }
}

extension MainChatChatVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Chat")
    }
}
