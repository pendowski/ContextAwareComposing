//
//  ViewController.swift
//  ContextComposeField
//
//  Created by Jarosław Pendowski on 01/08/16.
//  Copyright © 2016 Jarosław Pendowski. All rights reserved.
//

import UIKit
import ContextAwareComposeField

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

extension UITextField: MessageContainer {
    
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ContextAwareComposeViewDelegate {
    
    private var messageTimer: NSTimer!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var composeView: ContextAwareComposeView!
    @IBOutlet private var composeViewBottomContraint: NSLayoutConstraint!
    
    private var textField: UITextField!
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.messages.append(Message(type: .Incomming, body: "Hello"))
        self.messages.append(Message(type: .Incomming, body: "World"))

        self.messages.append(Message(type: .Outgoing, body: "Hi"))
        
        self.textField = UITextField()
        self.textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.textFieldDidChange(_:)),
                                                         name: UITextFieldTextDidChangeNotification,
                                                         object: self.textField)
        
        self.composeView.messageContainer.setMessageComposeView(self.textField)
        self.composeView.delegate = self
        self.composeView.sendButton.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardFrameChanged(_:)), name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        self.messageTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self,
                                                                   selector: #selector(self.sendFakeMessage),
                                                                   userInfo: nil,
                                                                   repeats: true)
    }
    
    func insertMessage(message: Message) {
        let animation: UITableViewRowAnimation = message.type == .Incomming ? .Right : .Left

        self.messages.append(message)
        let newIndexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
        
        self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: animation)
        self.tableView.scrollToRowAtIndexPath(newIndexPath, atScrollPosition: .Bottom, animated: true)
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
    
    // MARK: - Compose view delegate
    
    func composeView(composeView: ContextAwareComposeView, pressedSendButton: UIButton) {
        if let message = self.textField.text {
            self.insertMessage(Message(type: .Outgoing, body: message))
        }
        
        self.textField.text = ""
        self.composeView.setSaveButtonVisible(false, animated: true)
        self.composeView.sendButton.enabled = false
    }
    
    func composeView(composeView: ContextAwareComposeView, pressedSaveButton: UIButton) {
        self.textField.text = ""
        self.composeView.setSaveButtonVisible(false, animated: true)
        self.composeView.sendButton.enabled = false
    }
    
    func composeView(composeView: ContextAwareComposeView, tappedOnSavedMessage savedMessage: String) {
        let currentMessage = [ self.textField.text, savedMessage ].flatMap({ $0 }).joinWithSeparator(" ")
        self.textField.text = currentMessage
        self.composeView.sendButton.enabled = true
    }
    
    func composeView(composeView: ContextAwareComposeView, adjustForSavedMessagesOfHeight height: CGFloat) {
        self.tableView.contentInset.bottom = height
    }
    
    
    func viewForStoringSavesMessage(composeView: ContextAwareComposeView, savedMessage: String) -> UIView {
        let bubble = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let label = UILabel(frame: bubble.bounds)
        label.text = savedMessage
        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        bubble.addSubview(label)
        bubble.backgroundColor = UIColor.redColor()
        return bubble
    }
    
    // MARK: - Text Field delegate
    
    @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    @objc private func textFieldDidChange(notification: NSNotification) {
        if let textField = notification.object as? UITextField {
            self.composeView.sendButton.enabled = !(textField.text?.isEmpty ?? true)
        }
    }
    
    // MARK: - Keyboard handling
    
    @objc func keyboardFrameChanged(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
            self.composeViewBottomContraint.constant = CGRectGetHeight(keyboardFrame)
        }
    }
    
    // MARK: - Timer
    
    @objc private func sendFakeMessage() {
        let date = NSDate()
        self.insertMessage(Message(type: .Incomming, body: "It's now \(date)"))
        
        if let message = self.textField.text where !message.isEmpty {
            self.composeView.setSaveButtonVisible(true, animated: true)
        }
    }

}

