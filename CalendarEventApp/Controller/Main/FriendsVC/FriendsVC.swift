//
//  FriendsVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher
import NVActivityIndicatorView
import Contacts
import MessageUI

class FriendsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var main_frame: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
 
    var userModel = [String: Any]()
    var index = Int()
    var contactView = ContactView()
    
    override func viewDidLoad() {
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(send_email(_:)), name: .send_email, object: nil)
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FriendCell", bundle: nil), forCellWithReuseIdentifier: "FriendCell")
    }
    
    func get_contacts() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied || status == .restricted {
            presentSettingsActionSheet()
            return
        }
        // open it
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    self.presentSettingsActionSheet()
                }
                return
            }
            // get the contacts
            var contacts = [CNContact]()
            let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey as NSString, CNContactEmailAddressesKey as CNKeyDescriptor, CNContactThumbnailImageDataKey as CNKeyDescriptor, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    contacts.append(contact)
                }
            } catch {
                print(error)
            }
            
            // do something with the contacts array (e.g. print the names)
            let formatter = CNContactFormatter()
            formatter.style = .fullName
            ShareData.contacts.removeAll()
            for contact in contacts {
                print(formatter.string(from: contact) ?? "???")
                let name = formatter.string(from: contact) ?? "???"
                var emails = [String]()
                for i in 0..<contact.emailAddresses.count {
                    emails.append(contact.emailAddresses[i].value as String)
                }
                var photo = Data()
                if contact.isKeyAvailable(CNContactImageDataKey) {
                    if let img = contact.imageData {
                        photo = img
                    }
                }
                ShareData.contacts.append(ContactData(name: name, emails: emails, photo: photo))
            }
            
            self.contactView = Bundle.main.loadNibNamed("ContactView", owner: self, options: [:])?.first as! ContactView
            self.contactView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            
            UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.view.addSubview(self.contactView)
            }, completion: nil)
        }
    }
    
    func presentSettingsActionSheet() {
        let alert = UIAlertController(title: "Permission to Contacts", message: "This app needs access to contacts in order to ...", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
   
    @objc func send_email(_ notification: Notification) {
        let dict = notification.userInfo as! [String: [String]]
        self.sendEmail(dict["emails"]!)
    }
    
//    {"personalizations": [
//    {
//    "to": [
//    {"email": "rstcom929@gmail.com"}
//    ]
//    }],
//    "from": {"email": "rstcom919@gmail.com"},
//    "subject": "Sosh app is very useful.",
//    "content" : [{"type": "text/plain", "value": "Please use this app."}]
//    }
    
    func sendEmail(_ emails: [String]) {
        let url = URL(string: "https://api.sendgrid.com/v3/mail/send")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var toEmails = [[String: String]]()
        for email in emails {
            toEmails.append(["email": email])
        }

        let parameter = ["personalizations": ["to": ["email": emails[0]]], "from": ["email": "sunpooh920@gmail.com"], "subject": "Sosh", "content": ["type": "text/plain", "value": "Sosh app is very useful for events. Please use this app."]] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
        } catch let error {
            print(error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + ShareData.send_grid_key, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {  return }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject> {
                    print(json)
                }
            } catch let error {
                print(error)
            }
        })
        task.resume()
    }
    
//------------------ requests -------------------------
    func friendRequest(_ indexPath: IndexPath) {

        self.startAnimating(CGSize(width: 50, height: 50), message: "Sending...", type: ShareData.progressDlgs[23], color: .white, fadeInAnimation: nil)
        let docId = self.userModel[user.uid] as! String + ShareData.users[indexPath.row-1].uid!
        
        var ref: DocumentReference? = nil
        ref = Firestore.firestore().collection("requests").document(docId)
        let registerData : [String: Any] = ["sent_id": self.userModel[user.uid] as! String, "sent_name": self.userModel[user.name] as! String, "sent_photo": self.userModel[user.photo] as! String, "received_id": ShareData.users[indexPath.row-1].uid!, "received_name": ShareData.users[indexPath.row-1].name!, "received_photo": ShareData.users[indexPath.row-1].photo!, "status": 0, "read": false]
        ref?.setData(registerData) { (error) in
            self.stopAnimating(nil)
            if let error = error {
                print(error.localizedDescription)
            } else {
                ShareData().disappearAlert("Successfully sent friend request to \(ShareData.users[indexPath.row-1].name!).")
                ShareData.wait_users.append(ShareData.users[indexPath.row-1])
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func acceptFriendRequest(_ sender: UIButton) {
        let docId = ShareData.users[index].uid! + (self.userModel[user.uid] as! String)
        let ref = Firestore.firestore().collection("requests").document(docId)
        ref.updateData(["status": 1, "read": true]){(error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                ShareData.friends.append(ShareData.users[self.index])
                ShareData.me_wait_users = ShareData.me_wait_users.filter { $0.uid != ShareData.users[self.index].uid }
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func rejectFriendRequest(_ sender: UIButton) {
        let docId = ShareData.users[index].uid! + (self.userModel[user.uid] as! String)
        let ref = Firestore.firestore().collection("requests").document(docId)
        ref.updateData(["status": -1, "read": true]){(error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                ShareData.me_wait_users = ShareData.me_wait_users.filter { $0.uid != ShareData.users[self.index].uid }
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func skipFriendRequest(_ sender: UIButton) {
        let docId = ShareData.users[index].uid! + (self.userModel[user.uid] as! String)
        let ref = Firestore.firestore().collection("requests").document(docId)
        ref.updateData(["read": true]){(error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("read friend request but skipped.")
            }
        }
    }
    
    @objc func cancelRequest(_ sender: UIButton) {
        let docId = self.userModel[user.uid] as! String + ShareData.users[index].uid!
        Firestore.firestore().collection("requests").document(docId).delete()
        ShareData.wait_users = ShareData.wait_users.filter { $0.uid != ShareData.users[index].uid }
        self.collectionView.reloadData()
    }
    
    @objc func blankAction(_ sender: UIButton) {
        print("No Action")
    }
    
    @objc func unfriendRequest(_ sender: UIButton) {
        let sentDocId = self.userModel[user.uid] as! String + ShareData.users[index].uid!
        let receivedDocId = ShareData.users[index].uid! + (self.userModel[user.uid] as! String)
        let ref = Firestore.firestore().collection("requests")
        ref.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                for doc in querySnapshot!.documents {
                    if doc.documentID == sentDocId {
                        //friend that u sent friend request
                        ref.document(sentDocId).updateData(["status": 2, "read": false]) { _ in
                            print("successfully updated status to unfriend")
                            ShareData.friends = ShareData.friends.filter { $0.uid != ShareData.users[self.index].uid }
                            self.collectionView.reloadData()
                        }
                    } else if doc.documentID == receivedDocId {
                        //friend that u accepted his friend request
                        ref.document(receivedDocId).delete()
                        
                        let registerData : [String: Any] = ["sent_id": self.userModel[user.uid] as! String, "sent_name": self.userModel[user.name] as! String, "sent_photo": self.userModel[user.photo] as! String, "received_id": ShareData.users[self.index].uid!, "received_name": ShareData.users[self.index].name!, "received_photo": ShareData.users[self.index].photo!, "status": 2, "read": false]
                        ref.document(sentDocId).setData(registerData) { (error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                ShareData.friends = ShareData.friends.filter { $0.uid != ShareData.users[self.index].uid }
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension FriendsVC {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShareData.users.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  20
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
        
        if indexPath.row == 0 {
            cell.name = ""
            cell.border_color = .white
        } else {
            cell.name = ShareData.users[indexPath.row-1].name!
            if let photo_url = ShareData.users[indexPath.row-1].photo {
                let url = URL(string: photo_url)
                let processor = DownsamplingImageProcessor(size: cell.img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 25)
                cell.img.kf.indicatorType = .activity
                cell.img.kf.setImage(with: url, placeholder: UIImage(named: "non_profile"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
            }
            
            // check user type
            if ShareData.wait_users.contains(where: { $0.uid == ShareData.users[indexPath.row-1].uid }) {
                //waiting user
                cell.img.alpha = 0.6
                cell.border_color = .blue
            } else if ShareData.me_wait_users.contains(where: { $0.uid == ShareData.users[indexPath.row-1].uid }) {
                //waiting user that u didn't reply yet
                cell.img.alpha = 0.6
                cell.border_color = .red
            } else if ShareData.friends.contains(where: { $0.uid == ShareData.users[indexPath.row-1].uid }) {
                //friend
                cell.img.alpha = 0.6
                cell.border_color = .white
            } else {
                //normal user
                cell.img.alpha = 1
                cell.border_color = .white
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            get_contacts()
            return
        }
        
        index = indexPath.row - 1
        // check user type
        if ShareData.wait_users.contains(where: { $0.uid == ShareData.users[indexPath.row-1].uid }) {
            //waiting user
            
            ShareData().selectAlert(ShareData.users[index].name!, "\(ShareData.users[index].name!) did not reply for your friend request. \n Do you want to cancel friend request?", 2, ["OK", "Cancel"], [.blue, .blue], [.white, .white], self, [#selector(cancelRequest(_:)), #selector(blankAction(_:))])
        } else if ShareData.me_wait_users.contains(where: { $0.uid == ShareData.users[indexPath.row-1].uid }) {
            //waiting user who u didn't reply yet
            
            ShareData().selectAlert(ShareData.users[index].name!, "You did not reply for \(ShareData.users[index].name!)'s friend request.\n Do you want to accept friend request?", 3, ["Accept", "Reject", "Not Now"], [.blue, .red, .blue], [.white, .white, .white], self, [#selector(acceptFriendRequest(_:)), #selector(rejectFriendRequest(_:)), #selector(skipFriendRequest(_:))])
            
        } else if ShareData.friends.contains(where: { $0.uid == ShareData.users[indexPath.row-1].uid }) {
            //friend
            ShareData().selectAlert(ShareData.users[index].name!, "Are you sure to unfriend with \(ShareData.users[indexPath.row-1].name!)?", 2, ["OK", "Cancel"], [.blue, .blue], [.white, .white], self, [#selector(unfriendRequest(_:)), #selector(blankAction(_:))])
            
        } else {
            //normal user
            self.friendRequest(indexPath)
        }
    }
}
