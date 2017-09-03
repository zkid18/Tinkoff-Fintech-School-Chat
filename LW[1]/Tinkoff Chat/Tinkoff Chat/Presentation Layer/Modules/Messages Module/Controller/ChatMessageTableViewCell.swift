//
//  ChatMessageTableViewCell.swift
//  Tinkoff Chat
//
//  Created by Даниил on 25.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration: class {
    var message : Message1? {get set}
}

class ChatMessageTableViewCell: UITableViewCell, MessageCellConfiguration {
    
    var message: Message1?
    
    @IBOutlet weak var messageLabel: MessageLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell() {
        messageLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width*2/3
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 5.0
        //messageLabel.text = message?.messageText
    }
    
}
