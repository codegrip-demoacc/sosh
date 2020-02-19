//
//  CreateEventVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView

class CreateEventVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var name_text: UITextField!
    @IBOutlet var start_date_text: UITextField!
    @IBOutlet var start_time_text: UITextField!
    @IBOutlet weak var end_date_text: UITextField!
    @IBOutlet var end_time_text: UITextField!
    @IBOutlet var location_text: UITextField!
    @IBOutlet var invite_list_text: UITextField!
    @IBOutlet var description_textView: UITextView!
    @IBOutlet var private_btn: UIButton!
    @IBOutlet var public_btn: UIButton!
    @IBOutlet var btn_view: UIView!
    @IBOutlet var scroll_bottom_con: NSLayoutConstraint!
    
    var startDatePicker: UIDatePicker!
    var endDatePicker: UIDatePicker!
    var startTimePicker: UIDatePicker!
    var endTiemPicker: UIDatePicker!
    
    var image: UIImage? = nil
    var isPrivate = false
    
    var userModel = [String: Any]()
    var userView = UserView()
    var invitedList = [String]()
    
    override func viewDidLoad() {
        
        setupTextFields()
        formatDatePicker()
        init_UI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(setInviteList(_:)), name: .invite_list, object: nil)
    }
    
    @objc func setInviteList(_ notification: Notification) {
        var inviteText = String()
        for item in ShareData.selected_users {
            invitedList.append(item.uid!)
            inviteText += item.name! + " , "
        }
        if ShareData.selected_users.count > 0 {
            inviteText = inviteText.substring(to: inviteText.count-3)
        }
        self.invite_list_text.text = inviteText
    }
    
//-------------- text field && text view -------------------
    func setupTextFields() {
        name_text.delegate = self
        start_date_text.delegate = self
        start_time_text.delegate = self
        end_date_text.delegate = self
        end_time_text.delegate = self
        location_text.delegate = self
        invite_list_text.delegate = self
        description_textView.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scroll_bottom_con.constant = 60
        if textField == invite_list_text {
            self.view.endEditing(true)
            self.userView = Bundle.main.loadNibNamed("UserView", owner: self, options: [:])?.first as! UserView
            self.userView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            
            UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.userView.clipsToBounds = true
                self.view.addSubview(self.userView)
            }, completion: nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.scroll_bottom_con.constant = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.scroll_bottom_con.constant = 0
        self.view.endEditing(true)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if description_textView.text == " Description(Optional)" {
            description_textView.text = ""
            description_textView.textColor = .black
        }
        self.scroll_bottom_con.constant = 60
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if description_textView.text == "" {
            description_textView.text = " Description(Optional)"
            description_textView.textColor = .lightGray
        }
        self.scroll_bottom_con.constant = 0
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.scroll_bottom_con.constant = 0
            return false
        }
        return true
    }
    
    //---------------- date picker -------------------------
    func formatDatePicker(){
        startDatePicker = UIDatePicker()
        startDatePicker?.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(self.startDateChanged(datePicker:)), for: .valueChanged)
        start_date_text.inputView = startDatePicker
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        endDatePicker = UIDatePicker()
        endDatePicker?.datePickerMode = .date
        endDatePicker.addTarget(self, action: #selector(self.endDateChanged(datePicker:)), for: .valueChanged)
        end_date_text.inputView = endDatePicker
        let endtapGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        view.addGestureRecognizer(endtapGesture)
        view.addGestureRecognizer(tapGesture)
        
        startTimePicker = UIDatePicker()
        startTimePicker?.datePickerMode = .time
        startTimePicker.addTarget(self, action: #selector(self.startTimeChanged(datePicker:)), for: .valueChanged)
        start_time_text.inputView = startTimePicker
        let startTimetapGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        endTiemPicker = UIDatePicker()
        endTiemPicker?.datePickerMode = .time
        endTiemPicker.addTarget(self, action: #selector(self.endTimeChanged(datePicker:)), for: .valueChanged)
        end_time_text.inputView = endTiemPicker
        let endTimeGesture = UITapGestureRecognizer(target:self, action: #selector(self.viewTapped(gestureRecognize:)))
        
        view.addGestureRecognizer(startTimetapGesture)
        view.addGestureRecognizer(endTimeGesture)
    }
    
    @objc func viewTapped(gestureRecognize: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func startDateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        start_date_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func endDateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        end_date_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func startTimeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        start_time_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func endTimeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        end_time_text.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func private_btn_click(_ sender: Any) {
        private_btn.backgroundColor = .lightGray
        public_btn.backgroundColor = .clear
        private_btn.setTitleColor(.white, for: .normal)
        public_btn.setTitleColor(.lightGray, for: .normal)
        
        isPrivate = true
    }
    
    @IBAction func public_btn_click(_ sender: Any) {
        private_btn.backgroundColor = .clear
        public_btn.backgroundColor = .lightGray
        private_btn.setTitleColor(.lightGray, for: .normal)
        public_btn.setTitleColor(.white, for: .normal)
        
        isPrivate = false
    }
    
    @IBAction func publish_btn_click(_ sender: Any) {
        
        if self.name_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input Event name.", "OK", {})
            return
        } else if start_date_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input Start Date of this event..", "OK", {})
            return
        } else if end_date_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "EPlease input End Date of this event.", "OK", {})
            return
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let start_date = dateFormatter.date(from: self.start_date_text.text!)
            let end_date = dateFormatter.date(from: self.end_date_text.text!)
            
            if end_date?.compare(start_date!) == .orderedAscending {
                print("end date is smaller then start date")
                ShareData().doneAlert(ShareData.appTitle, "Start date can't be later than end date.", "OK", {})
                return
            } else if image == nil {
//                ShareData().doneAlert(ShareData.appTitle, "Please take main photo of this event.", "OK", {})
//                return
            } else {
               publishAction()
            }
        }
    }
    
    func publishAction() {
        self.startAnimating(CGSize(width: 50, height: 50), message: "Creating Event...", type: ShareData.progressDlgs[23], color: .white, fadeInAnimation: nil)
        let name = self.name_text.text
        let startDate = self.start_date_text.text
        let start_date_time = self.start_time_text.text
        let endDate = self.end_date_text.text
        let end_date_time = self.end_time_text.text
        let location = self.location_text.text
        var description = self.description_textView.text
        if description == " Description(Optional)" {description = ""}
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let timeString : String = formatter.string(from: Date())
        
        var ref : DocumentReference? = nil
        ref = Firestore.firestore().collection("events").document(userModel[user.uid] as! String + "_" + timeString)
        
        self.startAnimating(CGSize(width: 50, height: 50), message: "Saving....",  type: ShareData.progressDlgs[23],  fadeInAnimation: nil)
        let imageName = userModel[user.uid] as! String + "_" + timeString + ".png"
        let storageImg = Storage.storage().reference().child("images").child(imageName)
        
        if let uploadData = self.image!.pngData()
        {
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            storageImg.putData(uploadData, metadata: metaData, completion: { (metadata, error) in
                if let err = error {
                    self.stopAnimating(nil)
                    ShareData().doneAlert(ShareData.appTitle, err.localizedDescription, "OK", {})
                } else {
                    storageImg.downloadURL(completion: { (url, error) in
                        if error != nil{
                            print(error!)
                            return
                        } else {
                            if let urlText = url?.absoluteString {
                                self.userModel[user.photo] = urlText
                                let registerData : [String: Any] = ["id":(self.userModel[user.uid] as! String + "_" + timeString),"creator_id":self.userModel[user.uid] as! String,"creator_name":self.userModel[user.name] as! String,"creator_photo":self.userModel[user.photo] as! String,"name":name!,"location":location!,"description":description!,"isPrivate":self.isPrivate,"start_date":startDate!,"start_date_time":start_date_time!,"end_date":endDate!,"end_date_time":end_date_time!,"photos": [urlText], "photo_names":[self.userModel[user.name] as! String],"yes":0,"no":0,"tbd":ShareData.selected_users.count,"invite_users":self.invite_list_text.text!,"accepted_users":""]
                                
                                for item in ShareData.selected_users {
                                    var inviteData = [String: Any]()
                                    inviteData = ["uid": item.uid!, "name": item.name!,"photo": item.photo!, "status": 0, "read": false]
                                    ref?.collection("invite_list").document(item.uid!).setData(inviteData){ (error) in
                                        if let error = error {
                                            print("Error adding document: \(error)")
                                        } else {
                                            print("invite collection added")
                                        }
                                    }
                                }
                                
                                ref?.setData(registerData){ (error) in
                                    self.stopAnimating(nil)
                                    if let error = error {
                                        print("Error adding document: \(error)")
                                    } else {
                                        ShareData().disappearAlert("Successfully saved.")
                                        ShareData.isEventChange = true
                                        self.formatFields()
                                    }
                                }
                            }
                        }
                    })
                    self.stopAnimating(nil)
                }
            })
        }
    }
    
    func formatFields() {
        self.name_text.text = ""
        self.start_date_text.text = ""
        self.start_time_text.text = ""
        self.end_date_text.text = ""
        self.end_time_text.text = ""
        self.location_text.text = ""
        self.invite_list_text.text = ""
        ShareData.selected_users.removeAll()
        self.description_textView.text = " Description(Optional)"
        self.description_textView.textColor = .lightGray
        self.image = nil
    }
    
    @IBAction func camera_btn_click(_ sender: Any) {
        let alertController = UIAlertController.init(title: "\(ShareData.appTitle)", message: "Select Event Image", preferredStyle: .actionSheet)
        
        let imageAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.ImageFromCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.ImageFromGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        alertController.addAction(imageAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func init_UI() {
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        
        name_text.setLeftPaddingPoints(10)
        name_text.layer.borderWidth = 1
        name_text.layer.borderColor = UIColor.lightGray.cgColor
        
        start_date_text.setLeftPaddingPoints(10)
        start_date_text.layer.borderWidth = 1
        start_date_text.layer.borderColor = UIColor.lightGray.cgColor
        
        start_time_text.setLeftPaddingPoints(10)
        start_time_text.layer.borderWidth = 1
        start_time_text.layer.borderColor = UIColor.lightGray.cgColor
        
        end_date_text.setLeftPaddingPoints(10)
        end_date_text.layer.borderWidth = 1
        end_date_text.layer.borderColor = UIColor.lightGray.cgColor
        
        end_time_text.setLeftPaddingPoints(10)
        end_time_text.layer.borderWidth = 1
        end_time_text.layer.borderColor = UIColor.lightGray.cgColor
        
        location_text.setLeftPaddingPoints(10)
        location_text.layer.borderWidth = 1
        location_text.layer.borderColor = UIColor.lightGray.cgColor
        
        invite_list_text.setLeftPaddingPoints(10)
        invite_list_text.layer.borderWidth = 1
        invite_list_text.layer.borderColor = UIColor.lightGray.cgColor
        
        description_textView.layer.borderColor = UIColor.lightGray.cgColor
        description_textView.layer.borderWidth = 1
        
        private_btn.layer.cornerRadius = 5
        private_btn.clipsToBounds = true
        public_btn.layer.cornerRadius = 5
        public_btn.clipsToBounds = true
        
        private_btn.backgroundColor = .clear
        public_btn.backgroundColor = .lightGray
        private_btn.setTitleColor(.lightGray, for: .normal)
        public_btn.setTitleColor(.white, for: .normal)
        
        btn_view.layer.cornerRadius = 5
        btn_view.backgroundColor = .white
    }
}

extension CreateEventVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func ImageFromGallary()
    {
        let picker = UIImagePickerController.init()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.navigationBar.tintColor = UIColor.white
        picker.navigationBar.barTintColor = UIColor.gray
        present(picker, animated: true, completion: nil)
    }
    
    func ImageFromCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))   {
            let picker = UIImagePickerController.init()
            picker.allowsEditing = true
            picker.delegate = self
            
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            picker.navigationBar.tintColor = UIColor.white
            picker.navigationBar.barTintColor = UIColor.gray
            present(picker, animated: true, completion: nil)
        } else {
            ShareData().doneAlert(ShareData.appTitle, "You don't have a camera.", "OK", {})
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.originalImage] as? UIImage{
            let img = chosenImage.cropImage(width: 100, height: 100)
            self.image = img
            dismiss(animated:true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
