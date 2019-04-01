//
//  ViewController.swift
//  socketTest
//
//  Created by Stegowl on 27/07/18.
//  Copyright © 2018 Stegowl. All rights reserved.
//

import UIKit
import SocketIO
let app = UIApplication.shared.delegate as! AppDelegate
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var tblMessage: UITableView!
    @IBOutlet weak var txtMessage: UITextField!
    static let manager1 = SocketManager(socketURL: URL(string: "http://socialout.net:4040")!, config: [.log(true), .compress])
    let socket = manager1.defaultSocket
    let roomName = ""
    let opponentID = "250"
    var roomID = ""
    var arrMessages = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        socket.on(clientEvent: .connect) {data, ack in
//            print("socket connected")
//        }
//
//        socket.on("currentAmount") {data, ack in
//            guard let cur = data[0] as? Double else { return }
//
//            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
//                socket.emit("update", ["amount": cur + 2.50])
//            }
//
//            ack.with("Got your currentAmount", "dude")
//        }
//
//        socket.connect()
        establishConnection()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSendMessageClick(_ sender: UIButton) {
        
        let jsonData = MyJSON_Socket(message: self.txtMessage.text!, toID: self.opponentID, roomID: self.roomID)
        sendMessage(object: jsonData)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if app.user_id == (arrMessages.object(at: indexPath.row) as AnyObject).value(forKey: "from_id") as? String {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageViewCell", for: indexPath) as! MessageViewCell
        cell.lblMessage.text = (arrMessages.object(at: indexPath.row) as AnyObject).value(forKey: "data") as? String
        return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.lblMessage.text = (arrMessages.object(at: indexPath.row) as AnyObject).value(forKey: "data") as? String
            return cell
        }
    }
    

    func establishConnection()
    {
    
        self.socket.on(clientEvent: .connect) { (dataArray, ack) in
            print("socket.on connect called")
            self.roomID = self.getRoomNameFor(otherID: self.opponentID)
            self.joinRoomWith(opponentID: self.opponentID)
            print(dataArray)
            print(ack)
        }
        
        self.socket.on(clientEvent: .error) { (dataArray, ack) in
            print("socket.on error called")
            print(dataArray)
            print(ack)
        }
        
        self.socket.on(clientEvent: .disconnect) { (dataArray, ack) in
            print("socket.on disconnect called")
            print(dataArray)
            print(ack)
        }
        
        self.socket.on(clientEvent: .reconnect) { (dataArray, ack) in
            print("socket.on reconnect called")
            print(dataArray)
            print(ack)
        }
        
        self.socket.on(clientEvent: .reconnectAttempt) { (dataArray, ack) in
            print("socket.on reconnectAttempt called")
            print(dataArray)
            print(ack)
        }
        
        self.socket.on(clientEvent: .statusChange) { (dataArray, ack) in
            print("socket.on statusChange called")
            print(dataArray)
            print(ack)
        }
        
        self.socket.on("message") { ( dataArray, ack) -> Void in
            print("socket.on 'message' called")
            print(dataArray)
            self.arrMessages.add(dataArray[0])
            self.tblMessage.reloadData()
            print(ack)
          
        }
        
        self.socket.on("typing") { ( dataArray, ack) -> Void in
            print("socket.on 'typing' called")
            
        }
        
        self.socket.on("stop_typing") { ( dataArray, ack) -> Void in
            print("socket.on 'stop_typing' called")
            
            
        }
        
        
        // connecting to the socket of the server
        self.socket.connect()
        
        // adding all ther listerners here
        
    }
    
  
    
    func sendMessage(object: MyJSON_Socket)
    {
        let data = object.getJSON()
        socket.emit("message", data)
    }
    
    func userStartedTyping()
    {
        let data = ["username" : appDelegate.user_name, "id" : appDelegate.user_id]
        socket.emit("typing", data)
    }
    
    func userStoppedTyping()
    {
        let data = ["id" : appDelegate.user_id]
        socket.emit("stop_typing",data)
    }
    
    func getRoomNameFor(otherID: String) -> String
    {
        let myID = app.user_id
        var result = ""
        result = "grouproom1"//"room-" + myID + "-" + otherID
        return result
    }
    
    func joinRoomWith(opponentID: String)
    {
        let roomName = self.getRoomNameFor(otherID: opponentID)
        
//        if !self.joinedRooms.contains(roomName)
//        {
            socket.emit("room", roomName); // roomname >> string
            //self.joinedRooms.append(roomName)
        //}
        
    }
    
}

class MyJSON_Socket
{
    var data = "" // message
    //    var fromID = "" // from / sender id
    var toID = "" // receiver / target id
    var roomID = "" // chatRoom id
    //    var sentDate = "" // sent date
    //    var sentTime = "" // sent time
    //    var status = "" // status >> fix value 0
    
    init(message: String, toID: String, roomID: String) {
        self.data = message
        //        self.fromID = fromID
        self.toID = toID
        self.roomID = roomID
        //        self.sentDate = sentDate
        //        self.sentTime = sentTime
        //        self.status = status
    }
    
    func getJSON() -> [String : String]
    {
        return ["data" : self.data,
                "from_id" : app.user_id,
                "to_id" : self.toID,
                "room_id" : self.roomID,
                "sent_date" : "27/07/2018",
                "sent_time" : "02:50:00",
                "status" : "10",
                "name": "Jane Doe"
        ]
    }
    
    

    
}

