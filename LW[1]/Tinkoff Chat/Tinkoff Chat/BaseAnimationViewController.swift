//
//  BaseAnimationViewController.swift
//  Tinkoff Chat
//
//  Created by Даниил on 27.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

protocol IGestureRecognizerProtocol : class {
    func createFireWorks()
    func tapHandler(gesture: UITapGestureRecognizer)
    func stopFireWorks()
    func setGesture()
}

class BaseAnimationViewController: UIViewController {
    
    let emitter = CAEmitterLayer()
    var pointTap: CGPoint?
    var tap: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGesture()
    }
}


extension BaseAnimationViewController: IGestureRecognizerProtocol {
    
    func setGesture() {
        tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.minimumPressDuration = 1
        
        self.view.addGestureRecognizer(tap)
    }
    
    func tapHandler(gesture: UITapGestureRecognizer)  {
        if gesture.state == .began {
            print("start")
            pointTap = gesture.location(in: gesture.view)
            createFireWorks()
        } else if gesture.state == .ended {
            print("ended")
            stopFireWorks()
        } else if gesture.state == .changed {
            pointTap = gesture.location(in: gesture.view)
            createFireWorks()
        }
    }
    
    func createFireWorks() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let emitterCell = CAEmitterCell()
        emitter.frame = rect
        view.layer.addSublayer(emitter)
        
        emitter.emitterShape = kCAEmitterLayerCircle
        emitter.emitterPosition = pointTap!
        
        emitter.emitterSize = rect.size
        emitterCell.contents = UIImage(named: "spark")?.cgImage
        emitterCell.birthRate = 5
        emitterCell.lifetime = 2.5
        
        emitterCell.velocity = 20.0
        
        emitterCell.emissionLongitude = .pi * -0.5
        emitterCell.emissionRange = .pi * 0.5
        
        emitter.emitterCells = [emitterCell]
    }

    func stopFireWorks() {
        emitter.removeFromSuperlayer()
    }
    
    
    
}
