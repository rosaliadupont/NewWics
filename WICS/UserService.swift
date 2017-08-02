//
//  UserService.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth.FIRUser
import FirebaseDatabase
import CoreLocation
import MapKit

//this struct contains all of the user-related networking
//code here


struct UserService {
    
    static func show( forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        
        let userAttrs = ["username": username]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            //we dispatch to wait for all of the aynchronous code to complete before calling our copletion handler on the main thread
            let dispatchGroup = DispatchGroup()
            
            let posts: [Post] = snapshot.reversed().flatMap {
                guard let post = Post(snapshot: $0)
                    else { return nil }
                
                dispatchGroup.enter()
                
                LikeService.isPostLiked(post) { (isLiked) in
                    post.isLiked = isLiked
                    dispatchGroup.leave()
                }
                
                return post
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts)
                
            })
            
        })
    }
    
    static func followers(for user: User, completion: @escaping ([String]) -> Void) {
        let followersRef = Database.database().reference().child("followers").child(user.uid)
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
    }
    
    
    
    
    // MARK: - Potential error
    /* this is called from mainviewcontroller */
    static func timeline(userLocation: CLLocation, completion: @escaping ([Post]) -> Void) {
        let currentUser = User.current

        let timelineRef = Database.database().reference().child("timeline").child(currentUser.uid)
        timelineRef.observeSingleEvent(of: .value, with: { (snapshot) in

            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            struct PostCoordinate {
                var postID: String = ""
                var coordinate:CLLocation = CLLocation()
            }
 
            var posts = [Post]()
            let maxRadius: CLLocationDistance = 40233.6
            
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                
                dispatchGroup.enter()
                
                PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
                    if let post = post {
                        let latitude = post.location["latitude"]!
                        let longitude =  post.location["longitude"]!
                        
                        let postLocation: CLLocation = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                        
                        let distanceFromPost = userLocation.distance(from: postLocation)
                        if maxRadius >= distanceFromPost {
                            posts.append(post)
                        }
                        
                    }
                    dispatchGroup.leave()
                }
            }
            
            
            dispatchGroup.notify(queue: .main, execute: {

                completion(posts.sorted(by: { $0.0.eventDate! < $0.1.eventDate! }))
            })
        })
    }
    
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        // 1
        let ref = Database.database().reference().child("users")
        
        // 2
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            // 3
            let users =
                snapshot
                    .flatMap(User.init)
                    .filter { $0.uid != currentUser.uid }
            
            // 4
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                
                // 5
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    dispatchGroup.leave()
                }
            }
            
            // 6
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }
    
    static func following(for user: User = User.current, completion: @escaping ([User]) -> Void) {
        // 1
        let followingRef = Database.database().reference().child("following").child(user.uid)
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // 2
            guard let followingDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            // 3
            var following = [User]()
            let dispatchGroup = DispatchGroup()
            
            for uid in followingDict.keys {
                dispatchGroup.enter()
                
                show(forUID: uid) { user in
                    if let user = user {
                        following.append(user)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            // 4
            dispatchGroup.notify(queue: .main) {
                completion(following)
            }
        })
    }
    
    static func observeChats(for user: User = User.current, withCompletion completion: @escaping (DatabaseReference, [Chat]) -> Void) -> DatabaseHandle {
        let ref = Database.database().reference().child("chats").child(user.uid)
        
        return ref.observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(ref, [])
            }
            
            let chats = snapshot.flatMap(Chat.init)
            completion(ref, chats)
        })
    }
}

