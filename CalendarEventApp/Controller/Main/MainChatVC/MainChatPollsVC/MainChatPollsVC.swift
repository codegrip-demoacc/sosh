//
//  MainChatPollsVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainChatPollsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var eventPollsData = [EventPollData]()
    var displayIndex = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dummy_data()
        setupTableView()
        init_UI()
    }
    
    @objc func addBtnClick(_ sender: UIButton!) {
        let point = sender.convert(CGPoint.zero, to: tableView as UIView)
        var activeIndexPath: IndexPath! = tableView.indexPathForRow(at: point)!
        
        let tableIndex = activeIndexPath.section
        let collectionIndex = sender.tag
        print(tableIndex)
        print(collectionIndex)
    }
    
    func tableViewCellSelectHandler(tableIndex: Int, collectionIndex: IndexPath, answerIndex: IndexPath, answer: String) {
        print(tableIndex)
        print(collectionIndex.row)
        print(answerIndex.row)
        print(answer)
    }
    
    func dummy_data() {
        var questions = [QuestionData]()
        questions.append(QuestionData(id: "", question: "What do you want to do Saturday?", answers: ["Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        questions.append(QuestionData(id: "", question: "What do you want to do Sunday?", answers: ["Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        questions.append(QuestionData(id: "", question: "What do you want to do Monday?", answers: ["Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking.","Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions"]))
        questions.append(QuestionData(id: "", question: "What do you want to do Tuesday?", answers: ["Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        eventPollsData.append(EventPollData(id: "", name: "Tahoe Ski Trip", questions: questions))
        
        questions.removeAll()
        questions.append(QuestionData(id: "", question: "What do you want to do Monday?", answers: ["Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking.","Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions"]))
        questions.append(QuestionData(id: "", question: "What do you want to do Tuesday?", answers: ["Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        questions.append(QuestionData(id: "", question: "What do you want to do Saturday?", answers: ["Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        eventPollsData.append(EventPollData(id: "", name: "Joshua Tree Camping", questions: questions))
        
        questions.removeAll()
        questions.append(QuestionData(id: "", question: "What do you want to do Saturday?", answers: ["Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        questions.append(QuestionData(id: "", question: "What do you want to do Sunday?", answers: ["Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        questions.append(QuestionData(id: "", question: "What do you want to do Monday?", answers: ["Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking.","Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions"]))
        questions.append(QuestionData(id: "", question: "What do you want to do Tuesday?", answers: ["Hike `that` trail in the morning.", "Sleep in and recover from `bad` decisions", "Eat a fatty brunch at Gertrude's", "I don't know, I can't even tie my shoes without overthinking."]))
        eventPollsData.append(EventPollData(id: "", name: "Tahoe Ski Trip", questions: questions))
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PollCell", bundle: nil), forCellReuseIdentifier: "PollCell")
        tableView.isScrollEnabled = true
        
        tableView.reloadData()
    }
    
    func init_UI() {
        displayIndex = [Int](repeating: 0, count: eventPollsData.count)
    }
}

extension MainChatPollsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventPollsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40*eventPollsData[indexPath.section].questions![displayIndex[indexPath.section]].answers!.count+125)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath as IndexPath) as! PollCell
        cell.name_label.text = eventPollsData[indexPath.section].name
        cell.num_label.text = "\(displayIndex[indexPath.section]+1)"
        cell.collectionView.reloadData()
        cell.collectionView.scrollToIndex(index: displayIndex[indexPath.section])
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? PollCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? PollCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        tableViewCell.collectionViewOffset = 0 
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard cell is PollCell else { return }
    }
}

extension MainChatPollsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventPollsData[collectionView.tag].questions!.count
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
        height = CGFloat(40*eventPollsData[collectionView.tag].questions![indexPath.row].answers!.count + 80)
        return CGSize(width: tableView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        
        cell.question_label.text = eventPollsData[collectionView.tag].questions![indexPath.row].question
        cell.answers = eventPollsData[collectionView.tag].questions![indexPath.row].answers!
        cell.table_height.constant = CGFloat(40*eventPollsData[collectionView.tag].questions![indexPath.row].answers!.count)
        
        cell.plus_btn.tag = indexPath.row
        cell.plus_btn.addTarget(self, action: #selector(self.addBtnClick(_:)), for: .touchUpInside)
        
        cell.selectCellHandler = { ( _ subIndexPath: IndexPath, _ answer: String) -> Void in
            
            self.tableViewCellSelectHandler(tableIndex: collectionView.tag, collectionIndex: indexPath, answerIndex: subIndexPath, answer: answer)
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            return
        }
        var visibleRect = CGRect()
        
        visibleRect.origin = scrollView.contentOffset
        visibleRect.size = scrollView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let row = Int(visiblePoint.x / self.tableView.frame.width)
        displayIndex[scrollView.tag] = row
        tableView.reloadData()
    }
}

extension MainChatPollsVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Polls")
    }
}
