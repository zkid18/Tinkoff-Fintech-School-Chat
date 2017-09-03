//
//  ConversationListFetchService.swift
//  Tinkoff Chat
//
//  Created by Даниил on 13.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ConversationListFetchService: NSObject {
    
    var fetchedResultsController: NSFetchedResultsController<Conversation>
    let tableView: UITableView
    let coreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
    init(tableView: UITableView) {
        self.tableView = tableView
        let context = coreDataStack.mainContext
        
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        let isOnlineSort = NSSortDescriptor(key: "isOnline", ascending: false)
        let idSort = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [isOnlineSort,idSort]
        
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest:
            fetchRequest, managedObjectContext: context!, sectionNameKeyPath: "isOnline",
                          cacheName: nil)
        
        super.init()
        
        fetchedResultsController.delegate = self
    }
}


extension ConversationListFetchService: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange  anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            tableView.reloadData()
        }
    }
        
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .automatic)
        case .move, .update: break
        }
    }
}

    
    
