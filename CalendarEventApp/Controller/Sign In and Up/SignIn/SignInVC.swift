//
//  SignInVC.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/13/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit

class SignInVC: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var email_text: UITextField!
    @IBOutlet weak var pwd_text: UITextField!
    @IBOutlet weak var signin_btn: UIButton!
    
    let fbLoginManager : LoginManager = LoginManager()
    
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
    
    @IBAction func signin_btn_click(_ sender: Any) {
        if self.email_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input your email.", "OK", {})
            return
        } else if self.pwd_text.text == "" {
            ShareData().doneAlert(ShareData.appTitle, "Please input password.", "OK", {})
            return
        } else {
            signInAction()
        }
    }
    
    @IBAction func signupAction(_ sender: Any) {
        self.navigationController?.pushViewController(SignUpVC(), animated: true)
    }
    
    @IBAction func signin_google(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signin_facebook(_ sender: Any) {
        
        var fb_email = String()
        
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil) {
                let fbloginresult : LoginManagerLoginResult = result!
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    if((AccessToken.current) != nil){
                        GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                            if (error == nil){
                                if let dict:[String:Any] = result as? [String : Any] {
                                    
                                    let result =  dict as NSDictionary
                                    let picURL = ((result.value(forKey: "picture") as! NSDictionary).value(forKey: "data") as! NSDictionary).value(forKey: "url") as! String
                                    let fb_password = result.value(forKey: "id") as! String
                                    let first_name = result.value(forKey: "first_name") as! String
                                    let last_name = result.value(forKey: "last_name") as! String
                                    if let email = result.value(forKey: "email") {
                                        fb_email = email as! String
                                    } else {
                                        fb_email = "\(first_name)1019@outlook.com"
                                    }
                                    let name = "\(first_name) \(last_name)"
                                }
                            }
                        })
                    }
                }
                 self.startAnimating(CGSize(width: 50, height: 50), message: "Facebook Sign In...", type: ShareData.progressDlgs[29], color: .white, fadeInAnimation: nil)
                
                Firestore.firestore().collection("users").getDocuments() {(querySnapshot, err) in
                    self.stopAnimating(nil)
                    if let err = err {
                        print("Error getting documents: \(err)");
                    } else {
                        var isInvalid = true
                        for document in querySnapshot!.documents {
                            if document.data()["email"] as? String == fb_email {
                                isInvalid = false
                                UserDefaults.standard.set(document.data(), forKey: "userModel")
                                ShareData().disappearActionAlert(ShareData.appTitle, "Successfully Sign In.", {
                                    self.navigationController?.pushViewController(MainVC(), animated: true)
                                })
                            }
                        }
                        if isInvalid {
                            ShareData().doneAlert(ShareData.appTitle, "You did not register yet. \n Please sign up.", "OK", {})
                        }
                    }
                }
                
//                let credential = FacebookAuthProvider.credential(withAccessToken:  AccessToken.current!.tokenString)
//
//                Auth.auth().signIn(with: credential) { (authResult, error) in
//                    if let error = error {
//                        ShareData().selfVCAlert(message: error.localizedDescription, org: self)
//                        return
//                    }
//                    // User is signed in
//                Firestore.firestore().collection("users").document(credential.provider).getDocument { (document, error) in
//
//                        if let document = document, document.exists {
//                            print(document.data()!)
//                        self.navigationController?.pushViewController(MainVC(), animated: true)
//                        } else {
//                            ShareData().selfVCAlert(message: "You did not register yet. \n Please sign up.", org: self)
//                        }
//                    }
//                }
                
                //sign out
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
            } else {
                ShareData().doneAlert(ShareData.appTitle, error!.localizedDescription, "OK", {})
            }
        }
    }
    
    func signInAction() {
        self.startAnimating(CGSize(width: 50, height: 50), message: "Sign In...", type: ShareData.progressDlgs[29], color: .white, fadeInAnimation: nil)
        self.signin_btn.isUserInteractionEnabled = false
        
        let email = email_text.text
        let pwd = pwd_text.text
//        let credential = EmailAuthProvider.credential(withEmail: email!, password: pwd!)
        
        Auth.auth().signIn(withEmail: email!, password: pwd!, completion: { (user , error) in
            self.signin_btn.isUserInteractionEnabled = true
            
            if error != nil {
                self.stopAnimating(nil)
                ShareData().doneAlert(ShareData.appTitle, error!.localizedDescription, "OK", {})
            } else {
                guard let uid = Auth.auth().currentUser?.uid else {return}
               
               print("uid \(uid)")
                Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
                    self.stopAnimating(nil)
                    if let document = document, document.exists {
                        print(document.data()!)
                        UserDefaults.standard.set(email, forKey: "savedEmail")
                        UserDefaults.standard.set(pwd, forKey: "savedPassword")
                        UserDefaults.standard.set(document.data(), forKey: "userModel")
                        ShareData().disappearActionAlert(ShareData.appTitle, "Successfully Sign In.", {
                            self.navigationController?.pushViewController(MainVC(), animated: true)
                        })
                    } else {
                        ShareData().doneAlert(ShareData.appTitle, "Invalid User.", "OK", {})
                    }
                }
            }
        })
    }
    
    func init_UI() {
        self.navigationController?.isNavigationBarHidden = true
        self.hideKeyboardWhenTappedAround()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        
        signin_btn.layer.cornerRadius = 5
        signin_btn.layer.masksToBounds = true
        
        email_text.delegate = self
        pwd_text.delegate = self
        email_text.setLeftPaddingPoints(10)
        email_text.layer.cornerRadius = 5
        pwd_text.layer.cornerRadius = 5
        pwd_text.setLeftPaddingPoints(10)
        
        if UserDefaults.standard.object(forKey: "savedEmail") != nil {
            email_text.text = UserDefaults.standard.string(forKey: "savedEmail")
            pwd_text.text = UserDefaults.standard.string(forKey: "savedPassword")
        }
    }
}

extension SignInVC: GIDSignInUIDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            Initialize(user: user)
        }
    }
    
    func Initialize(user: GIDGoogleUser!){
        self.startAnimating(CGSize(width: 50, height: 50), message: "Google Sign In...", type: ShareData.progressDlgs[29], color: .white, fadeInAnimation: nil)
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            self.stopAnimating(nil)
            if let error = error {
                ShareData().doneAlert(ShareData.appTitle, error.localizedDescription, "OK", {})
                return
            }
            //signin successfully
            Firestore.firestore().collection("users").getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)");
                } else {
                    var isInvalid = true
                    for document in querySnapshot!.documents {
                        if document.data()["email"] as? String == user.profile.email {
                            isInvalid = false
                            UserDefaults.standard.set(document.data(), forKey: "userModel")
                            ShareData().disappearActionAlert(ShareData.appTitle, "Successfully Sign In.", {
                                self.navigationController?.pushViewController(MainVC(), animated: true)
                            })
                        }
                    }
                    if isInvalid {
                        ShareData().doneAlert(ShareData.appTitle, "You did not register yet. \n Please sign up.", "OK", {})
                    }
                }
            }
            //sign out
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
}
