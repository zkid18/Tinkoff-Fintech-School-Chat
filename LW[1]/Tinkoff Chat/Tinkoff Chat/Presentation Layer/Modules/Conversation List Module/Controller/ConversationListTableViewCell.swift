//
//  HistoryTableViewCell.swift
//  Tinkoff Chat
//
//  Created by Даниил on 24.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration: class {
    var name: String? {get set}
    var message: String? {get set}
    var date: Date?  {get set}
    var online: Bool {get set}
    var hasUnreadMessage: Bool {get set}
}

class ConversationListTableViewCell: UITableViewCell, ConversationCellConfiguration {
    
    @IBOutlet weak var interlocutorNameLabel: UILabel!
    @IBOutlet weak var inercloutorLastMessageLabel: UILabel!
    @IBOutlet weak var isOnlineIndicatorView: CircleIndicatorView!
    @IBOutlet weak var lastMessageTimeLabel: UILabel!
    
    var name: String?
    var message: String?
    var date: Date?
    var online: Bool = false
    var hasUnreadMessage: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBindig() {
        interlocutorNameLabel.text = name
        inercloutorLastMessageLabel.text = message
        
        lastMessageTimeLabel.text = formatData(date!)
        checkCurrentUserStaus(isOnline: online)
        
        hasUnreadMessage = false
    }
    
    //MARK: - Private methods
    
    private func formatData(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.autoupdatingCurrent
        let convertedString: String
        
        if calendar.isDateInYesterday(date) {
            dateFormatter.dateFormat = "EEEE"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        
        convertedString = dateFormatter.string(from: date)
        return convertedString
    }
    
    private func checkCurrentUserStaus(isOnline: Bool) {
        if isOnline { isOnlineIndicatorView.backgroundColor = UIColor.green }
        else {isOnlineIndicatorView.backgroundColor = UIColor.red}
    }
}
