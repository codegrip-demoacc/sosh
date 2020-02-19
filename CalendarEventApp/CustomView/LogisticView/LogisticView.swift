//
//  LogisticView.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/26/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class LogisticView: UIView, UITextFieldDelegate {
    @IBOutlet var name_label: UILabel!
    @IBOutlet var arrive_date_text: UITextField!
    @IBOutlet var arrive_time_text: UITextField!
    @IBOutlet var arrive_way_text: UITextField!
    @IBOutlet var arrive_comment_text: UITextField!
    
    @IBOutlet var depart_date_text: UITextField!
    @IBOutlet var depart_time_text: UITextField!
    @IBOutlet var depart_way_text: UITextField!
    @IBOutlet var depart_comment_text: UITextField!
    @IBOutlet var lodging_text: UITextField!
    
    var arrive_datePicker : UIDatePicker!
    var arrive_timePicker: UIDatePicker!
    var depart_datePicker : UIDatePicker!
    var depart_timePicker: UIDatePicker!
    
    var selectEvent = [String: Any]()
    
    override func awakeFromNib() {
        selectEvent = UserDefaults.standard.object(forKey: "selectEvent") as! [String : Any]
        init_UI()
        setupTextFields()
        formatDatePicker()
    }
    
    
    func publishAction() {
        
        var dict = [String: String]()
        dict[logistic.arrive_date] = self.arrive_date_text.text!
        dict[logistic.arrive_time] = self.arrive_time_text.text!
        dict[logistic.arrive_method] = self.arrive_way_text.text!
        dict[logistic.arrive_comment] = self.arrive_comment_text.text
        dict[logistic.depart_date] = self.depart_date_text.text!
        dict[logistic.depart_time] = self.depart_time_text.text!
        dict[logistic.depart_method] = self.depart_way_text.text!
        dict[logistic.depart_comment] = self.depart_comment_text.text
        dict[logistic.lodging] = self.lodging_text.text!
        
        NotificationCenter.default.post(name: .add_logistic, object: nil, userInfo: dict)
        self.removeFromSuperview()
    }
    
    @IBAction func publish_btn_click(_ sender: Any) {
        if self.arrive_date_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input arrive date.", "OK", {})
            return
        } else if self.arrive_time_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input arrive time.", "OK", {})
            return
        } else if self.arrive_way_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input arriving method.", "OK", {})
            return
        } else if self.depart_date_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input depart date.", "OK", {})
            return
        } else if self.depart_time_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input depart time.", "OK", {})
            return
        } else if self.depart_way_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input departing method.", "OK", {})
            return
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let start_date = dateFormatter.date(from: selectEvent[event.start_date] as! String)
            let end_date = dateFormatter.date(from: selectEvent[event.end_date] as! String)
            let arrive_date = dateFormatter.date(from: self.arrive_date_text.text!)
            let depart_date = dateFormatter.date(from: self.depart_date_text.text!)
            
            if depart_date?.compare(start_date!) == .orderedAscending {
                print("depart date is smaller than start date")
                ShareData().doneAlert(ShareData.appTitle, "Depart date can't be first than start date of event. \n This event starts at \((selectEvent[event.start_date] as! String).fullFormat()).", "OK", {})
                return
            } else if depart_date?.compare(end_date!) == .orderedDescending {
                print("depart Date is greater than end date")
                ShareData().doneAlert(ShareData.appTitle, "Depart date can't be later than end date of event. \n This event ends at \((selectEvent[event.end_date] as! String).fullFormat()).", "OK", {})
                return
            } else if arrive_date?.compare(start_date!) == .orderedAscending {
                print("arrive date is smaller than start date")
                ShareData().doneAlert(ShareData.appTitle, "Arrive date can't be first than start date of event. \n This event starts at \((selectEvent[event.start_date] as! String).fullFormat()).", "OK", {})
                return
            } else if arrive_date?.compare(end_date!) == .orderedDescending {
                print("depart Date is greater than end date")
                ShareData().doneAlert(ShareData.appTitle, "Arrive date can't be later than end date of event. \n This event ends at \((selectEvent[event.end_date] as! String).fullFormat()).", "OK", {})
                return
            } else if arrive_date?.compare(depart_date!) == .orderedAscending {
                print("arrive date is first than depart date")
                ShareData().doneAlert(ShareData.appTitle, "Arrive date can't be first than depart date.", "OK", {})
                return
            } else if arrive_date == depart_date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let arrive_time = dateFormatter.date(from: self.arrive_time_text.text!)
                let depart_time = dateFormatter.date(from: self.depart_time_text.text!)
                    if arrive_time?.compare(depart_time!) == .orderedAscending {
                        print("arrive time is later than depart time.")
                        ShareData().doneAlert(ShareData.appTitle, "Arrive time can't be first than depart time.", "OK", {})
                        return
                    }
            }
        }
        publishAction()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func blankTouchAction(_ sender: Any) {
        self.removeFromSuperview()
    }

// ------------------ text fields --------------------
    func setupTextFields() {
        self.arrive_date_text.delegate = self
        self.arrive_time_text.delegate = self
        self.arrive_way_text.delegate = self
        self.arrive_comment_text.delegate = self
        self.depart_date_text.delegate = self
        self.depart_time_text.delegate = self
        self.depart_way_text.delegate = self
        self.depart_comment_text.delegate = self
        self.lodging_text.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
// ------------------- date picker -------------------
    func formatDatePicker() {
        arrive_datePicker = UIDatePicker()
        arrive_datePicker.datePickerMode = .date
        arrive_datePicker.addTarget(self, action: #selector(self.arriveDateChanged(datePicker:)), for: .valueChanged)
        arrive_date_text.inputView = arrive_datePicker
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        arrive_timePicker = UIDatePicker()
        arrive_timePicker.datePickerMode = .time
        arrive_timePicker.addTarget(self, action: #selector(self.arriveTimeChanged(datePicker:)), for: .valueChanged)
        arrive_time_text.inputView = arrive_timePicker
        let timeTapGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        depart_datePicker = UIDatePicker()
        depart_datePicker.datePickerMode = .date
        depart_datePicker.addTarget(self, action: #selector(self.departDateChanged(datePicker:)), for: .valueChanged)
        depart_date_text.inputView = depart_datePicker
        let tapDepartGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        depart_timePicker = UIDatePicker()
        depart_timePicker.datePickerMode = .time
        depart_timePicker.addTarget(self, action: #selector(self.departTimeChanged(datePicker:)), for: .valueChanged)
        depart_time_text.inputView = depart_timePicker
        let timeTapDepartGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(timeTapGesture)
        self.addGestureRecognizer(tapDepartGesture)
        self.addGestureRecognizer(timeTapDepartGesture)
    }
    
    @objc func viewTapped(gestureRecognize: UITapGestureRecognizer){
        self.endEditing(true)
    }
    
    @objc func arriveDateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        arrive_date_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func arriveTimeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        arrive_time_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func departDateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        depart_date_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func departTimeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        depart_time_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    func init_UI() {
        arrive_date_text.setLeftPaddingPoints(10)
        arrive_date_text.layer.borderWidth = 1
        arrive_date_text.layer.borderColor = UIColor.lightGray.cgColor
        
        arrive_time_text.setLeftPaddingPoints(10)
        arrive_time_text.layer.borderWidth = 1
        arrive_time_text.layer.borderColor = UIColor.lightGray.cgColor
        
        arrive_way_text.setLeftPaddingPoints(10)
        arrive_way_text.layer.borderWidth = 1
        arrive_way_text.layer.borderColor = UIColor.lightGray.cgColor
        
        arrive_comment_text.setLeftPaddingPoints(10)
        arrive_comment_text.layer.borderWidth = 1
        arrive_comment_text.layer.borderColor = UIColor.lightGray.cgColor
        
        depart_date_text.setLeftPaddingPoints(10)
        arrive_comment_text.layer.borderWidth = 1
        arrive_comment_text.layer.borderColor = UIColor.lightGray.cgColor
        
        depart_time_text.setLeftPaddingPoints(10)
        depart_time_text.layer.borderWidth = 1
        depart_time_text.layer.borderColor = UIColor.lightGray.cgColor
        
        depart_way_text.setLeftPaddingPoints(10)
        depart_way_text.layer.borderWidth = 1
        depart_way_text.layer.borderColor = UIColor.lightGray.cgColor
        
        depart_comment_text.setLeftPaddingPoints(10)
        depart_comment_text.layer.borderWidth = 1
        depart_comment_text.layer.borderColor = UIColor.lightGray.cgColor
        
        lodging_text.setLeftPaddingPoints(10)
        lodging_text.layer.borderWidth = 1
        lodging_text.layer.borderColor = UIColor.lightGray.cgColor
    }
}
