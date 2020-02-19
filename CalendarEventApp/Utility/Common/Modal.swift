//
//  Modal.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import Foundation

struct user {
    static let uid = "uid"
    static let name = "name"
    static let email = "email"
    static let photo = "photo"
    static let phone = "phone"
    static let isPush = "isPush"
    static let isFacebook = "isFacebook"
    static let isInstagram = "isInstagram"
    static let isGmail = "isGmail"
}

struct event {
    static let id = "id"
    static let creator_id = "creator_id"
    static let creator_name = "creator_name"
    static let creator_photo = "creator_photo"
    static let accept = "accepted_users"
    static let invite = "invite_users"
    static let name = "name"
    static let start_date = "start_date"
    static let start_date_time = "start_date_time"
    static let end_date = "end_date"
    static let end_date_time = "end_date_time"
    static let location = "location"
    static let description = "description"
    static let isPrivate = "isPrivate"
    static let photos = "photos"
    static let photo_names = "photo_names"
    static let yes = "yes"
    static let no = "no"
    static let tbd = "tbd"
}

struct EAEvent {
    let start_date = String()
    let end_date = String()
    let name = String()
}

struct activity {
    static let id = "id"
    static let name = "name"
    static let date = "date"
    static let time = "time"
    static let location = "location"
    static let description = "description"
    static let status = "status" // for users read activities or not
    static let read = "read" // for read notification of activities
}

struct message {
    static let sender_id = "sender_id"
    static let sender_name = "sender_name"
    static let sender_photo = "sender_photo"
    static let text = "text"
    static let time = "time"
}

struct activityType {
    static let update = "update" // update or delete
    static let add = "add"
}

struct logistic {
    static let arrive_date = "arrive_date"
    static let arrive_time = "arrive_time"
    static let arrive_method = "arrive_method"
    static let arrive_comment = "arrive_comment"
    static let depart_date = "depart_date"
    static let depart_time = "depart_time"
    static let depart_method = "depart_method"
    static let depart_comment = "depart_comment"
    static let lodging = "lodging"
}

struct notiType {
    static let friend = "friend"
    static let event = "event"
    static let chat = "chat"
    static let activity = "activity"
    static let expense = "expense"
}

struct badge {
    static var total = Int()
    static var friend = Int()
    static var chat = Int()
    static var activity = Int()
    static var expense = Int()
    static var event = Int()
}

struct FriendData: Codable {
    let uid: String?
    let photo: String?
    let name: String?
}

struct ContactData {
    let name: String?
    let emails: [String]?
    let photo: Data?
}

struct NotiFriendData: Codable {
    let id: String?
    let name: String?
    let photo: String?
    var status: Int?
    var read: Bool?
}

struct NotiEventData: Codable {
    let id: String?
    let name: String?
    let start_date: String?
    let end_date: String?
    let location: String?
    let creator_id: String?
    let creator_name: String?
    let creator_photo: String?
    var status: Int?
    var read: Bool?
}

struct NotiActivityData: Codable {
    let event_id: String?
    let event_name: String?
    let creator_id: String?
    let creator_name: String?
    let creator_photo: String?
    let activity_count: Int?
    var read: Bool?
}

struct ExpenseData: Codable {
    let id: String?
    let name: String?
    let amount: String?
}

struct QuestionData: Codable {
    let id: String?
    let question: String?
    let answers: [String]?
}

struct EventPollData: Codable {
    let id: String?
    let name: String?
    let questions: [QuestionData]?
}

struct EventTypeData: Codable {
    let id: String?
    let type: String?
    let details: [String]?
}

struct ChatEventListData: Codable {
    let id: String?
    let name: String?
    let lists: [EventTypeData]?
}
