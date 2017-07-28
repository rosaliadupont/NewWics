//
//  BounceCAT.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/14/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class BounceCAT: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toVC = transitionContext.viewController(forKey: .to), let toView = transitionContext.view(forKey: .to) {
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toVC)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeCubic, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.334){
                    toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.334, relativeDuration: 0.333) {
                    toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.66, relativeDuration: 0.333) {
                    toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
