//
//  InputTextViewController.swift
//  Tinkoff Chat
//
//  Created by Даниил on 25.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit


class InputTextViewController: UIViewController {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var messageStorage = MessageStorageService()
    var conversation: Conversation!
    
    var currentCommunicationManager: CommunicationManager!
    var isSendButtonEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if !conversation.isOnline {
            sendButton.isEnabled = false
            isSendButtonEnabled = false
        }
        
        messageTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        messageTextField.addTarget(self, action: #selector(textFieldDidBegin(textField:)), for: .editingDidBegin)
    }
    
    func textFieldDidChange(textField: UITextField){
        
        var typeCount = 1
        
        if textField.text == "" {
            disableButton()
            typeCount -= 1
        }
        
        if textField.text != "" && isSendButtonEnabled && typeCount == 1 {
            enableButton()
            typeCount += 1
        }
    }
    
    func textFieldDidBegin(textField: UITextField){
        disableButton()
        print("Text begin")
    }
    
    func enableButton() {
        sendButton.isEnabled = true
        UIView.animate(withDuration: 0.5) {
            self.sendButton.tintColor = UIColor.init(red: 0.22, green: 0.33, blue: 0.53, alpha: 1)
            self.sendButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            UIView.animate(withDuration: 1) {
                self.sendButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    func disableButton() {
        sendButton.isEnabled = false
    }
    

    //MARK: - IBActions
    
    @IBAction func sendMessge(_ sender: Any) {
        
        messageStorage.saveMessageToConversation(in: conversation.id!, messageText: messageTextField.text!, messageDate: Date(), userID: (conversation.participant?.id)!)
        
        currentCommunicationManager.sendMessage(messageText: messageTextField.text!, userID: (conversation.participant?.id)!)
        messageTextField.text = nil
    }
}

extension InputTextViewController: InputTextViewsDelegate {
    
    func isUserOnline() {
        print("user is online")
        isSendButtonEnabled = true
        //enableButton()
    }
    func isUserOffline() {
        print("user is offline")
        isSendButtonEnabled = false
        disableButton()
    }
}
