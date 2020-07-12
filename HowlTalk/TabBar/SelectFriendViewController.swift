//
//  SelectFriendViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/07/08.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox
import Kingfisher

class SelectFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BEMCheckBoxDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var makeRoomButton: UIButton!
    
    // 초대할 친구들의 목록
    var users = Dictionary<String, Bool>()
    var array: [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference().child("users").observe(DataEventType.value, with: {
            (snapshot) in
            self.array.removeAll() // 중복되는 데이터 제거
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let dic = fchild.value as! [String : Any]
                let userModel = UserModel(JSON: dic)
                
                // 친구 목록에 내 uid는 뜨지 않도록
                if(userModel!.uid == myUid) {
                    continue
                }
                
                self.array.append(userModel!)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        makeRoomButton.addTarget(self, action: #selector(makeRoom), for: .touchUpInside )
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        cell.nameLabel.text = array[indexPath.row].userName
        cell.profileImageView.kf.setImage(with: URL(string: array[indexPath.row].profileImageURL!))
        cell.checkBox.delegate = self
        cell.checkBox.tag = indexPath.row
        return cell
    }

    // 체크박스를 관련 이벤트를 발생
    func didTap(_ checkBox: BEMCheckBox) {
        if(checkBox.on) { // 체크됐을 때
            users[self.array[checkBox.tag].uid!] = true
        } else {
            users.removeValue(forKey: self.array[checkBox.tag].uid!)
        }
    }
    
    @objc func makeRoom() {
        var myUid = Auth.auth().currentUser?.uid
        users[myUid!] = true
        let nsDic = users as! NSDictionary
        Database.database().reference().child("chatRooms").childByAutoId().child("users").setValue(nsDic)
    }
    
}

class SelectFriendCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}
