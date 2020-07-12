//
//  GroupChatRoomViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/07/08.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase

class GroupChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var destinationRoom: String?
    var uid: String?
    
    var comments:  [ChatModel.Comment] = []

    var databaseRef: DatabaseReference?
    var observe: UInt?
    var users: [String:AnyObject]?
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            // user 정보 담아줌
            self.users = datasnapshot.value as! [String:AnyObject]
        }
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        getMessageList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.comments[indexPath.row].uid == uid) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.messageLabel.text = self.comments[indexPath.row].message
            cell.messageLabel.numberOfLines = 0
             
            if let time = self.comments[indexPath.row].timeStamp {
                cell.timeStampLabel.text = time.todayTime
            }
             // setReadCount(label: cell.readCount, position: indexPath.row)
            return cell
         } else {
            let destinationUser = users![self.comments[indexPath.row].uid!]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            cell.nameLabel.text = destinationUser!["userName"] as! String
            cell.messageLabel.text = self.comments[indexPath.row].message
            cell.messageLabel.numberOfLines = 0
            let imageUrl = destinationUser!["profileImageURL"] as! String
            let url = URL(string: imageUrl)
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width/2
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.kf.setImage(with: url)
            if let time = self.comments[indexPath.row].timeStamp {
                cell.timeStampLabel.text = time.todayTime
            }
         // setReadCount(label: cell.readCount, position: indexPath.row)
            return cell
        }
    }
    
    @objc func sendMessage() {
        let value: Dictionary<String, Any> = [
            "uid": uid!,
            "message": messageTextField.text!,
            "timeStamp": ServerValue.timestamp()
        ]
        Database.database().reference().child("chatRooms").child(destinationRoom!).child("comments").childByAutoId().setValue(value) { (err, ref) in
            self.messageTextField.text = ""
        }
        
    }
    
    func getMessageList() {
        databaseRef = Database.database().reference().child("chatRooms").child(self.destinationRoom!).child("comments")
        observe = databaseRef?.observe(DataEventType.value) {
            (datasnapshot) in
            self.comments.removeAll()
            var readUserDic : Dictionary<String, AnyObject> = [:]
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                let key = item.key as String
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                var notifyComment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                notifyComment?.readUsers[self.uid!] = true
                readUserDic[key] = notifyComment?.toJSON() as! NSDictionary
                self.comments.append(comment!)
            }
            let nsDic = readUserDic as NSDictionary
            
            if(self.comments.last?.readUsers.keys == nil) {
                return
            }
            // 마지막 대화를 내가 읽지 않았으면 서버에 보고
            if(!(self.comments.last?.readUsers.keys.contains(self.uid!))!) {
                datasnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any]) { (err, ref) in
                    self.tableView.reloadData()
                    if self.comments.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                }
            } else { // 읽었으면 그냥 메시지만 표현
                self.tableView.reloadData()
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }

        }
    }

   

}
