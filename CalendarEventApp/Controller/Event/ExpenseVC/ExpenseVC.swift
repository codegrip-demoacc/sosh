//
//  ExpenseVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class ExpenseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var person_btn: UIButton!
    @IBOutlet weak var due_btn: UIButton!
    @IBOutlet weak var expense_btn: UIButton!
    @IBOutlet weak var expense_table: UITableView!
    @IBOutlet weak var expense_view_height: NSLayoutConstraint!
    
    @IBOutlet weak var total_expense_view: UIView!
    @IBOutlet weak var bottom_btn_view: UIView!
    @IBOutlet weak var even_btn: UIButton!
    @IBOutlet weak var custom_btn: UIButton!
    var person_expenses = [ExpenseData]()
    var expense_expenses = [ExpenseData]()
    var display = [ExpenseData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
        dummy_data()
        setupTableView()
    }
    
    @IBAction func expense_btn_click(_ sender: Any) {
//        expense_btn.underlineMyText()
//        person_btn.removeUnderLine()
        
        display = expense_expenses
        expense_table.reloadData()
    }
    
    @IBAction func person_btn_click(_ sender: Any) {
//        person_btn.underlineMyText()
//        expense_btn.removeUnderLine()
        
        display = person_expenses
        expense_table.reloadData()
    }
    
    @IBAction func top_total_expense_btn_click(_ sender: Any) {
        if expense_view_height.constant == 85 {
            expense_view_height.constant = 300
            expense_table.isHidden = false
        } else {
            expense_view_height.constant = 85
            expense_table.isHidden = true
        }
    }
    
    @IBAction func even_btn_click(_ sender: Any) {
        even_btn.backgroundColor = .lightGray
        custom_btn.backgroundColor = .clear
        even_btn.setTitleColor(.white, for: .normal)
        custom_btn.setTitleColor(.lightGray, for: .normal)
    }
    
    @IBAction func custom_btn_click(_ sender: Any) {
        even_btn.backgroundColor = .clear
        custom_btn.backgroundColor = .lightGray
        even_btn.setTitleColor(.lightGray, for: .normal)
        custom_btn.setTitleColor(.white, for: .normal)
    }
    
    
    func dummy_data() {
        person_expenses.append(ExpenseData(id: "", name: "Person 1", amount: "1420"))
        person_expenses.append(ExpenseData(id: "", name: "Person 2", amount: "1420"))
        person_expenses.append(ExpenseData(id: "", name: "Person 3", amount: "1420"))
        person_expenses.append(ExpenseData(id: "", name: "Person 4", amount: "1420"))
        person_expenses.append(ExpenseData(id: "", name: "Person 5", amount: "1420"))
        person_expenses.append(ExpenseData(id: "", name: "Person 6", amount: "1420"))
        person_expenses.append(ExpenseData(id: "", name: "Person 7", amount: "1420"))
        person_expenses.append(ExpenseData(id: "", name: "Person 8", amount: "1420"))
        
        expense_expenses.append(ExpenseData(id: "", name: "Expense 1", amount: "1420"))
        expense_expenses.append(ExpenseData(id: "", name: "Expense 2", amount: "1420"))
        expense_expenses.append(ExpenseData(id: "", name: "Expense 3", amount: "1420"))
        expense_expenses.append(ExpenseData(id: "", name: "Expense 4", amount: "1420"))
        expense_expenses.append(ExpenseData(id: "", name: "Expense 5", amount: "1420"))
        expense_expenses.append(ExpenseData(id: "", name: "Expense 6", amount: "1420"))
        expense_expenses.append(ExpenseData(id: "", name: "Expense 7", amount: "1420"))
        display = person_expenses
    }
    
    func setupTableView() {
        expense_table.delegate = self
        expense_table.dataSource = self
        expense_table.separatorStyle = .none
        expense_table.rowHeight = 30
        expense_table.register(UINib(nibName: "ExpenseCell", bundle: nil), forCellReuseIdentifier: "ExpenseCell")
        expense_table.isScrollEnabled = true
        
        expense_table.reloadData()
    }
    
    func init_UI() {
        due_btn.layer.cornerRadius = 5
        due_btn.layer.masksToBounds = true
        
//        person_btn.underlineMyText()
        
        even_btn.layer.cornerRadius = 5
        even_btn.clipsToBounds = true
        custom_btn.layer.cornerRadius = 5
        custom_btn.clipsToBounds = true
        
        even_btn.backgroundColor = .clear
        custom_btn.backgroundColor = .lightGray
        even_btn.setTitleColor(.lightGray, for: .normal)
        custom_btn.setTitleColor(.white, for: .normal)
        
        bottom_btn_view.layer.cornerRadius = 5
        bottom_btn_view.backgroundColor = .white
        
        total_expense_view.layer.cornerRadius = 5
        total_expense_view.layer.borderColor = UIColor.green.cgColor
        total_expense_view.layer.borderWidth = 1
    }
}

extension ExpenseVC {
    func numberOfSections(in tableView: UITableView) -> Int {
        return display.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell") as! ExpenseCell
        cell.name_label.text = display[indexPath.section].name
        cell.amount_label.text = "$ " + display[indexPath.section].amount!
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.green.cgColor
        cell.layer.borderWidth = 1
        cell.selectionStyle = .none
        return cell
    }
}
