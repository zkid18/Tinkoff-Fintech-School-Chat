//
//  MessageListFetchService.swift
//  Tinkoff Chat
//
//  Created by Даниил on 13.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class MessageListFetchService: NSObject {
    
    var fetchedResultsController: NSFetchedResultsController<Message>
    let tableView: UITableView
    let id: String
    let coreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
    init(tableView: UITableView, id: String) {
        self.tableView = tableView
        self.id = id
        let context = coreDataStack.mainContext
        
        let fetchRequest: NSFetchRequest<Message> = Message.fethRequestsUser(id: id, in: coreDataStack.mainContext!)!
        let dateSort = NSSortDescriptor(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        
        fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest:
            fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil,
                          cacheName: nil)
        
        super.init()
        
        fetchedResultsController.delegate = self
    }
}


extension MessageListFetchService: NSFetchedResultsControllerDelegate {
    
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
                //tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
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
