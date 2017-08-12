//
//  GraphApiVC.swift
//  WICS
//
//  Created by Rosalia Dupont on 8/7/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit

class GraphAPIVC: UITableViewController {
    
    func presentAlertControllerFor<P: GraphRequestProtocol>(_ result: GraphRequestResult<P>) {
        let alertController: UIAlertController
        switch result {
        case .success(let response):
            alertController = UIAlertController(title: "Succeeded", message: "graph request succeeded with response: \(response)", preferredStyle: .alert)
        case .failed(let error):
            alertController = UIAlertController(title: "Succeeded", message: "graph request failed with error: \(error)", preferredStyle: .alert)
        }
        present(alertController, animated: true, completion: nil)
    }
}

//--------------------------------------
// MARK: - Read Profile
//--------------------------------------

//--------------------------------------
// MARK: - Read User Events
//--------------------------------------
extension GraphAPIVC {
    /**
     Fetches the currently logged in user's list of events.
     */
    static func readEvent(path: String, completion: @escaping (Post?) -> Void) {
        
        let request = GraphRequest(graphPath: "/\(path)",
            parameters: [ "fields" : "description, place, name, start_time, end_time" ],
            httpMethod: .GET)
        request.start { _, result in
            switch result {
            case .success(let response):
                
                let dict = JSON(response.dictionaryValue ?? [:])
                print(dict)
                
               guard let title = dict["name"].string, let eventDate = dict["start_time"].string, let address = dict["place"]["location"]["street"].string, let city = dict["place"]["location"]["city"].string, let latitude = dict["place"]["location"]["latitude"].double, let longitude = dict["place"]["location"]["longitude"].double, let description = dict["description"].string
                    else { return completion(nil) }
                
                print("\(#function): My longi: \(longitude)")
                print("\(#function): My lati: \(latitude)")
                
                let trimmed = description.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
                let timeFormatter = DateFormatter()
                
                
                let fixedEventDate = eventDate.replacingOccurrences(of: "-0700", with: "")
                print("\(#function) DATE: \(fixedEventDate)")
                timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let date = timeFormatter.date(from: fixedEventDate)
                
                timeFormatter.dateStyle = .short
                timeFormatter.timeStyle = .short
                let newEventDate = timeFormatter.string(from: date!)
                
                let post = Post(title: title, eventDate: newEventDate, address: address, city: city, latitude: latitude, longitude: longitude, description: trimmed)!
                completion(post)
                
                
            case .failed(let error):
                print("Graph Request Failed: \(error)")
                completion(nil)

            }
        }
    }
}

//--------------------------------------
// MARK: - Read User Friend List
//--------------------------------------
extension GraphAPIVC {
    /**
     Fetches the currently logged in user's list of facebook friends.
     */
    @IBAction func readUserFriendList() {
        
        
        let request = GraphRequest(graphPath: "/me/friends",
                                   parameters: [ "fields" : "data" ],
                                   httpMethod: .GET)
        request.start { httpResponse, result in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
            
            self.presentAlertControllerFor(result)
        }
    }
}
