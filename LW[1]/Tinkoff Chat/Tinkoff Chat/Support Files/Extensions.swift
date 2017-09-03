//
//  Extensions.swift
//  Tinkoff Chat
//
//  Created by Даниил on 01.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color)
        }
        set(colorData, forKey: key)
    }
}

import UIKit
import Foundation

@IBDesignable
class ViewWithCorner: UIView {
    
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


