//
//  PostService.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/19/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    
    /*this is to create the database reference with post's information */
    
    static func create(title: String, eventDate: String, address: String, city: String, latitude: String, longitude: String, description: String, completion: @escaping (Bool?)->Void ){
        // create new post in database
        //1 this creates a user reference to current user
        let currentUser = User.current
        // 2
        let post = Post(title: title, eventDate: eventDate, address: address, city: city, latitude: latitude, longitude: longitude, description: description)
        
        //3 here we're creating the references of the places we're planning to write data to
        let rootRef = Database.database().reference()
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
        
        
        //4 here we use our class method to get an array of followerUIDs
        UserService.followers(for: currentUser) { (usersUIDs) in
            
            //5 We construct a timeline JSON object where we store our current user's uid. We need to do
            //this because when we fetch a timeline for a given user, we'll need the uid of the post in
            //order to read the post from the Post subtree.
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            // 4 We create a mutable dictionary that will store all of the data we want to write to our database. We initialize it by writing the current timeline dictionary to our own timeline because our own uid will be excluded from our follower UIDs.
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            // 5 We add our post to each of our follower's timelines.
            for uid in usersUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            // 6 We make sure to write the post we are trying to create.
            let postDict = post?.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            // 7 We write our multi-location update to our database.
            rootRef.updateChildValues(updatedData, withCompletionBlock: { (error, _) in
                
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(false)
                }
                    
                else {
                    return completion(true)
                }
            })
        }
        
        
    }
    
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
}
