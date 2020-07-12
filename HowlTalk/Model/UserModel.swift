//
//  UserModel.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/06/24.
//  Copyright © 2020 serim. All rights reserved.
//

import ObjectMapper

class UserModel: Mappable {
    var profileImageURL: String?
    var userName: String?
    var uid: String?
    var status: String?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        uid <- map["uid"]
        userName <- map["userName"]
        profileImageURL <- map["profileImageURL"]
        status <- map["status"]
    }
    
}
