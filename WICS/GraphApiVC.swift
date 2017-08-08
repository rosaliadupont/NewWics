//
//  GraphApiVC.swift
//  WICS
//
//  Created by Rosalia Dupont on 8/7/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

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
    static func readEvent(path: String, completion: @escaping (Bool) -> Void) {
        
        let request = GraphRequest(graphPath: "/\(path)",
            parameters: [ "fields" : "data, description" ],
            httpMethod: .GET)
        request.start { _, result in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
                completion(true)
            case .failed(let error):
                print("Graph Request Failed: \(error)")
                completion(false)
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
