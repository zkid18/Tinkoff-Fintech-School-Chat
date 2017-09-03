//
//  HistoryChatViewController.swift
//  Tinkoff Chat
//
//  Created by Даниил on 24.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

class ConversationListViewController: BaseAnimationViewController {

    @IBOutlet weak var conversationListTableView: UITableView!
    
    var conversationListService: ConversationListFetchService!
    
    let communicationManager = CommunicationManager()
    let conversationStorageService = ConversationStorageService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleaAppInTheBackgound),
                                               name: NSNotification.Name(rawValue: "appIsInBackGround"),
                                               object: nil)
    }
    
    func handleaAppInTheBackgound() {
        print("Application: VC Back")
        conversationStorageService.changeConversationIsOnlineStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        conversationListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private methods
    
    
    private func configureTableView() {
        
        conversationListTableView.dataSource = self
        //conversationListTableView.delegate = self
        
        conversationListService = ConversationListFetchService(tableView: conversationListTableView)
        
        do {
            try conversationListService.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - IBAction
    @IBAction func unwindToHistoryViewController(segue: UIStoryboardSegue) {
    }
}



//extension ConversationListTableViewCell:

extension ConversationListViewController {
    func configureCell(cell: ConversationListTableViewCell, indexPath: IndexPath) {

        let conversation = conversationListService.fetchedResultsController.object(at: indexPath) as Conversation
        //let date = Date(timeIntervalSince1970: TimeInterval((conversation.lastMessage?.time)!)!)
    
        let date = Date()
        
        print("LIST user: \(conversation.participant?.isOnline, conversation.participant?.name)")
        
        cell.name = conversation.participant?.name
        cell.message = conversation.lastMessage?.text
        cell.online = conversation.isOnline
        
        if conversation.lastMessage?.reciever?.id == conversation.participant?.id {
            cell.message = "You: \(conversation.lastMessage?.text ?? "Write him start")"
        } else {
            cell.message = "\(conversation.lastMessage?.text ?? "Write him start")"
        }
        
        cell.date = date
        
        if cell.online == true {
            cell.backgroundColor = UIColor.init(red: 252/255, green: 218/255, blue: 142/255, alpha: 1)
        } else {
            cell.backgroundColor = UIColor.clear
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCurrentMessage" {
            let detailViewController = segue.destination as! MessageViewController
            let selectedIndexPath = self.conversationListTableView.indexPathForSelectedRow!
            let conservation = conversationListService.fetchedResultsController.object(at: selectedIndexPath) as Conversation
            
            detailViewController.currentCommunicationManager = communicationManager
            detailViewController.currentConversation = conservation
            
            detailViewController.currentCommunicationManager.activeContactDelegate = detailViewController
        }
    }
}


extension ConversationListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return (conversationListService.fetchedResultsController.sections?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = conversationListService.fetchedResultsController.sections![section]
        print("LIST section name: \(sectionInfo.name)")
        var sectionName: String?
        
        if sectionInfo.name == "1" {
            sectionName = "Online"
        }
        if sectionInfo.name == "0" {
            sectionName = "History"
        }
        return sectionName
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = conversationListService.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! ConversationListTableViewCell
        
        configureCell(cell: cell, indexPath: indexPath)
        cell.setBindig()
        
        return cell
    }
    
}


