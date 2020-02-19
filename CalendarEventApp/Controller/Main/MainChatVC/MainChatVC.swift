//
//  MainChatVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainChatVC: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 18)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 40
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 30
        settings.style.buttonBarRightContentInset = 30
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .white
            newCell?.label.textColor = .white
        }
        super.viewDidLoad()

        init_UI()
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = MainChatPollsVC()
        let child_2 = MainChatChatVC()
        let child_3 = MainChatListsVC()
        return [child_1, child_2, child_3]
    }

    override func viewWillAppear(_ animated: Bool) {

    }

    func init_UI(){
    }
}
