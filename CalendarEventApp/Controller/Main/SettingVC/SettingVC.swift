//
//  SettingVC.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/7/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView
import Kingfisher

class SettingVC: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var photo_btn: UIButton!
    @IBOutlet var photo_img: UIImageView!
    @IBOutlet var name_text: UITextField!
    @IBOutlet var email_text: UITextField!
    @IBOutlet var phone_text: UITextField!
    @IBOutlet var push_switch: UISwitch!
    @IBOutlet var facebook_switch: UISwitch!
    @IBOutlet var instagram_switch: UISwitch!
    @IBOutlet var gmail_switch: UISwitch!
    
    var userModel = [String: Any]()
    
    var email = String()
    var name = String()
    var phone = String()
    var isPush = true
    var isFacebook = true
    var isInstagram = true
    var isGmail = true
    var isPhotoChange = false
    var isDataChange = false
    var photo = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        init_UI()
    }
    
// -------------- textfields -------------------
    func setupTextFields() {
        name_text.delegate = self
        email_text.delegate = self
        phone_text.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save_btn_click(_ sender: Any) {
        if name == self.name_text.text && email == self.email_text.text && phone == self.phone_text.text && isPush == push_switch.isOn && isFacebook == facebook_switch.isOn && isInstagram == instagram_switch.isOn && isGmail == gmail_switch.isOn && !isPhotoChange{
            return
        }
        
        if self.name_text.text != userModel[user.name] as? String{
            isDataChange = true
            userModel[user.name] = self.name_text.text!
        }
        
        if self.email_text.text != userModel[user.email] as? String {
            isDataChange = true
            userModel[user.email] = self.email_text.text!
        }
        
        if self.phone_text.text != userModel[user.phone] as? String {
            isDataChange = true
            userModel[user.phone] = self.phone_text.text!
        }
        
        if self.push_switch.isOn != userModel[user.isPush] as? Bool {
            isDataChange = true
            userModel[user.isPush] = self.push_switch.isOn
        }
        
        if self.facebook_switch.isOn != userModel[user.isFacebook] as? Bool {
            isDataChange = true
            userModel[user.isFacebook] = self.facebook_switch.isOn
        }
        
        if self.instagram_switch.isOn != userModel[user.isInstagram] as? Bool {
            isDataChange = true
            userModel[user.isInstagram] = self.instagram_switch.isOn
        }
        
        if self.gmail_switch.isOn != userModel[user.isGmail] as? Bool {
            isDataChange = true
            userModel[user.isGmail] = self.gmail_switch.isOn
        }
        
        if isPhotoChange {
            self.startAnimating(CGSize(width: 50, height: 50), message: "Uploading Image....",  type: ShareData.progressDlgs[23],  fadeInAnimation: nil)
            let imageName = userModel[user.uid] as! String + ".png"
            let storageImg = Storage.storage().reference().child("images").child(imageName)
            if let uploadData = self.photo.pngData()
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
                                    Firestore.firestore().collection("users").document(self.userModel[user.uid] as! String).updateData([user.photo : urlText]){ (error) in
                                        if let error = error {
                                            print("Error adding document: \(error)")
                                            self.stopAnimating(nil)
                                        } else {
                                            print("Document added ")
                                            ShareData().disappearAlert("Sucessfully saved.")
                                            self.stopAnimating(nil)
                                        }
                                    }
                                }
                            }
                        })
                        self.isPhotoChange = false
                        self.stopAnimating(nil)
                    }
                })
            }
            
            //update saved in requests
            let ref = Firestore.firestore().collection("requests")
            ref.getDocuments{(querySnapshot, err) in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    for doc in querySnapshot!.documents {
                        if doc.data()["sent_id"] as! String == self.userModel[user.uid] as! String {
                            ref.document(doc.documentID).updateData(["sent_photo": self.userModel[user.photo] as! String]) { _ in
                                print("successfully updated photo")
                            }
                        } else if doc.data()["received_id"] as! String == self.userModel[user.uid] as! String {
                            ref.document(doc.documentID).updateData(["received_photo": self.userModel[user.photo] as! String]) { _ in
                                print("successfully updated photo")
                            }
                        }
                    }
                }
            }
            
            //update saved in event lists
            let ref1 = Firestore.firestore().collection("events")
            ref1.getDocuments{(querySnapshot, err) in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    for doc in querySnapshot!.documents {
                        ref1.document(doc.documentID).collection("invite_list").getDocuments{(query, _) in
                            for doc1 in query!.documents {
                                if doc1.documentID == self.userModel[user.uid] as! String {
                                    ref1.document(doc.documentID).collection("invite_list").document(doc1.documentID).updateData(["photo": self.userModel[user.photo] as! String]){ _ in
                                        print("successfully updated photo")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if isDataChange {
            self.startAnimating(CGSize(width: 50, height: 50), message: "Uploading Data....",  type: ShareData.progressDlgs[23],  fadeInAnimation: nil)
            Firestore.firestore().collection("users").document(self.userModel[user.uid] as! String).updateData(self.userModel){ (error) in
                if !self.isPhotoChange {self.stopAnimating(nil)}
                if let error = error {
                    print("Error adding document: \(error)")
                    self.stopAnimating(nil)
                } else {
                    self.isDataChange = false
                    if !self.isPhotoChange {
                        ShareData().disappearAlert("Successfully saved.")
                    }
                }
            }
        }
        UserDefaults.standard.removeObject(forKey: "userModel")
        UserDefaults.standard.set(self.userModel, forKey: "userModel")
    }
    
    @IBAction func photo_btn_click(_ sender: Any) {
        let alertController = UIAlertController.init(title: "\(ShareData.appTitle)", message: "Select your photo.", preferredStyle: .actionSheet)
        
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
    
    @IBAction func logout_btn_click(_ sender: Any) {
        ShareData().selectAlert(ShareData.appTitle, "Are you sure to logout?", 2, ["OK", "Cancel"], [.blue, .blue], [.white, .white], self, [#selector(logoutAction(_:)), #selector(blankAction(_:))])
    }
    
    @objc func logoutAction(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "userModel")
        ShareData.isEventChange = true
        ShareData.isFriendChange = true
        ShareData.isSelectEventChange = true
        self.navigationController?.pushViewController(SignInVC(), animated: true)
    }
    
    @objc func blankAction(_ sender: UIButton) {
        print("No Action")
    }
    
    func init_UI() {
        self.navigationController?.isNavigationBarHidden = true
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        
        if let photo_url = userModel[user.photo] as? String{
            let url = URL(string: photo_url)
            let processor = DownsamplingImageProcessor(size: photo_img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 70)
            photo_img.kf.indicatorType = .activity
            photo_img.kf.setImage(with: url, placeholder: UIImage(named: "photo_add"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
        }
        
        if let name = userModel[user.name] as? String {
            self.name_text.text = name
        }
        if let email = userModel[user.email] as? String {
            self.email_text.text = email
        }
        if let phone = userModel[user.phone] as? String {
            self.phone_text.text = phone
        }
        if let isPush = userModel[user.isPush] as? Bool {
            self.push_switch.isOn = isPush
        }
        if let isFacebook = userModel[user.isFacebook] as? Bool {
            self.facebook_switch.isOn = isFacebook
        }
        if let isInstagram = userModel[user.isInstagram] as? Bool {
            self.instagram_switch.isOn = isInstagram
        }
        if let isGmail = userModel[user.isGmail] as? Bool {
            self.gmail_switch.isOn = isGmail
        }
    }
}

extension SettingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            let img = chosenImage.cropImage(width: 140, height: 140)
            photo_img.image = img
            photo_img.layer.cornerRadius = photo_img.layer.frame.height/2
            photo_img.layer.masksToBounds = true
            self.photo = img
            self.isPhotoChange = true
            dismiss(animated:true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
