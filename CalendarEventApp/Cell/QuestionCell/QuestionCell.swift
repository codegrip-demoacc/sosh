//
//  QuestionCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/5/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class QuestionCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var question_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plus_btn: UIButton!
    @IBOutlet weak var table_height: NSLayoutConstraint!
    var selectCellHandler : (( _ indexPath: IndexPath, _ answer: String) -> Void)!
    
    var answers = [String]()
    
    override func layoutSubviews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 40
        tableView.register(UINib(nibName: "AnswerCell", bundle: nil), forCellReuseIdentifier: "AnswerCell")
        tableView.isScrollEnabled = false
        
        tableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AnswerCell") as! AnswerCell
        cell.answer_label.text = answers[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var answer = String()
        answer = answers[indexPath.row]
        if (selectCellHandler != nil) {
            //            let cell = tableView.cellForRow(at: indexPath)
            selectCellHandler(indexPath, answer)
        }
    }
}
