//
//  ShareData.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseFirestore
import NVActivityIndicatorView

class ShareData: UIViewController {
    static let appTitle = "Sosh"
    static let mainColors = [UIColor(hexString: "#465EV4"), UIColor(hexString: "#1CB450"), UIColor(hexString: "#001B60")]
    static let send_grid_key = "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"
    
    static let main_back_blue = UIColor(hexString: "#3574C0")
    static let main_back_green = UIColor(hexString: "#00B158")
    static let tag_colors = [UIColor(hexString: "#44DB5E"),UIColor(hexString: "#FE9400"),UIColor(hexString: "#5856D6"),UIColor(hexString: "#5AC8FB"),UIColor(hexString: "#D81159"),UIColor(hexString: "#FF5E3A"),UIColor(hexString: "#3B5998")]
    
    static let progressDlgs = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()
    
    static var contacts = [ContactData]()
    
    static var friends = [FriendData]()
    static var wait_users = [FriendData]() // users who did not reply for friend request
    static var me_wait_users = [FriendData]() // users who u did not reply for this user's friend request
    static var users = [FriendData]()
    static var isFriendChange = true
    
    static var friendsNoti = [NotiFriendData]()
    static var eventsNoti = [NotiEventData]()
    static var activitiesNoti = [NotiActivityData]()
    
    //for invite list in Create Event
    static var selected_users = [FriendData]()
    static var events = [[String: Any]]()
    static var arrangedEvents = [[[String: Any]]]()
    static var isEventChange = true
    static var isSelectEventChange = true
    
    func doneAlert(_ title: String, _ subtitle: String, _ btn_title: String, _ completionHandler: @escaping () -> Void)
    {
        let appearance = SCLAlertView.SCLAppearance( 
            kDefaultShadowOpacity: 0.6,
            kCircleIconHeight: 60,
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "logo")
        
        alertView.addButton(btn_title, backgroundColor: UIColor.blue, textColor: UIColor.white, action: completionHandler)
        
        alertView.showInfo(title, subTitle: subtitle, circleIconImage: alertViewIcon)
    }
    
    func selectAlert(_ title: String, _ subtitle: String, _ btn_num: Int, _ btn_titles: [String], _ btn_colors: [UIColor], _ btn_txt_colors: [UIColor], _ target: AnyObject, _ btn_actions: [Selector])
    {
        let appearance = SCLAlertView.SCLAppearance(
            kDefaultShadowOpacity: 0.6,
            kCircleIconHeight: 60,
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "logo")
        
        for i in 0..<btn_num
        {
            alertView.addButton(btn_titles[i], backgroundColor: btn_colors[i], textColor: btn_txt_colors[i], target: target, selector: btn_actions[i])
        }
        
        alertView.showInfo(title, subTitle: subtitle, circleIconImage: alertViewIcon)
    }
    
    func disappearAlert(_ subtitle: String) {
        let appearance = SCLAlertView.SCLAppearance(
            kDefaultShadowOpacity: 0.6,
            kCircleIconHeight: 60,
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "logo")
        let timeoutValue: TimeInterval = 2.0
        let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {}
        
        alertView.showInfo(ShareData.appTitle, subTitle: subtitle, timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: timeoutValue, timeoutAction: timeoutAction), circleIconImage: alertViewIcon)
    }
    
    func disappearActionAlert(_ title: String, _ subtitle: String, _ completionHandler: @escaping () -> Void) {
        let appearance = SCLAlertView.SCLAppearance(
            kDefaultShadowOpacity: 0.6,
            kCircleIconHeight: 60,
            showCloseButton: false,
            showCircularIcon: true
        )

        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "logo")
        let timeoutValue: TimeInterval = 2.0
        let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = completionHandler
    
        alertView.showInfo(title, subTitle: subtitle, timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: timeoutValue, timeoutAction: timeoutAction), circleIconImage: alertViewIcon)
    }
}
