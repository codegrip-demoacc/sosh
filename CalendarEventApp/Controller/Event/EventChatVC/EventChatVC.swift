//
//  EventChatVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class EventChatVC: UIViewController {

    @IBOutlet weak var chat_collectionView: UICollectionView!
    @IBOutlet weak var poll_collectionView: UICollectionView!
    @IBOutlet weak var poll_num_label: UILabel!
    @IBOutlet weak var poll_frame_height: NSLayoutConstraint!
    
    @IBOutlet var name_label: UILabel!
    @IBOutlet var chat_badge_label: UILabel!
    @IBOutlet var load_more_btn: UIButton!
    @IBOutlet var msg_text: UITextField!
    @IBOutlet var msg_send_btn: UIButton!
    
    var msgLists = [[String: Any]]()
    var questions = [QuestionData]()
    var selectEvent = [String: Any]()
    var userModel = [String: Any] ()
    var chat_listener : ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        dummy_data()
        init_UI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        read_data()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        chat_listener.remove()
    }
    
    @IBAction func msg_send_btn_click(_ sender: Any) {
        if self.msg_text.text == "" {
            return
        }
        self.msg_send()
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
    
    @objc func addBtnClick(_ sender: UIButton!) {
        print(sender.tag)
    }
    
    func tableViewCellSelectHandler( collectionIndex: IndexPath, tableIndex: IndexPath, caption: String) {
        print(collectionIndex.row)
        print(tableIndex.row)
        print(caption)
    }
    
    func read_data() {
        selectEvent = UserDefaults.standard.object(forKey: "selectEvent") as! [String : Any]
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        self.name_label.text = self.selectEvent[event.name] as? String
        chat_listener = Firestore.firestore().collection("events").document(selectEvent[event.id] as! String).collection("chat").addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else { return }
            self.msgLists.removeAll()
            for document in (querySnapshot?.documents)!{
                self.msgLists.append(document.data())
            }
            self.chat_collectionView.reloadData()
            self.chat_collectionView.scrollToLast()
        }
    }
    
    func dummy_data() {
        questions.append(QuestionData(id: "", question: "What do you want to do Saturday?", answers: ["Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        questions.append(QuestionData(id: "", question: "What do you want to do Sunday?", answers: ["Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        questions.append(QuestionData(id: "", question: "What do you want to do Monday?", answers: ["Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking.","Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions"]))
        questions.append(QuestionData(id: "", question: "What do you want to do Tuesday?", answers: ["Hike `that` trail in the morning.", "Hike `that` trail in the morning.", "Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking.", "I don't know, I can't even tie my shoes without overthinking."]))
    }
    
    func setupCollectionView() {
        poll_collectionView.dataSource = self
        poll_collectionView.delegate = self
        poll_collectionView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellWithReuseIdentifier: "QuestionCell")
        poll_collectionView.isPagingEnabled = true
        
        chat_collectionView.dataSource = self
        chat_collectionView.delegate = self
        chat_collectionView.register(UINib(nibName: "ChatMsgCell", bundle: nil), forCellWithReuseIdentifier: "ChatMsgCell")
    }
    
    func init_UI () {
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        poll_num_label.backgroundColor = ShareData.main_back_green
        poll_num_label.layer.cornerRadius = poll_num_label.layer.frame.height/2
        poll_num_label.clipsToBounds = true
        poll_num_label.layer.borderWidth = 2
        poll_num_label.layer.borderColor = UIColor.blue.cgColor
        poll_num_label.text = "1"
        poll_frame_height.constant = CGFloat(40*questions[0].answers!.count + 110)
        
        chat_badge_label.backgroundColor = ShareData.main_back_green
        chat_badge_label.layer.cornerRadius = chat_badge_label.layer.frame.height/2
        chat_badge_label.clipsToBounds = true
        chat_badge_label.layer.borderWidth = 2
        chat_badge_label.layer.borderColor = UIColor.blue.cgColor
        chat_badge_label.text = "1"
        chat_badge_label.alpha = 0
        
        load_more_btn.layer.cornerRadius = load_more_btn.frame.height/2
        load_more_btn.clipsToBounds = true
        
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

extension EventChatVC: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        self.view.layoutIfNeeded()
        self.chat_collectionView.reloadData()
        self.chat_collectionView.scrollToLast()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.msg_send()
        return (true)
    }
}

extension EventChatVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == chat_collectionView {
            return msgLists.count
        } else {
            return questions.count
        }
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
        if collectionView == chat_collectionView {
            let font = UIFont.systemFont(ofSize: 15)
            let msgDefaultWidth = UIScreen.main.bounds.width / 2 + 40
            let msgWidth = (msgLists[indexPath.section][message.text] as! String).widthOfString(font: font)
            let msgHeight = (msgLists[indexPath.section][message.text] as! String).heightOfString(font: font)
            let width = UIScreen.main.bounds.width
            var height: CGFloat = 0.0
            var lines: Int = 0
            
            if msgWidth > msgDefaultWidth {
//                width = msgDefaultWidth
                lines = Int(msgWidth / msgDefaultWidth) + 1
                
            } else {
//                width = msgWidth
                lines = 1
            }
            
            height = msgHeight * CGFloat(lines)
            return CGSize(width: width, height: height + 27)
        } else {
            var height = CGFloat()
            height = CGFloat(40*questions[indexPath.section].answers!.count + 80)
            return CGSize(width: poll_collectionView.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == chat_collectionView {
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
            
            cell.question_label.text = questions[indexPath.section].question
            cell.answers = questions[indexPath.section].answers!
            cell.table_height.constant = CGFloat(40*questions[indexPath.section].answers!.count)
            
            cell.plus_btn.tag = indexPath.section
            cell.plus_btn.addTarget(self, action: #selector(self.addBtnClick(_:)), for: .touchUpInside)
            
            cell.selectCellHandler = { ( _ subIndexPath: IndexPath, _ caption: String) -> Void in
                
                self.tableViewCellSelectHandler(collectionIndex: indexPath, tableIndex: subIndexPath, caption: caption)
            }
            return cell
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == chat_collectionView {
            
        } else {
            var visibleRect = CGRect()
            
            visibleRect.origin = scrollView.contentOffset
            visibleRect.size = scrollView.bounds.size
            
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            
            let row = Int(visiblePoint.x / self.poll_collectionView.frame.width)
            poll_num_label.text = "\(row+1)"
            poll_frame_height.constant = CGFloat(40*questions[row].answers!.count + 110)
        }
    }
}
