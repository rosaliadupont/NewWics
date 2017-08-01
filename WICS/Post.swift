//
//  Post.swift
//  Makestagram
//
//  Created by Rosalia Dupont on 6/28/17.
//  Copyright © 2017 Make School. All rights reserved.
//


import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post {
    // properties and initializers
    
    var key: String?
    //let imageURL: String
    //let imageHeight: CGFloat
    let title: String?
    let creationDate: Date
    let eventDate: String?
    let location: [String: Any]
    let description: String?
    let poster: User
    
    var likeCount: Int
    var isLiked = false
    
    init?(title: String?, eventDate: String?, address: String?, city: String?, latitude: Double?, longitude: Double?, description: String?) {
        if title != nil, eventDate != nil, address != nil, city != nil, longitude != nil, latitude != nil, description != nil {
            self.title = title
            self.eventDate = eventDate
            let locationDict : [String: Any] = ["address" : address ?? "",
                                "city": city ?? "",
                                "longitude": longitude ?? 0,
                                "latitude": latitude ?? 0]
            self.location = locationDict
            self.description = description
            self.creationDate = Date()
            self.poster = User.current
            self.likeCount = 0
        }
        else {
            return nil
        }
    }
    
    /*this is a property associated with the Post, im assumming 
     this will be added to the database */
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        let userDict = ["uid" : poster.uid,
                        "username" : poster.username]
        
        return ["title" : title!,
                "date_of_event" : eventDate!,
                "location" : location,
                "created_at" : createdAgo,
                "description" : description!,
                "like_count" : likeCount,
                "poster" : userDict]
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let title = dict["title"] as? String,
            let eventDate = dict["date_of_event"] as? String,
            let location = dict["location"] as? [String: Any],
            let description = dict["description"] as? String,
            let createdAgo = dict["created_at"] as? TimeInterval,
            let userDict = dict["poster"] as? [String : Any],
            let likeCount = dict["like_count"] as? Int,
            let uid = userDict["uid"] as? String,
            let username = userDict["username"] as? String
            else { return nil }
        
        
        self.title = title
        self.eventDate = eventDate
        self.location = location
        self.description = description
        self.poster = User(uid: uid, username: username)
        self.likeCount = likeCount
        
        self.key = snapshot.key
        self.creationDate = Date(timeIntervalSince1970: createdAgo)
        
    }
}
