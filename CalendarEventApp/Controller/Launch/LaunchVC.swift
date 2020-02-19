//
//  LaunchVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/24/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(SignInVC(), animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
}
