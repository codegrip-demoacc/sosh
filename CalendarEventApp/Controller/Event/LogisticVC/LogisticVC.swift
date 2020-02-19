//
//  LogisticVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import FirebaseFirestore

class LogisticVC: UIViewController {
    
    @IBOutlet weak var arrive_tbl: UITableView!
    @IBOutlet weak var depart_tbl: UITableView!
    
    @IBOutlet var address_label: UILabel!
    
    var logisticView = LogisticView()
    
    var selectEvent = [String: Any]()
    var userModel = [String: Any]()
    var logistics = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectEvent = UserDefaults.standard.object(forKey: "selectEvent") as! [String : Any]
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        
        setupTableView()
        init_UI()
        read_logistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(addLogistic(_:)), name: .add_logistic, object: nil)
    }
    
    @objc func addLogistic(_ notification: Notification) {
        var dict = notification.userInfo as! [String: String]
        //add
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let timeString : String = formatter.string(from: Date())
        dict[activity.id] = timeString
        let ref = Firestore.firestore().collection("events").document(self.selectEvent[event.id] as! String)
        ref.collection("logistic").document(timeString).setData(dict) { (_ ) in
            self.logistics.append(dict)
            self.arrive_tbl.reloadData()
            self.depart_tbl.reloadData()
        }
    }
    
    @IBAction func arrive_plus_btn_click(_ sender: Any) {
        if self.userModel[user.uid] as! String == self.selectEvent[event.creator_id] as! String {
            //if i am creator of this event
            self.showLogisticView()
        } else {
            //if i am not creator of this event
            ShareData().doneAlert(ShareData.appTitle, "Logistics can be added only by creator of the event.", "OK", {})
        }
    }
    
    @IBAction func depart_plus_btn_click(_ sender: Any) {
        if self.userModel[user.uid] as! String == self.selectEvent[event.creator_id] as! String {
            //if i am creator of this event
            self.showLogisticView()
        } else {
            //if i am not creator of this event
            ShareData().doneAlert(ShareData.appTitle, "Logistics can be added by only creator of the event.", "OK", {})
        }
    }
    
    func showLogisticView() {
        self.logisticView = Bundle.main.loadNibNamed("LogisticView", owner: self, options: [:])?.first as! LogisticView
        self.logisticView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.logisticView)
    }
    
    func read_logistics() {
        let ref = Firestore.firestore().collection("events").document(selectEvent[event.id] as! String).collection("logistic")
        ref.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.logistics.removeAll()
                for doc in querySnapshot!.documents {
                    self.logistics.append(doc.data() as! [String: String])
                }
                self.arrive_tbl.reloadData()
                self.depart_tbl.reloadData()
            }
        }
    }
    
    func setupTableView(){
        arrive_tbl.delegate = self
        arrive_tbl.dataSource = self
        arrive_tbl.separatorStyle = .none
        arrive_tbl.rowHeight = 40
        arrive_tbl.register(UINib(nibName: "LogisticCell", bundle: nil), forCellReuseIdentifier: "LogisticCell")
        arrive_tbl.isScrollEnabled = true
        arrive_tbl.showsVerticalScrollIndicator = false
        arrive_tbl.reloadData()
        
        depart_tbl.delegate = self
        depart_tbl.dataSource = self
        depart_tbl.separatorStyle = .none
        depart_tbl.rowHeight = 40
        depart_tbl.register(UINib(nibName: "LogisticCell", bundle: nil), forCellReuseIdentifier: "LogisticCell")
        depart_tbl.isScrollEnabled = true
        depart_tbl.showsVerticalScrollIndicator = false
        depart_tbl.reloadData()
    }
    
    func init_UI() {
        self.address_label.text = self.selectEvent[event.location] as? String
    }
}

extension LogisticVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logistics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogisticCell") as! LogisticCell
        if tableView == arrive_tbl {
            cell.name_label.text = self.logistics[indexPath.row][logistic.lodging]
            cell.time_label.text = self.logistics[indexPath.row][logistic.arrive_date]!.monthAndDay() +  ", " + self.logistics[indexPath.row][logistic.arrive_time]!
            cell.detail_label.text = self.logistics[indexPath.row][logistic.arrive_method]
        } else {
            cell.name_label.text = self.logistics[indexPath.row][logistic.lodging]
            cell.time_label.text = self.logistics[indexPath.row][logistic.depart_date]!.monthAndDay() +  ", " + self.logistics[indexPath.row][logistic.depart_time]!
            cell.detail_label.text = self.logistics[indexPath.row][logistic.depart_method]
        }
        cell.selectionStyle = .none
        return cell
    }
}
