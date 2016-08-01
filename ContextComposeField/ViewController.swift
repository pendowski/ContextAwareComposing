//
//  ViewController.swift
//  ContextComposeField
//
//  Created by Jarosław Pendowski on 01/08/16.
//  Copyright © 2016 Jarosław Pendowski. All rights reserved.
//

import UIKit

enum CellIdentifier: String {
    case Incomming = "IncommingCell"
    case Outgoing = "OutgoingCell"
}

enum MessageType {
    case Incomming
    case Outgoing
}

struct Message {
    let type: MessageType
    let body: String
}

class MessageCell: UITableViewCell {
    @IBOutlet var messageLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private var tableView: UITableView!
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.messages.append(Message(type: .Incomming, body: "Hello"))
        self.messages.append(Message(type: .Incomming, body: "World"))

        self.messages.append(Message(type: .Outgoing, body: "Hi"))
        
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
        
        var messageCell: MessageCell? = nil
        switch message.type {
        case .Incomming:
            messageCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.Incomming.rawValue, forIndexPath: indexPath) as? MessageCell
        case .Outgoing:
            messageCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.Outgoing.rawValue, forIndexPath: indexPath) as? MessageCell
        }
        
        guard let cell = messageCell else {
            preconditionFailure()
        }
        
        cell.messageLabel.text = message.body
        
        return cell
    }

}

