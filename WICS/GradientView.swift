//
//  GradientView.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/17/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        
        let components: [CGFloat] = [0, 0, 0, 0.3, 0, 0, 0, 0.7]
        
        let locations: [CGFloat] = [0, 1]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        let radius = max(x ,y)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
