//
//  EventListVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import NVActivityIndicatorView

class EventListVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var collectionView: UICollectionView!
    
    var userModel = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        if ShareData.isEventChange {
            read_data()
        } else {
            self.collectionView.reloadData()
        }
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if ShareData.isEventChange {
//            read_data()
//        }
        self.view.layoutIfNeeded()
    }
    
    func read_data() {
        userModel = UserDefaults.standard.object(forKey: "userModel") as! [String : Any]

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
        self.collectionView.reloadData()
    } 
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "EventListCell", bundle: nil), forCellWithReuseIdentifier: "EventListCell")
        collectionView.showsVerticalScrollIndicator = false
    }
    
    func tableViewCellSelectHandler( collectionIndex: IndexPath, tableIndex: IndexPath) {
        print(collectionIndex.row)
        print(tableIndex.section)
        
        let selectEvent = ShareData.arrangedEvents[collectionIndex.row][tableIndex.section]
        UserDefaults.standard.set(selectEvent, forKey: "selectEvent")
        self.navigationController?.pushViewController(EventVC(), animated: true)
    }
}

extension EventListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShareData.arrangedEvents.count
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
        
        var height = CGFloat()
        height = CGFloat(70*(ShareData.arrangedEvents[indexPath.row].count) + 70)
        return CGSize(width: collectionView.frame.size.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventListCell", for: indexPath) as! EventListCell
        cell.date_label.text = (ShareData.arrangedEvents[indexPath.row][0][event.start_date] as! String).monthAndyear()
        cell.table_height.constant = CGFloat(70*(ShareData.arrangedEvents[indexPath.row].count))
        cell.events = ShareData.arrangedEvents[indexPath.row]
        cell.contain_width.constant = collectionView.frame.size.width

        cell.selectCellHandler = { ( _ subIndexPath: IndexPath) -> Void in
            
            self.tableViewCellSelectHandler(collectionIndex: indexPath, tableIndex: subIndexPath)
        }
        return cell
    }
}
