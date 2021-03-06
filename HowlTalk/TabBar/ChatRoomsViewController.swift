//
//  ChatRoomsViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/07/06.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var uid: String!
    var chatRooms: [ChatModel]! = []
    var destinationUsers: [String] = []
    var keys: [String] = [] //방에 대한 키값을 보관하는 변수

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uid = Auth.auth().currentUser?.uid
        self.getChatRoomsList() 
    }
    
    func getChatRoomsList() {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: {
            (datasnapshot) in
            self.chatRooms.removeAll()
            // item : 각 방
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                // self.chatRooms.removeAll()
                if let chatRoomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    self.keys.append(item.key) // 각 방에 대한 키값 저장
                    self.chatRooms.append(chatModel!)
                    print("appended")
                }
            }
            print("count")
            print(self.chatRooms.count)
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("hi~~~!")
        print(self.chatRooms.count)
        return self.chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! CustomCell
        var destinationUid: String?
        for item in chatRooms[indexPath.row].users {
            if(item.key != self.uid) {
                destinationUid = item.key
                destinationUsers.append(destinationUid!)
            }
        }
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value, with: {
            (datasnapshot) in
            let dic = datasnapshot.value as! [String:Any]
            let userModel = UserModel(JSON: dic)
            cell.titleLabel.text = userModel?.userName
            let url = URL(string: (userModel?.profileImageURL)!)
            cell.imageview.layer.cornerRadius = cell.imageview.frame.width/2
            cell.imageview.layer.masksToBounds = true
            cell.imageview.kf.setImage(with: url)
            
            // 나눈 대화가 없을 경우
            if(self.chatRooms[indexPath.row].comments.keys.count == 0) {
                return
            }
            
            let lastMessageKey = self.chatRooms[indexPath.row].comments.keys.sorted(){$0 > $1}
            cell.lastMessageLabel.text = self.chatRooms[indexPath.row].comments[lastMessageKey[0]]?.message
            let unixTime = self.chatRooms[indexPath.row].comments[lastMessageKey[0]]?.timeStamp
            cell.timeStampLabel.text = unixTime?.todayTime
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(self.destinationUsers[indexPath.row].count > 2) { // 단체 채팅방
            // let destinationUid = self.destinationUsers[indexPath.row]
            let view = self.storyboard?.instantiateViewController(identifier: "GroupChatRoomViewController") as! GroupChatRoomViewController
            view.destinationRoom = self.keys[indexPath.row]
            self.navigationController?.pushViewController(view, animated: true)
        } else { // 일대일 채팅방
            let destinationUid = self.destinationUsers[indexPath.row]
            let view = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
            view.destinationUid = destinationUid
            self.navigationController?.pushViewController(view, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }

}

class CustomCell: UITableViewCell {
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
}
