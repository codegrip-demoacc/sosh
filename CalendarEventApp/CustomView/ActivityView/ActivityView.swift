//
//  ActivityView.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/20/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class ActivityView: UIView, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var title_label: UILabel!
    @IBOutlet var name_text: UITextField!
    @IBOutlet var date_text: UITextField!
    @IBOutlet var time_text: UITextField!
    @IBOutlet var location_text: UITextField!
    @IBOutlet var description_textView: UITextView!
    @IBOutlet var scrollView_bottom_con: NSLayoutConstraint!
    
    var datePicker: UIDatePicker!
    var timePicker: UIDatePicker!
    
    var selectEvent = [String: Any]()
    var type = String()
    var temp = [String: String]()
    
    override func awakeFromNib() {
        
        selectEvent = UserDefaults.standard.object(forKey: "selectEvent") as! [String : Any]
        setupTextFields()
        formatDatePicker()
        init_UI()
    }
    
    func setValues(_ dict: [String: String], _ type: String) {
        self.type = type
        switch type {
        case activityType.add:
            self.title_label.text = "New Activity"
        case activityType.update:
            self.temp = dict
            self.title_label.text = "Activity"
            self.name_text.text = dict[activity.name]
            self.date_text.text = dict[activity.date]
            self.time_text.text = dict[activity.time]
            self.location_text.text = dict[activity.location]
            if dict[activity.description] != "" {
                self.description_textView.text = dict[activity.description]
                self.description_textView.textColor = .black
            }
        default:
            break;
        }
    }
    
//--------------- text field & text view ----------------
    func setupTextFields() {
        name_text.delegate = self
        date_text.delegate = self
        time_text.delegate = self
        location_text.delegate = self
        description_textView.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView_bottom_con.constant = 80
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.scrollView_bottom_con.constant = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.scrollView_bottom_con.constant = 0
        self.endEditing(true)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if description_textView.text == " Description(Optional)" {
            description_textView.text = ""
            description_textView.textColor = .black
        }
        self.scrollView_bottom_con.constant = 80
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if description_textView.text == "" {
            description_textView.text = " Description(Optional)"
            description_textView.textColor = .lightGray
        }
        self.scrollView_bottom_con.constant = 0
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.scrollView_bottom_con.constant = 0
            return false
        }
        return true
    }
    
// ------------------- date picker -------------------
    func formatDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        date_text.inputView = datePicker
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(self.timeChanged(datePicker:)), for: .valueChanged)
        time_text.inputView = timePicker
        let timeTapGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(timeTapGesture)
    }
    
    @objc func viewTapped(gestureRecognize: UITapGestureRecognizer){
        self.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        date_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func timeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        time_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func blankTouchAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func publish_btn_click(_ sender: Any) {
        if self.name_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input name of activity.", "OK", {})
            return
        } else if self.date_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input date of activity.", "OK", {})
            return
        } else if self.time_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input time of activity.", "OK", {})
            return
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let start_date = dateFormatter.date(from: selectEvent[event.start_date] as! String)
            let end_date = dateFormatter.date(from: selectEvent[event.end_date] as! String)
            let select_date = dateFormatter.date(from: self.date_text.text!)
            
            if select_date?.compare(start_date!) == .orderedAscending {
                print("select date is smaller then start date")
                ShareData().doneAlert(ShareData.appTitle, "Activity date can't be first than start date of event. \n This event starts at \((selectEvent[event.start_date] as! String).fullFormat()).", "OK", {})
                return
            } else if select_date?.compare(end_date!) == .orderedDescending {
                print("select Date is greater then end date")
                ShareData().doneAlert(ShareData.appTitle, "Activity date can't be later than end date of event. \n This event ends at \((selectEvent[event.end_date] as! String).fullFormat()).", "OK", {})
                return
            } else {
                publishAction()
            }
        }
    }
    
    func publishAction() {
        var dict = [String: String]()
        if self.type == activityType.update {
            //update
            dict[activity.id] = self.temp[activity.id]
        } else {
            //add newly
            dict[activity.id] = ""
        }
        dict[activity.status] = ""
        dict[activity.read] = ""
        dict[activity.name] = self.name_text.text
        dict[activity.date] = self.date_text.text
        dict[activity.time] = self.time_text.text
        dict[activity.location] = self.location_text.text
        
        if description_textView.text == " Description(Optional)" {
            dict[activity.description] = ""
        } else {
            dict[activity.description] = self.description_textView.text
        }
        
        NotificationCenter.default.post(name: .add_activity, object: nil, userInfo: dict)
        self.removeFromSuperview()
    }
    
    @IBAction func delete_btn_click(_ sender: Any) {
        
        if self.type == activityType.update {
            ShareData().selectAlert(self.temp[activity.name]!, "Are you sure to delete this activity?", 2, ["Delete", "Cancel"], [.red, .blue], [.white, .white], self, [#selector(deleteAction(_:)), #selector(blankAction(_:))])
        } else {
            // when adding
            print("No action")
        }
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        var dict = [String: String]()
        dict[activity.id] = self.temp[activity.id]
        NotificationCenter.default.post(name: .delete_activity, object: nil, userInfo: dict)
        self.removeFromSuperview()
    }
    
    @objc func blankAction(_ sender: UIButton) {
        print("No Action")
    }
    
    func init_UI() {
        name_text.setLeftPaddingPoints(10)
        name_text.layer.borderWidth = 1
        name_text.layer.borderColor = UIColor.lightGray.cgColor
        
        date_text.setLeftPaddingPoints(10)
        date_text.layer.borderWidth = 1
        date_text.layer.borderColor = UIColor.lightGray.cgColor
        
        time_text.setLeftPaddingPoints(10)
        time_text.layer.borderWidth = 1
        time_text.layer.borderColor = UIColor.lightGray.cgColor
        
        location_text.setLeftPaddingPoints(10)
        location_text.layer.borderWidth = 1
        location_text.layer.borderColor = UIColor.lightGray.cgColor
        
        description_textView.layer.borderColor = UIColor.lightGray.cgColor
        description_textView.layer.borderWidth = 1
    }
}
