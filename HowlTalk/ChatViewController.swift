//
//  ChatViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/06/24.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var uid: String?
    var chatRoomId: String?
    var comments:  [ChatModel.Comment] = []
    var userModel: UserModel?
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var peopleCount: Int?
    public var destinationUid: String? // 나중에 내가 채팅할 대상의 UID
     
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
        self.tabBarController?.tabBar.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
        databaseRef?.removeObserver(withHandle: observe!) // 뒤로 갔을 때 관찰하던 게 사라짐
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        print("show keyboard")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height
        }
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            (complete) in
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func createRoom() {
        let createRoomInfo: Dictionary<String, Any> = [
            "users" : [
                uid!: true,
                destinationUid!: true
            ]
        ]
        if(chatRoomId == nil) { // 방 key가 없으면 방 생성
            // 방이 생성되는 동안 전송 버튼 누르면 안 됨 -> 계속 방 생성되수도 ..
            self.sendButton.isEnabled = false
            Database.database().reference().child("chatRooms").childByAutoId().setValue(createRoomInfo, withCompletionBlock: { (err, ref) in
                if(err == nil) {
                    self.checkChatRoom()
                }
            })
        } else {
            let value: Dictionary<String, Any> = [
                "uid" : uid!,
                "message" : messageTextField.text!,
                "timeStamp" : ServerValue.timestamp()
            ]
            Database.database().reference().child("chatRooms").child(chatRoomId!).child("comments").childByAutoId().setValue(value, withCompletionBlock: { (err, ref) in
                self.messageTextField.text = ""
            })
             
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
            setReadCount(label: cell.readCount, position: indexPath.row)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            cell.nameLabel.text = userModel?.userName
            cell.messageLabel.text = self.comments[indexPath.row].message
            cell.messageLabel.numberOfLines = 0
            let url = URL(string: (self.userModel?.profileImageURL)!)
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width/2
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.kf.setImage(with: url)
            if let time = self.comments[indexPath.row].timeStamp {
                cell.timeStampLabel.text = time.todayTime
            }
            setReadCount(label: cell.readCount, position: indexPath.row)
            return cell
        }
    }
    
    
    func checkChatRoom() {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) {
            (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                
                if let chatRoomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    if(chatModel?.users[self.destinationUid!] == true && chatModel?.users.count == 2) {
                        self.chatRoomId = item.key // 방의 key가 들어감
                        self.sendButton.isEnabled = true
                        self.getDestinationInfo()
                    }
                }
                
            }
        }
        
    }
    
    func getDestinationInfo() {
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value) {
            (datasnapshot) in
            let dic = datasnapshot.value as! [String:Any]
            self.userModel = UserModel(JSON: dic)
            self.getMessageList()
        }
    }
    
    func setReadCount(label: UILabel?, position: Int?) {
        let readCount = self.comments[position!].readUsers.count
        if peopleCount == nil { // 처음 한 번만 채팅방의 전체 인원 수 계산
            Database.database().reference().child("chatRooms").child(chatRoomId!).child("users").observeSingleEvent(of: DataEventType.value, with: {
                (datasnapshot) in
                let dic = datasnapshot.value as! [String:Any]
                self.peopleCount = dic.count
                let noReadCount = self.peopleCount! - readCount
                if noReadCount > 0 {
                    label?.isHidden = false
                    label?.text = String(noReadCount)
                } else {
                    label?.isHidden = true
                }
            })
        } else {
            let noReadCount = self.peopleCount! - readCount
            if noReadCount > 0 {
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
        }

    }
    
    func getMessageList() {
        databaseRef = Database.database().reference().child("chatRooms").child(self.chatRoomId!).child("comments")
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

extension Int {
    var todayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dateFormatter.string(from: date)
    }
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var readCount: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var readCount: UILabel!
}
