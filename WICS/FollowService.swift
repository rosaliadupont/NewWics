//
//  FollowService.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {
    
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : true,
                          "following/\(currentUID)/\(user.uid)" : true]
        
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            
            /*this is for whenever a user is followed by current user, all of the followee's
             posts are added to the current user timeline */
            
            // 1 first we get all of the posts from the user followed
            UserService.posts(for: user) { (posts) in
                // 2 then we have to get all of the keys of the followed user's posts
                let postKeys = posts.flatMap { $0.key }
                
                // 3 We build a multiple location update using a dictionary that adds each of the followee's post to our timeline.
                var followData = [String : Any]()
                let timelinePostDict = ["poster_uid" : user.uid]
                postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                // 4 We write the dictionary to our database.
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    // 5 We return success based on whether we received an error.
                    success(error == nil)
                })
            }
        }
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                          "following/\(currentUID)/\(user.uid)" : NSNull()]
        
        // 2 we write our new relationship to firebase
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            // 3 we return whether the update was successful
            // 1 first we get all of the posts from the user followed
            UserService.posts(for: user) { (posts) in
                // 2 then we have to get all of the keys of the followed user's posts
                
                var unfollowData = [String : Any]()
                let postsKeys = posts.flatMap { $0.key }
                
                // 3 We build a multiple location update using a dictionary that adds each of the followee's post to our timeline.
                postsKeys.forEach {
                    // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
                    unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
                }
                
                // 4 We write the dictionary to our database.
                ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    // 5 We return success based on whether we received an error.
                    success(error == nil)
                })
            }
            
        }
    }
    
    //this function will let us directly set the follow relationship to the
    //current user(easily sets the follow relationship betweeen two users
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) ->Void){
        
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("followers").child(user.uid)
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String: Bool] {
                
                completion(true)
            }else{
                completion(false)
            }
        })
        
    }
    
}
