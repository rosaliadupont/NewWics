//
//  AddressDecoder.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/24/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMapsBase
import GooglePlaces

protocol AddressGeocodeDelegateProtocol {
    func coordinateFound(coordinate: CLLocationCoordinate2D)
    func coordinateNotFound()
}

protocol AddressReverseGeocodeDelegateProtocol {
    func addressFound(address: String?)
    func addressNotFound()
}

class AddressDecoder {
    
    var geocodeDelegate: AddressGeocodeDelegateProtocol?
    var reverseGeocodeDelegate: AddressReverseGeocodeDelegateProtocol?
    
    func decodeAddress(address: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
            if let placemark = placemarks?[0] {
                let coordinate = (placemark.location?.coordinate)!
                self.geocodeDelegate?.coordinateFound(coordinate: coordinate)
            } else {
                self.geocodeDelegate?.coordinateNotFound()
            }
        })
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: Error?) in
            if error != nil {
                self.reverseGeocodeDelegate?.addressNotFound()
            }
            
            guard let marks = placemarks else {
                self.reverseGeocodeDelegate?.addressNotFound()
                return
            }
            
            if marks.count > 0 {
                let mark = marks[0]
                var address = ""
                var noRoad = true
                
                if let number = mark.subThoroughfare {
                    if number.contains("–") {
                        noRoad = true
                    } else {
                        noRoad = false
                        address.append(number)
                    }
                }
                if let road = mark.thoroughfare {
                    if !noRoad {
                        address.append(" \(road)")
                    }
                }
                if let town = mark.locality {
                    if !noRoad {
                        address.append(", \(town)")
                    } else {
                        address.append("\(town)")
                    }
                }
                if let state = mark.administrativeArea {
                    address.append(", \(state)")
                }
                
                self.reverseGeocodeDelegate?.addressFound(address: address)
            } else {
                self.reverseGeocodeDelegate?.addressNotFound()
            }
        }
        
    }
}
