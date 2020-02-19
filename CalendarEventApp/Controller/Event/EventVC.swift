//
//  EventVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import NVActivityIndicatorView

class EventVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var photo_collectionView: UICollectionView!
    @IBOutlet var main_collectionView: UICollectionView!
    @IBOutlet var chat_badge_label: UILabel!
    
    @IBOutlet var yes_btn: UIButton!
    @IBOutlet var no_btn: UIButton!
    @IBOutlet var third_btn: UIButton!
    @IBOutlet var invite_btn: UIButton!
    
    @IBOutlet var event_name_label: UILabel!
    @IBOutlet var location_label: UILabel!
    @IBOutlet var start_date_label: UILabel!
    @IBOutlet var end_date_label: UILabel!
    @IBOutlet var start_date_day_label: UILabel!
    @IBOutlet var end_date_day_label: UILabel!
    @IBOutlet var description_text: UITextView!
    @IBOutlet var main_img: UIImageView!
    @IBOutlet var add_activity_btn: UIButton!
    
    var tableView: UITableView!
    var viewControllers: [UIViewController]!
    var vc: UIViewController!
    
    var selectedIndex: Int = -1
    
    var userModel = [String: Any]()
    var selectEvent = [String: Any]()
    var isCreator = false
    
    var yes_users = [FriendData]()
    var no_users = [FriendData]()
    var tbd_users = [FriendData]()
    var display_users = [FriendData]()
    var btn_status = 0
    
    var activities = [[String: String]]()
    var arrangedActivities = [[[String: String]]]()
    var activityView = ActivityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        selectEvent = UserDefaults.standard.object(forKey: "selectEvent") as! [String : Any]
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        
        viewControllers = [EventChatVC(), LogisticVC(), PhotoVC(), ExpenseVC()]
        setupCollectionView()
        setupTableView()
        
        if ShareData.isSelectEventChange {
            init_UI()
            read_activity()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(addActivity(_:)), name: .add_activity, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteActivity(_:)), name: .delete_activity, object: nil)
    }
    
    //main tab buttons
    @IBAction func buttonTapped(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        vc = viewControllers[selectedIndex]
        
        if sender.isSelected {
            let previousVC = viewControllers[sender.tag]
            previousVC.willMove(toParent: nil)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
            self.viewDidLoad()
        } else {
            if previousIndex != -1 {
                buttons[previousIndex].isSelected = false
                let previousVC = viewControllers[previousIndex]
                previousVC.willMove(toParent: nil)
                previousVC.view.removeFromSuperview()
                previousVC.removeFromParent()
            }
            addChild(vc)
            vc.view.frame = contentView.bounds
            contentView.addSubview(vc.view)
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func photo_collectionview_click(_ sender: Any) {
        buttons[2].isSelected = false
        buttonTapped(buttons[2])
    }
    
    @IBAction func calendar_btn_click(_ sender: Any) {
        ShareData.isSelectEventChange = true
        self.navigationController?.popViewController(animated: true)
    }
    
//-------------------- top buttons -----------------------------
    @IBAction func yes_btn_click(_ sender: Any) {
        display_users = yes_users
        if btn_status == 1 {
            yes_btn.removeUnderLine()
            btn_status = 0
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            yes_btn.underlineMyText()
            no_btn.removeUnderLine()
            third_btn.removeUnderLine()
            btn_status = 1
        }
        tableView.reloadData()
    }
    
    @IBAction func no_btn_click(_ sender: Any) {
        display_users = no_users
        if btn_status == 2 {
            no_btn.removeUnderLine()
            btn_status = 0
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            no_btn.underlineMyText()
            yes_btn.removeUnderLine()
            third_btn.removeUnderLine()
            btn_status = 2
        }
        tableView.reloadData()
    }
    
    @IBAction func third_btn_click(_ sender: Any) {
        display_users = tbd_users
        if btn_status == 3 {
            third_btn.removeUnderLine()
            btn_status = 0
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            third_btn.underlineMyText()
            no_btn.removeUnderLine()
            yes_btn.removeUnderLine()
            btn_status = 3
        }
        tableView.reloadData()
    }
    
    @IBAction func invite_btn_click(_ sender: Any) {
        display_users = ShareData.users
        if btn_status == 4 {
            btn_status = 0
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            yes_btn.removeUnderLine()
            no_btn.removeUnderLine()
            third_btn.removeUnderLine()
            btn_status = 4
        }
        tableView.reloadData()
    }
    
// ------------------ activity part -------------------------------
    @IBAction func add_activity_btn_click(_ sender: Any) {
        if !isCreator {
            return
        }
        ShareData().selectAlert(self.selectEvent[event.name] as! String, "There is no activity in this event. \n Please add activities.", 2, ["OK", "Not Now"], [.blue, .blue], [.white, .white], self, [#selector(showNewActivity(_:)), #selector(blankAction(_:))])
    }
    
    @objc func showNewActivity(_ sender: UIButton) {
        self.activityView = Bundle.main.loadNibNamed("ActivityView", owner: self, options: [:])?.first as! ActivityView
        self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.activityView.setValues(["":""], activityType.add)
            self.view.addSubview(self.activityView)
        }, completion: nil)
    }
    
    @objc func blankAction(_ sender: UIButton) {
        print("No Action")
    }
    
    @objc func addActivity(_ notification: Notification) {
        var dict = notification.userInfo as! [String: String]
        
        if dict[activity.id] == "" {
            //add newly
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let timeString : String = formatter.string(from: Date())
            dict[activity.id] = timeString
            let ref = Firestore.firestore().collection("events").document(self.selectEvent[event.id] as! String)
            ref.collection("activity").document(timeString).setData(dict) { (_ ) in
                self.activities.append(dict)
                self.rearrange_activities()
            }
        } else {
            //update
            let ref = Firestore.firestore().collection("events").document(self.selectEvent[event.id] as! String)
            ref.collection("activity").document(dict[activity.id]!).updateData([activity.name: dict[activity.name]!, activity.date: dict[activity.date]!, activity.time: dict[activity.time]!, activity.location: dict[activity.location]!, activity.description: dict[activity.description]!, activity.read: dict[activity.read]!, activity.status: dict[activity.status]!]){(error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("successfully updated")
                    self.activities = self.activities.filter { $0[activity.id] != dict[activity.id] }
                    self.activities.append(dict)
                    self.rearrange_activities()
                }
            }
        }
    }
    
    @objc func deleteActivity(_ notification: Notification) {
        var dict = notification.userInfo as! [String: String]
        //delete
        let ref = Firestore.firestore().collection("events").document(self.selectEvent[event.id] as! String).collection("activity").document(dict[activity.id]!)
        ref.delete()
        self.activities = self.activities.filter { $0[activity.id] != dict[activity.id] }
        self.rearrange_activities()
    }
    
// --------------- main collection add button or click cell --------------
    @objc func plus_btn_click(_ sender: UIButton) {
        if !isCreator {
            ShareData().doneAlert(ShareData.appTitle, "Activities can be added by only creator of the event.", "OK", {})
            return
        }
        print(sender.tag)
        self.activityView = Bundle.main.loadNibNamed("ActivityView", owner: self, options: [:])?.first as! ActivityView
        self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.activityView.setValues(["":""], activityType.add)
            self.view.addSubview(self.activityView)
        }, completion: nil)
    }
    
    func tableViewCellSelectHandler( collectionIndex: IndexPath, tableIndex: IndexPath) {
        if !isCreator {
            return
        }
        
        print(collectionIndex.row)
        print(tableIndex.section)
        self.activityView = Bundle.main.loadNibNamed("ActivityView", owner: self, options: [:])?.first as! ActivityView
        self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.activityView.setValues(self.arrangedActivities[collectionIndex.row][tableIndex.section], activityType.update)
            self.view.addSubview(self.activityView)
        }, completion: nil)
    }
    
// --------------------- initial read data --------------------
    func read_activity() {
        let ref = Firestore.firestore().collection("events").document(selectEvent[event.id] as! String).collection("activity")
        ref.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.activities.removeAll()
                for doc in querySnapshot!.documents {
                    self.activities.append(doc.data() as! [String: String])
                }
                self.rearrange_activities()
            }
        }
        
        //mark as read if i am not creator of this event.
        if selectEvent[event.creator_id] as! String != userModel[user.uid] as! String {
            let ref1 = Firestore.firestore().collection("events").document(selectEvent[event.id] as! String).collection("activity")
            ref1.getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    for doc in querySnapshot!.documents {
                        if !(doc.data()[activity.status] as! String).contains(self.userModel[user.uid] as! String) {
                            //add my uid to read users
                            var read_users = doc.data()[activity.status] as! String
                           read_users += " , " + (self.userModel[user.uid] as! String)
                            ref1.document(doc.documentID).updateData([activity.status:read_users])
                        }
                        
                    }
                }
            }
        }
    }
    
    func rearrange_activities() {
        if self.activities.count ==  0 {
            ShareData().doneAlert(ShareData.appTitle, "There is no activity.", "Done", {})
            self.add_activity_btn.isHidden = false
            return
        }
        self.add_activity_btn.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        activities = activities.sorted {
            guard let date1 = dateFormatter.date(from:$0["date"]!), let date2 = dateFormatter.date(from:$1["date"]!) else { return false}
            return date1 < date2
        }
        var firstArray = [[String: String]]()
        firstArray.append(activities[0])
        arrangedActivities.removeAll()
        let calendar = Calendar(identifier: .gregorian)
        for i in 1..<activities.count {
            let prevDate = dateFormatter.date(from: activities[i-1][activity.date]!)!
            let nextDate = dateFormatter.date(from: activities[i][activity.date]!)!
            if !calendar.isDate(prevDate, equalTo: nextDate, toGranularity: .day) {
                arrangedActivities.append(firstArray)
                firstArray.removeAll()
            }
            firstArray.append(activities[i])
        }
        if firstArray.count > 0 {
            arrangedActivities.append(firstArray)
            firstArray.removeAll()
        }
        self.main_collectionView.reloadData()
    }
    
    func setupCollectionView() {
        photo_collectionView.dataSource = self
        photo_collectionView.delegate = self
        photo_collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        photo_collectionView.showsHorizontalScrollIndicator = false
        
        main_collectionView.dataSource = self
        main_collectionView.delegate = self
        main_collectionView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellWithReuseIdentifier: "ActivityCell")
        photo_collectionView.showsVerticalScrollIndicator = false
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 150, width: self.contentView.frame.width, height: 240))
        tableView.register(UINib(nibName: "EventFriendCell", bundle: nil), forCellReuseIdentifier: "EventFriendCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 40
        tableView.separatorStyle = .none
        tableView.backgroundColor = .blue
        self.contentView.addSubview(tableView)
        tableView.isHidden = true
    }
    
    func init_UI() {
        
        if self.userModel[user.uid] as! String == self.selectEvent[event.creator_id] as! String {
            //if you are a creator of this event
            self.isCreator = true
        } else {
            //if you are not a creator of this event
            self.isCreator = false
        }
        
        var yes_user_num = Int()
        var no_user_num = Int()
        var tbd_user_num = Int()
        
        yes_user_num = (selectEvent[event.yes] as? Int)!
        no_user_num = (selectEvent[event.no] as? Int)!
        tbd_user_num = (selectEvent[event.tbd] as? Int)!
        
        self.event_name_label.text = selectEvent[event.name] as? String
        self.location_label.text = selectEvent[event.location] as? String
        self.start_date_label.text = (selectEvent[event.start_date] as? String)?.monthAndDay()
        self.start_date_day_label.text = (selectEvent[event.start_date] as? String)?.weekDay()
        self.end_date_label.text = (selectEvent[event.end_date] as? String)?.monthAndDay()
        self.end_date_day_label.text = (selectEvent[event.end_date] as? String)?.weekDay()
        self.description_text.text = selectEvent[event.description] as? String
        self.yes_btn.setTitle("Yes : \(yes_user_num)", for: .normal)
        self.no_btn.setTitle("No : \(no_user_num)", for: .normal)
        self.third_btn.setTitle("??? : \(tbd_user_num)", for: .normal)
        
        let photo = (selectEvent[event.photos] as! [String])[0]
        let url = URL(string: photo)
        let processor = DownsamplingImageProcessor(size: main_img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 0)
        main_img.kf.indicatorType = .activity
        main_img.kf.setImage(with: url, placeholder: UIImage(named: "sky"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
        
        if yes_user_num == 0 && no_user_num == 0 && tbd_user_num == 0 {
            // no invited users
            print("No invited user")
        } else {
            // get invited users
            self.startAnimating(CGSize(width: 50, height: 50), message: "Loading...", type: ShareData.progressDlgs[23], color: .white, fadeInAnimation: nil)
            self.yes_users.removeAll()
            self.no_users.removeAll()
            self.tbd_users.removeAll()
            let ref = Firestore.firestore().collection("events").document(selectEvent[event.id] as! String).collection("invite_list")
            ref.getDocuments() { (querySnapshot,_) in
                for doc in querySnapshot!.documents {
                    switch doc.data()["status"] as! Int {
                    case 0:
                        self.tbd_users.append(FriendData(uid: doc.data()["uid"] as? String, photo: doc.data()["photo"] as? String, name: doc.data()["name"] as? String))
                    case 1:
                        self.yes_users.append(FriendData(uid: doc.data()["uid"] as? String, photo: doc.data()["photo"] as? String, name: doc.data()["name"] as? String))
                    case -1:
                        self.no_users.append(FriendData(uid: doc.data()["uid"] as? String, photo: doc.data()["photo"] as? String, name: doc.data()["name"] as? String))
                    default:
                        break;
                    }
                }
                self.stopAnimating(nil)
            }
        }
        self.photo_collectionView.reloadData()
        
        ShareData.isSelectEventChange = false
        
        chat_badge_label.layer.cornerRadius = chat_badge_label.layer.frame.height/2
        chat_badge_label.clipsToBounds = true
    }
}

extension EventVC: UICollectionViewDelegate, UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photo_collectionView {
            return (selectEvent[event.photos] as! [String]).count-1
        } else {
            return arrangedActivities.count
        }
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
        
        if collectionView == photo_collectionView {
            return CGSize(width: collectionView.frame.height/2, height: collectionView.frame.height/2)
        } else {
            var height = CGFloat()
            height = CGFloat(50*self.arrangedActivities[indexPath.row].count + 40)
            return CGSize(width: collectionView.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photo_collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            cell.plus_view.alpha = 0
            cell.mask_view.alpha = 0
            cell.name_label.alpha = 0
            
            let photo = (selectEvent[event.photos] as! [String])[indexPath.row+1]
            let url = URL(string: photo)
            let processor = DownsamplingImageProcessor(size: cell.img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 0)
            cell.img.kf.indicatorType = .activity
            cell.img.kf.setImage(with: url, placeholder: UIImage(named: "sky"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
            cell.tableView_height.constant = CGFloat(50*(arrangedActivities[indexPath.row].count))
            cell.contain_width.constant = collectionView.frame.size.width
            cell.date_label.text = arrangedActivities[indexPath.row][0][activity.date]?.fullWeekday_month_day()
            cell.details = arrangedActivities[indexPath.row]
            
            cell.plus_btn.tag = indexPath.row
            cell.plus_btn.addTarget(self, action: #selector(self.plus_btn_click), for: .touchUpInside)
            
            cell.selectCellHandler = { ( _ subIndexPath: IndexPath) -> Void in
                self.tableViewCellSelectHandler(collectionIndex: indexPath, tableIndex: subIndexPath)
            }
            
            return cell
        }
    }
}

extension EventVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return display_users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "EventFriendCell") as! EventFriendCell
        cell.name_label.text = display_users[indexPath.row].name
        
        let photo = display_users[indexPath.row].photo!
        let url = URL(string: photo)
        let processor = DownsamplingImageProcessor(size: cell.photo_img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 15)
        cell.photo_img.kf.indicatorType = .activity
        cell.photo_img.kf.setImage(with: url, placeholder: UIImage(named: "non_profile"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.tableView.isHidden = true
    }
}
