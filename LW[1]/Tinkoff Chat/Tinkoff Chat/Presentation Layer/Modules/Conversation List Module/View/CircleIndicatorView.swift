//
//  CircleIndicatorView.swift
//  Tinkoff Chat
//
//  Created by Даниил on 26.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

@IBDesignable
class CircleIndicatorView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 5{
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet { layer.borderColor = borderColor.cgColor }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet { layer.borderWidth = borderWidth }
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        layer.cornerRadius = cornerRadius
    }

}
