//
//  APIClient.swift
//  WICS
//
//  Created by Rosalia Dupont on 8/2/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FacebookCore
import FBSDKCoreKit

enum ApiResult {
    case success(data: AnyObject?)
    case failure(error: NSError)
}

enum HttpStatuses: Int {
    case authenticationError = 401
}

class ApiClient {
    
    static func apiCall(_ content: String, completion: @escaping (Post?) -> Void) {
        
        let baseApiUrl = "https://www.eventbriteapi.com/v3/events/" + content + "/"
        
        let header: HTTPHeaders = ["Authorization": "Bearer PWRLWUMRMO2KKGLESFOJ"]
        var venueid = ""
        Alamofire.request(baseApiUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            
            let eventjson = JSON(with: response.data!)
            venueid = eventjson["venue_id"].stringValue
            print("HEREEE " + venueid)
            
            let venueurl = "https://www.eventbriteapi.com/v3/venues/" + venueid + "/"
            
            Alamofire.request(venueurl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
                
                let venuejson = JSON(with: response.data!)
                print(venuejson)
                
                guard let title = eventjson["name"]["text"].string, let eventDate = eventjson["start"]["local"].string, let address = venuejson["address"]["localized_address_display"].string, let city = venuejson["address"]["city"].string, let lat = venuejson["latitude"].string, let lon = venuejson["longitude"].string, let description = eventjson["description"]["text"].string
                    else { return completion(nil) }
                
                //let longitude = lon.toDouble(longitude)
                guard let longitude = NumberFormatter().number(from: lon)?.doubleValue, let latitude = NumberFormatter().number(from: lat)?.doubleValue
                
                else { return completion(nil) }
                
                print("\(#function): My longi: \(longitude)")
                print("\(#function): My lati: \(latitude)")
                let trimmed = description.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
                let post = Post(title: title, eventDate: eventDate, address: address, city: city, latitude: latitude, longitude: longitude, description: trimmed)!
                completion(post)
            }

            print(eventjson)
        }
    }
    
    /*static func fbApiCall(_ eventid: String, completion: @escaping (Post?) -> Void) {
        let params = ["fields" : "data,description" ]
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: eventid, parameters: params, accessToken: AccessToken(authenticationToken:"EAAUTNa6bZCB0BAAIvejFKwZCpNVjVqHtm9ZB8TZCrcy5rf82Husxlecs2ZBpIn886hRPxXvJBOnFgTKvEb1KnihTw0v7v8JK5wP1XD6PoR2AOiQj4PPZBt5Ew9wveo2OViTdO2OBZBgfjzc0DsW6XL9RuT83hdAUftZAt3pXzk7ZALgZDZD"), httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
        graphRequest.start {
            (urlResponse, requestResult) in
            
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print("\(#function) \(responseDictionary)")
                }
            }
            completion(nil)
        }
    }*/
    
    
    
}
