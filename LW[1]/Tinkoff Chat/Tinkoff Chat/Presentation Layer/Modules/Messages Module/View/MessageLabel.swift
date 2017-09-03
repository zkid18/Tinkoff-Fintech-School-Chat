//
//  MessageLabel.swift
//  Tinkoff Chat
//
//  Created by Даниил on 11.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

class MessageLabel: UILabel {
    
    var topInset: CGFloat = 16.0
    var bottomInset: CGFloat = 16.0
    var leftInset: CGFloat = 5.0
    var rightInset: CGFloat = 5.0
    
    override public var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
    
    override func draw(_ rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
