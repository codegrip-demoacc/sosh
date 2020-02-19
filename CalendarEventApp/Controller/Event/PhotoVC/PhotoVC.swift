//
//  PhotoVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView

class PhotoVC: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet var header_img: UIImageView!
    @IBOutlet var name_label: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var preview_img: UIImageView!
    @IBOutlet var preview_name_label: UILabel!
    
    var selectEvent = [String: Any]()
    var userModel = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
        setupCollectionView()
    }
    
    @IBAction func facebook_btn_click(_ sender: Any) {
    }
    
    @IBAction func instagram_btn_click(_ sender: Any) {
    }
    
    @objc func previewImgTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            self.preview_img.isHidden = true
            self.preview_name_label.isHidden = true
        }
    }
    
    func add_new_photo() {
        let alertController = UIAlertController.init(title: "\(ShareData.appTitle)", message: "Take New Image", preferredStyle: .actionSheet)
        
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
    
    func upload_new_photo(img: UIImage) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let timeString : String = formatter.string(from: Date())
        
        var ref : DocumentReference? = nil
        ref = Firestore.firestore().collection("events").document(selectEvent[event.id] as! String)
        
        self.startAnimating(CGSize(width: 50, height: 50), message: "Saving....",  type: ShareData.progressDlgs[23],  fadeInAnimation: nil)
        let imageName = userModel[user.uid] as! String + "_" + timeString + ".png"
        let storageImg = Storage.storage().reference().child("images").child(imageName)
        
        if let uploadData = img.pngData()
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
                                var updatePhotos = self.selectEvent[event.photos] as! [String]
                                updatePhotos.append(urlText)
                                var updateNames = self.selectEvent[event.photo_names] as! [String]
                                updateNames.append(self.userModel[user.name] as! String)
                                ref!.updateData([event.photos : updatePhotos, event.photo_names: updateNames]) {(error) in
                                    if let error = error {
                                        self.stopAnimating(nil)
                                        print(error.localizedDescription)
                                    } else {
                                        self.stopAnimating(nil)
                                        self.selectEvent[event.photos] = updatePhotos
                                        self.selectEvent[event.photo_names] = updateNames
                                        UserDefaults.standard.removeObject(forKey: "selectEvent")
                                        UserDefaults.standard.set(self.selectEvent, forKey: "selectEvent")
                                        ShareData.isEventChange = true
                                        ShareData.isSelectEventChange = true
                                        self.collectionView.reloadData()
                                    }
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionView.showsVerticalScrollIndicator = false
    }
    
    func init_UI() {
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]
        selectEvent = UserDefaults.standard.object(forKey: "selectEvent") as! [String : Any]
        
        name_label.text = (selectEvent[event.photo_names] as! [String])[0]
        //header image
        let photo = (selectEvent[event.photos] as! [String])[0]
        let url = URL(string: photo)
        let processor = DownsamplingImageProcessor(size: header_img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 0)
        header_img.kf.indicatorType = .activity
        header_img.kf.setImage(with: url, placeholder: UIImage(named: "sky"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
        
        preview_img.isHidden = true
        preview_name_label.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.previewImgTapped(gesture:)))
        preview_img.addGestureRecognizer(tapGesture)
        preview_img.isUserInteractionEnabled = true
    }
    
    
}

extension PhotoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (selectEvent[event.photos] as! [String]).count
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
        
        return CGSize(width: collectionView.frame.width/5, height: collectionView.frame.width/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.img.image = UIImage(named: "sky")
        if indexPath.row == 0 {
            cell.plus_view.alpha = 1
            cell.name_label.alpha = 0
            cell.mask_view.alpha = 0.25
        } else {
            cell.name_label.alpha = 1
            cell.plus_view.alpha = 0
            cell.mask_view.alpha = 0
        }
        let photo = (selectEvent[event.photos] as! [String])[indexPath.row]
        let url = URL(string: photo)
        let processor = DownsamplingImageProcessor(size: cell.img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 0)
        cell.img.kf.indicatorType = .activity
        cell.img.kf.setImage(with: url, placeholder: UIImage(named: "sky"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
        
        cell.name_label.text = (selectEvent[event.photo_names] as! [String])[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.add_new_photo()
        } else {
            preview_name_label.isHidden = false
            preview_name_label.text = (selectEvent[event.photo_names] as! [String])[indexPath.row]
            preview_img.isHidden = false
            let photo = (selectEvent[event.photos] as! [String])[indexPath.row]
            let url = URL(string: photo)
            let processor = DownsamplingImageProcessor(size: preview_img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 0)
            preview_img.kf.indicatorType = .activity
            preview_img.kf.setImage(with: url, placeholder: UIImage(named: "sky"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
        }
    }
}

extension PhotoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            self.upload_new_photo(img: chosenImage)
            dismiss(animated:true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
