//
//  ListenViewController.swift
//  Sense
//
//  Created by Bob Yuan on 2020/1/2.
//  Copyright © 2020 Bob Yuan. All rights reserved.
//

import UIKit
import Lottie

class ListenViewController: UIViewController {
    
    let animationView = AnimationView()
    
    let top = 764
    let bottom = 700

    lazy var half:Int = {
        return self.top - ((self.top - self.bottom)/10)
    }()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropDownView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hi")
        
        dropDownView.backgroundColor = .clear
    }
    
    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer) {
        dropDownView.backgroundColor = .white
        guard let recognizerView = recognizer.view else {
            return
            
        }
        if recognizer.state == .ended {
            if Int(heightConstraint.constant) > half {
                print("less")
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                    self.heightConstraint.constant = CGFloat(self.top+60)
                }) { (complete) in
                    
                }
            }
            else {
                print("greater")
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                    self.heightConstraint.constant = CGFloat(self.bottom)
                }) { (complete) in
                    self.dropDownView.smooth(count: 1, for: 0.2, withTranslation: 2)
                }
            }
        }
        let translation = recognizer.translation(in: view)
        
        if heightConstraint.constant - translation.y > CGFloat(bottom) {
            heightConstraint.constant -= translation.y
            
            
        }
        recognizer.setTranslation(.zero, in: view)
    }

    
}

extension UIView {
    
    func smooth(count : Float = 4,for duration : TimeInterval = 0.5,withTranslation translation : Float = 5) {
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}
