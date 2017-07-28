//
//  NearbyViewController.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/25/17.
//  Copyright © 2017 Make School. All rights reserved.
//
import Foundation
import UIKit
import MapKit
import CoreLocation


class NearbyViewController: UIViewController {

    func alertMessage(message:String,buttonText:String,completionHandler:(()->())?) {
        let alert = UIAlertController(title: "Location", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default) { (action:UIAlertAction) in
            completionHandler?()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        LocationManager.sharedInstance.getCurrentReverseGeoCodedLocation { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
            if error != nil {
                
                self.alertMessage(message: (error?.localizedDescription)!, buttonText: "OK", completionHandler: nil)
                return
            }
            guard let _ = location else {
                return
            }
            /*print(placemark?.administrativeArea ?? "")
            print(placemark?.name ?? "")
            print(placemark?.country ?? "")
            print(placemark?.areasOfInterest ?? "")
            print(placemark?.isoCountryCode ?? "")
            print(placemark?.location ?? "")
            print(placemark?.locality ?? "")
            print(placemark?.subLocality ?? "")
            print(placemark?.postalCode ?? "")
            print(placemark?.timeZone ?? "")*/
            print(placemark?.addressDictionary?.description ?? "")
            
            let address = placemark?.addressDictionary?["FormattedAddressLines"] as! NSArray
            print(address.description)
            
            print("this is latitude: \((placemark?.location?.coordinate.latitude)!)")
            print( "this is longitude: zs\((placemark?.location?.coordinate.longitude)!)")
        }
        
        //HERE YOU WILL GET CURRENT LOCATION OF THE USER
        //EVERY TIME THE USER CLIKS ON THE PIN BUTTON THAT VIEWLOADS THIS VC, A NEW CURRENT LOCATION WILL BE FETCHED FROM GOOGLE PLACES API

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    //THEN SET THE TABLE VIEW AND EVERYTHING SAME AS MAINVIEW CONTROLLER, THE DIFFERENCE IS THAT THE ONCE THE POST ARRAY IS GOTTEN, THE POST ARRAY WILL BE REARRANGED BASED ON THE LOCATION FROM THE CURRENTUSER USING GOOGLE PLACES API

}
