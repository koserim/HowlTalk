//
//  ChatModel.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/06/25.
//  Copyright © 2020 serim. All rights reserved.
//

import ObjectMapper

struct ChatModel: Mappable {

    public var users: Dictionary<String,Bool> = [:] // 채팅방에 참여한 사람들에 대한 dic
    public var comments: Dictionary<String, Comment> = [:] // 대화 내용
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    struct Comment: Mappable {
        public var uid: String?
        public var message: String?
        public var timeStamp: Int?
        public var readUsers : Dictionary<String, Bool> = [:]
        init?(map: Map) {
            
        }
        mutating func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timeStamp <- map["timeStamp"]
            readUsers <- map["readUsers"]
        }
    }
}
