//
//  MainVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/24/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import NVActivityIndicatorView
import JTAppleCalendar
import EventKit
import CalendarLib

class MainVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var bottom_frame: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekViewStack: UIStackView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var noti_badge_label: UILabel!
    @IBOutlet var monthPlannerView: MGCMonthPlannerView!
    
    var viewControllers: [UIViewController]!
    var vc: UIViewController!
    
    var selectedIndex: Int = -1
    var userModel = [String: Any]()
    
    let formatter = DateFormatter()
    let today = Date()
    var dictionary = [String: [String]]()
    var curent = String()
    var names = [String]()
    var dates = [String]()
    var overlap = 1
    var x = 0
    var Indexes = [String: Int]()
    var y = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [FriendsVC(), MainChatVC(), CreateEventVC(), EventListVC()]
        
        init_UI()
        read_users()
        read_events()
        setupCalendar()
        display_event()
    }
    
    // tab bar buttons
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
    
    @IBAction func setting_btn_click(_ sender: Any) {
        self.navigationController?.pushViewController(SettingVC(), animated: true)
    }
    
    @IBAction func noti_btn_click(_ sender: Any) {
        self.navigationController?.pushViewController(NotificationVC(), animated: true)
    }
    
    func setupCalendar() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.scrollToDate(Date()) // scroll to today

        calendarView.calendarDataSource = self
        calendarView.ibCalendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.ibCalendarDelegate = self
        calendarView.register(UINib(nibName: "CalendarCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CalendarCell")
        
        monthPlannerView.delegate = self
        monthPlannerView.dataSource = self
        monthPlannerView.scroll(to: Date(), animated: false)
        monthPlannerView.dayCellHeaderHeight = 15
        monthPlannerView.rowHeight = monthPlannerView.layer.frame.height/5
        monthPlannerView.headerHeight = 0
        monthPlannerView.weekDaysStringArray = ["Mon","Tue","Wed","Thu","Fri","Sat"]
        monthPlannerView.pagingMode = .headerTop
        monthPlannerView.monthHeaderStyle = .hidden
        monthPlannerView.monthInsets = UIEdgeInsets.zero
        monthPlannerView.style = .events
    }
    
    func display_event() {
        
    } 
    
    func init_UI() {
        self.navigationController?.isNavigationBarHidden = true
        
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        
        noti_badge_label.layer.cornerRadius = noti_badge_label.layer.frame.height/2
        noti_badge_label.layer.masksToBounds = true
    }
    
    func eventsAtDate(date: Date) -> [[String: Any]] {
        formatter.dateFormat = "MM/dd/yyyy"
        var events = [[String: Any]]()
        for item in ShareData.events {
            let start_date = formatter.date(from: item[event.start_date] as! String)
            let end_date = formatter.date(from: item[event.start_date] as! String)
            if !(date.compare(start_date!) == .orderedAscending) && !(date.compare(end_date!) == .orderedDescending) {
                 events.append(item)
            }
        }
        return events
    }
    
    func eventAtIndex(index: UInt, date: Date) -> [String: Any] {
        let events = self.eventsAtDate(date: date)
        return events[Int(index)]
    }
}

extension MainVC: MGCMonthPlannerViewDelegate, MGCMonthPlannerViewDataSource {
    func monthPlannerView(_ view: MGCMonthPlannerView!, numberOfEventsAt date: Date!) -> Int {
        
        var count = 0
        if self.eventsAtDate(date: date).count != 0 {
            count = self.eventsAtDate(date: date).count
        }
        return count
    }
    
    func monthPlannerView(_ view: MGCMonthPlannerView!, dateRangeForEventAt index: UInt, date: Date!) -> MGCDateRange! {
        
        formatter.dateFormat = "MM/dd/yyyy"
        let events = self.eventsAtDate(date: date)
        let event :[String: Any]? = events[Int(index)]
        var range : MGCDateRange? = nil
        range = MGCDateRange(start: formatter.date(from: (event!["start_date"] as! String)), end: formatter.date(from: (event!["end_date"] as! String)))
        
        return range
    }
    
    func monthPlannerView(_ view: MGCMonthPlannerView!, cellForEventAt index: UInt, date: Date!) -> MGCEventView! {
        let currentEvent = self.eventAtIndex(index: index, date: date)
        let eventView = MGCStandardEventView()
        eventView.font = UIFont.systemFont(ofSize: 10)
        eventView.title = currentEvent["creator_name"] as? String
//        eventView.subtitle = currentEvent["creator_name"] as? String
        if currentEvent["creator_id"] as! String == self.userModel[user.uid] as! String {
            eventView.title = currentEvent["name"] as? String
            eventView.color = ShareData.main_back_green
        } else {
            eventView.color = ShareData.main_back_blue
            eventView.title = currentEvent["creator_name"] as? String
        }
        
        eventView.style = [MGCStandardEventViewStyle.plain,MGCStandardEventViewStyle.subtitle]
        return eventView
    }
    
    func monthPlannerViewDidScroll(_ view: MGCMonthPlannerView!) {
        formatter.dateFormat = "MM/dd/yyyy"
        var date = monthPlannerView.day(at: self.view.center)
        if date == nil {date = Date()}
        let month = (formatter.string(from: date!)).monthAndyear()
        self.monthLabel.text = month
    }
    
    func monthPlannerView(_ view: MGCMonthPlannerView!, didSelectEventAt index: UInt, date: Date!) {
        let currentEvent = self.eventAtIndex(index: index, date: date)
        ShareData().doneAlert(ShareData.appTitle, currentEvent[event.name] as! String, "OK", {})
    }
    
    func monthPlannerView(_ view: MGCMonthPlannerView!, attributedStringForDayHeaderAt date: Date!) -> NSAttributedString! {
        formatter.dateFormat = "d"
        let dayStr = formatter.string(from: date)
        let str = dayStr
        let font = UIFont.systemFont(ofSize: 10)
        let attrStr = NSMutableAttributedString(string: str, attributes: [ NSAttributedString.Key.font: font ])
        let para = NSMutableParagraphStyle()
        para.alignment = NSTextAlignment.center
        para.tailIndent = -6
        attrStr.addAttributes([NSAttributedString.Key.paragraphStyle: para], range: NSMakeRange(0, attrStr.length))
        return attrStr
    }
}
 
extension MainVC: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2018 03 01")!
        let endDate = formatter.date(from: "2020 12 01")!
        let firstDayOfWeek: DaysOfWeek = .monday
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate,  firstDayOfWeek: firstDayOfWeek)
        
        return parameters 
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        cell.dayLabel.text = cellState.text
        cell.dayLabel.textColor = UIColor.darkGray
        cell.tableView.isHidden = true
        
        formatter.dateFormat = "MM/dd/yyyy"
        
        let myDate = formatter.string(from: date)
        for item in names{
            if dictionary[item]![0] == myDate{
                cell.tableView.isHidden = false
                cell.tableView.delegate = self
                cell.tableView.dataSource = self
                cell.tableView.register(UINib(nibName: "DayCell", bundle: Bundle.main), forCellReuseIdentifier: "DayCell")
                cell.tableView.separatorStyle = .none
                cell.tableView.tag = x
                x += 1
            }
        }
        x = 0
        
        if cellState.dateBelongsTo == .thisMonth {
            cell.dayLabel.textColor = UIColor.darkGray
        } else {
            cell.dayLabel.textColor = UIColor.lightGray
        }
        
        if cellState.isSelected{
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
        
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        if cellState.dateBelongsTo != .thisMonth{
            return
        }
        validCell.selectedView.isHidden = false
        validCell.selectedView.layer.cornerRadius = validCell.selectedView.layer.frame.height/2
        validCell.selectedView.backgroundColor = UIColor.red
        validCell.dayLabel.textColor = UIColor.white
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        validCell.selectedView.isHidden = true
        validCell.dayLabel.textColor = UIColor.darkGray
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "MMMM yyyy"
        self.monthLabel.text = self.formatter.string(from: date)
        self.calendarView.reloadData()
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return names.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath) as! DayCell
        formatter.dateFormat = "MM/dd/yyyy"

        if indexPath.section == Indexes[names[tableView.tag]]! - 1{
            cell.name_label.text = names[tableView.tag]
            if let constraint = (cell.name_label.constraints.filter{$0.firstAttribute == .width}.first) {
                constraint.constant = CGFloat(60 * CGFloat(dictionary[names[tableView.tag]]!.count))
            }
        }else{
            if Indexes[names[tableView.tag]]! > 1 && indexPath.section == 0{
                cell.name_label.isHidden = true

            } else {
                cell.isHidden = true
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
}

//read users

extension MainVC {
    func read_users() {
        if ShareData.isFriendChange {
            //get all users
            self.startAnimating(CGSize(width: 50, height: 50), message: "Loading...", type: ShareData.progressDlgs[23], color: .white, fadeInAnimation: nil)
            ShareData.users.removeAll()
            ShareData.wait_users.removeAll()
            ShareData.me_wait_users.removeAll()
            ShareData.friends.removeAll()
            let ref = Firestore.firestore().collection("users")
            ref.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)");
                } else {
                    for document in querySnapshot!.documents {
                        if document.documentID != self.userModel[user.uid] as? String {
                            ShareData.users.append(FriendData(uid: document.documentID, photo: document.data()["photo"] as? String, name: document.data()["name"] as? String))
                        }
                    }
                }
            }
            
            //get friends and waiting users
            let ref1 = Firestore.firestore().collection("requests")
            ref1.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)");
                } else {
                    for document in querySnapshot!.documents {
                        if document.data()["received_id"] as! String == self.userModel[user.uid] as! String  {
                            switch document.data()["status"] as! Int {
                            case 0:
                                print("user who u didn't reply yet")
                                ShareData.me_wait_users.append(FriendData(uid: document.data()["sent_id"] as? String, photo: document.data()["sent_photo"] as? String, name: document.data()["sent_name"] as? String))
                            case 1:
                                print("friend")
                                ShareData.friends.append(FriendData(uid: document.data()["sent_id"] as? String, photo: document.data()["sent_photo"] as? String, name: document.data()["sent_name"] as? String))
                            case -1:
                                print("rejected friend request user")
                            case 2:
                                print("user that sent unfriend request to u")
                            default:
                                break
                            }
                        } else if document.data()["sent_id"] as! String == self.userModel[user.uid] as! String {
                            switch document.data()["status"] as! Int {
                            case 0:
                                print("waiting acceptance user")
                                ShareData.wait_users.append(FriendData(uid: document.data()["received_id"] as? String, photo: document.data()["received_photo"] as? String, name: document.data()["received_name"] as? String))
                            case 1:
                                print("friend")
                                ShareData.friends.append(FriendData(uid: document.data()["received_id"] as? String, photo: document.data()["received_photo"] as? String, name: document.data()["received_name"] as? String))
                            case -1:
                                print("rejected friend request user")
                            case 2:
                                print("user who u sent unfriend request")
                            default:
                                break
                            }
                        }
                    }
                }
                self.stopAnimating(nil)
                ShareData.isFriendChange = false
            }
        }
    }
}

// read events
extension MainVC {
    func read_events() {
        if !ShareData.isEventChange {
            return
        }
        
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
                    DispatchQueue.main.async {
                        self.setupCalendar()
                        self.monthPlannerView.reloadEvents()
//                        self.calendarView.reloadData()
                    }
                }
            }
        }
    }
    
    func rearrange_events() {
        if ShareData.events.count == 0 {
            ShareData().doneAlert(ShareData.appTitle, "There is no events to show.", "Done", {})
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
    }
}
