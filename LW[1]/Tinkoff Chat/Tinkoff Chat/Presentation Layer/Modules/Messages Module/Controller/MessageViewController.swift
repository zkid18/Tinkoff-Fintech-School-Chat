//
//  MessageViewController.swift
//  Tinkoff Chat
//
//  Created by Даниил on 25.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit


protocol InputTextViewsDelegate: class {
    func isUserOnline()
    func isUserOffline()
}

class MessageViewController: BaseAnimationViewController {

    var currentConversation: Conversation!
    weak var messageDelegate: InputTextViewsDelegate!
    
    var messageListService: MessageListFetchService!
    
    var containerViewController: InputTextViewController?
    var currentCommunicationManager: CommunicationManager!
    
    @IBOutlet weak var enterMessageView: UIView!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageListService = MessageListFetchService(tableView: messageTableView, id: currentConversation.id!)
        
        do {
            try messageListService.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        configureTableView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if currentConversation.isOnline {
            changeNavigationTitleForOnline()
        }
    }

    
    func configureTableView() {
        messageTableView.dataSource = self
        navigationItem.title = currentConversation.participant?.name
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 44

        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame , object: nil)
        
    }
    
    func handleMPCReceivedMessageDataWithNotification(_ notification: NSNotification) {        
        OperationQueue.main.addOperation {
            self.messageTableView.reloadData()
        }
        print("Message Table View Has Updated")
    }
    
    func changeNavigationTitleForOnline() {
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.green,
            NSFontAttributeName : UIFont(name: ".SFUIText-Medium", size: 20)!]
    }
    
    func changeNavigationTitleForOffline() {
        UIView.animate(withDuration: 1) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black]
        }
    }
    
    func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            
            if (keyboardFrame.origin.y) >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint.constant = keyboardFrame.size.height
            }
            
            UIView.animate(withDuration: duration, animations: {self.view.layoutIfNeeded()})
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MessageViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToInputText" {
            let connectContainerViewController = segue.destination as? InputTextViewController
            containerViewController = connectContainerViewController
            connectContainerViewController?.conversation = currentConversation
            
            containerViewController?.currentCommunicationManager = currentCommunicationManager
            messageDelegate = connectContainerViewController
        }
    }
}


extension MessageViewController: UITableViewDataSource {
    
    //MARK: - tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = messageListService.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (messageListService.fetchedResultsController.sections?.count)!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = ChatMessageTableViewCell()
        
        let message = messageListService.fetchedResultsController.object(at: indexPath)
        
        if message.reciever?.id == currentConversation.participant?.id {
            cell = tableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as! ChatMessageTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "recieverCell", for: indexPath) as! ChatMessageTableViewCell
        }
        
        
        cell.messageLabel.text = message.text
        cell.configureCell()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        containerViewController?.messageTextField.endEditing(true)
    }
}


extension MessageViewController: ContactManagerDelegate {
    
    func becomeOnline() {
        print("message is online")
        changeNavigationTitleForOnline()
        messageDelegate.isUserOnline()
    }
    
    func becomeOffline() {
        print("message is offline")
        changeNavigationTitleForOffline()
        messageDelegate.isUserOffline()
    }
    
}

