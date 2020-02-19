//
//  SignUpVC.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/13/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import FirebaseAuth
import FirebaseFirestore
//import FirebaseDatabase

class SignUpVC: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var name_text: UITextField!
    @IBOutlet weak var email_text: UITextField!
    @IBOutlet weak var pwd_text: UITextField!
    @IBOutlet weak var create_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    @IBAction func create_btn_click(_ sender: Any) {
        if name_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input your name.", "OK", {})
            return
        } else if email_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input your email.", "OK", {})
            return
        } else if !(email_text.text?.isValidEmailAddress())! {
            ShareData().doneAlert(ShareData.appTitle, "Invalid Email Address.", "OK", {})
            return
        } else if pwd_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input password.", "OK", {})
            return
        } else {
            createAccount()
        }
    }
    
    @IBAction func signinAction(_ sender: Any) {
        self.navigationController?.pushViewController(SignInVC(), animated: true)
    }
    
    func createAccount() {
        self.startAnimating(CGSize(width: 50, height: 50), message: "Creating Account...", type: ShareData.progressDlgs[29], color: .white, fadeInAnimation: nil)
        self.create_btn.isUserInteractionEnabled = false
        
        let name = name_text.text
        let email = email_text.text
        let password = pwd_text.text
        
        Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user, error) in
            
            self.create_btn.isUserInteractionEnabled = true
            
            if let error = error {
                self.stopAnimating(nil)
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        print("invalid")
                    case .emailAlreadyInUse:
                        ShareData().doneAlert(ShareData.appTitle, "Email duplicated.", "OK", {})
                    default:
                        ShareData().doneAlert(ShareData.appTitle, "Error: \(error.localizedDescription)", "OK", {})
                    }
                }
            } else {
                guard let uid = Auth.auth().currentUser?.uid else {return}
                print("uid \(uid)")
                var ref : DocumentReference? = nil
                ref = Firestore.firestore().collection("users").document(uid)
                let registerData : [String : Any] = ["uid": uid, "name": name!, "email": email!, "photo": "", "phone": "", "isPush": true, "isFacebook": true, "isInstagram": true, "isGmail": true]
                ref?.setData(registerData){ (error) in
                    self.stopAnimating(nil)
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        UserDefaults.standard.set(email, forKey: "savedEmail")
                        UserDefaults.standard.set(password, forKey: "savedPassword")
                        UserDefaults.standard.set(registerData, forKey: "userModel")
                        ShareData().disappearActionAlert(ShareData.appTitle, "Successfully Registered.", {
                            self.navigationController?.pushViewController(MainVC(), animated: true)
                        })
                    }
                }
            }
            
        })
    }
    
    func init_UI() {
        self.navigationController?.isNavigationBarHidden = true
        self.hideKeyboardWhenTappedAround()
        
        create_btn.layer.cornerRadius = 5
        create_btn.layer.masksToBounds = true
        
        email_text.layer.cornerRadius = 5
        pwd_text.layer.cornerRadius = 5
        name_text.layer.cornerRadius = 5
        
        email_text.delegate = self
        name_text.delegate = self
        pwd_text.delegate = self
        name_text.setLeftPaddingPoints(10)
        email_text.setLeftPaddingPoints(10)
        pwd_text.setLeftPaddingPoints(10)
    }
}
