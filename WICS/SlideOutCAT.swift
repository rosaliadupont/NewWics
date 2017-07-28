//
//  SlideOutCAT.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/17/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class SlideOutCAT: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromView = transitionContext.view(forKey: .from) {
            
            let containerView = transitionContext.containerView
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, animations: {
                fromView.center.y -= containerView.bounds.size.height
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: {
                finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}

