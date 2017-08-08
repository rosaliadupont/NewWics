//
//  Utils.swift
//  WICS
//
//  Created by Rosalia Dupont on 8/3/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Kingfisher

class Utils {
    
    fileprivate static let dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
    
    static func stringFormattedDate(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    static func dateFromServerSrting(_ date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.date(from: date)
    }
    
    /*class AppActivityIndicator: CustomActivityIndicator {
        init(showInView mainView:UIView) {
            var images: [UIImage] = []
            for countValue in 1...7 {
                let image  = UIImage(named:"frame_\(countValue)")
                images.append(image!)
            }
            
            super.init(width:250, height: 55, images: images, backgroundColor: UIColor.loadingIndicatorBackgroundColor(), showInView: mainView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }*/
}

extension UIColor {
    static func colorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

/*extension UIImageView {
    public func app_setImageWithURL(_ url: URL, placeholderImage: UIImage? = nil) {
        kf_setImageWithURL(url, placeholderImage: placeholderImage, optionsInfo: nil)
    }
}*/
