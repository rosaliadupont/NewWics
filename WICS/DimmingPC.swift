//
//  DimmingPC.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/17/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class DimmingPC: UIPresentationController {
    //MARK: -Properties
    lazy var dimmingVC = GradientView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    //MARK: - Override Methods
    override func presentationTransitionWillBegin() {
        dimmingVC.frame = containerView!.bounds
        containerView!.insertSubview(dimmingVC, at: 0)
        
        dimmingVC.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (_) in
                self.dimmingVC.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (_) in
                self.dimmingVC.alpha = 0
            }, completion: nil)
        }
    }
}
