//
//  MainViewController.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/13/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import SwiftyJSON
import Alamofire
import FBSDKCoreKit
import FacebookCore

let timestampFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    
    return dateFormatter
}()


class MainViewController: UIViewController, EditPostVCDelegate {
    
    var userLocation: CLLocation!

    // MARK: - Properties
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView! //tableview!
    var posts = [Post]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "wics_back_6")!)
        
        configureTableView()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        navigationController!.navigationBar.barTintColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        
        LocationManager.sharedInstance.getCurrentReverseGeoCodedLocation { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
            if error != nil {
                
                self.alertMessage(message: (error?.localizedDescription)!, buttonText: "OK", completionHandler: nil)
                return
            }
            guard let _ = location else {
                return
            } 
            print(placemark?.addressDictionary?.description ?? "")
            
            let address = placemark?.addressDictionary?["FormattedAddressLines"] as! NSArray
            print(address.description)
            
            print("this is latitude: \((placemark?.location?.coordinate.latitude)!)")
            print( "this is longitude: \((placemark?.location?.coordinate.longitude)!)")
            
            if let temporaryNavigationController = self.navigationController
            {
                temporaryNavigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            }
            
            self.navigationItem.title = placemark?.locality
            self.userLocation = CLLocation(latitude: (placemark?.location?.coordinate.latitude)!, longitude: (placemark?.location?.coordinate.longitude)!)
            self.reloadTimeLine()
            
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func postEditingFinished() {
        reloadTimeLine()
    }
    
    func alertMessage(message:String,buttonText:String,completionHandler:(()->())?) {
        let alert = UIAlertController(title: "Location", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default) { (action:UIAlertAction) in
            completionHandler?()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func reloadTimeLine() {
        
        UserService.timeline(userLocation: userLocation) { (posts) in
            self.posts = posts
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.tableView.reloadData()
        }
    }
    
    func configureTableView() {
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        
        // remove separators from cells
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(reloadTimeLine), for : .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        //create the sidebar menu
    }
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        //segue to a search view to browse among events and opportunities
    }
   
    @IBAction func addButtonTapped(_ sender: UIButton) {
        //segue? to a custom cell that
    }
    
    @IBOutlet weak var myLocationLabel: UILabel!
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        LocationManager.sharedInstance.getCurrentReverseGeoCodedLocation { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
            if error != nil {
                
                self.alertMessage(message: (error?.localizedDescription)!, buttonText: "OK", completionHandler: nil)
                return
            }
            guard let _ = location else {
                return
            }
            
            print("this is latitude: \((placemark?.location?.coordinate.latitude)!)")
            print( "this is longitude: \((placemark?.location?.coordinate.longitude)!)")
            
            self.navigationItem.title = placemark?.locality
            self.userLocation = CLLocation(latitude: (placemark?.location?.coordinate.latitude)!, longitude: (placemark?.location?.coordinate.longitude)!)
            print("HERE IS THE USER'S LOCATION \(self.userLocation)")
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        
        switch indexPath.row {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostHeaderCell") as! PostHeaderCell
            cell.usernameLabel.text = post.poster.username
            cell.selectionStyle = .none
            return cell
            
        case 1: 
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostDisplayCell") as! PostDisplayCell
            cell.postTitle.text = post.title
            cell.postDate.text = post.eventDate
            cell.postLocation.text = post.location["city"]! as? String
            cell.postDescription.text = post.description
            cell.selectionStyle = .none

            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostActionCell") as! PostActionCell
            cell.delegate = self
            cell.selectionStyle = .none

            configureCell(cell, with: post)
            
            return cell
            
        default:
            fatalError("Error: unexpected indexPath.")
        }
        
        
    }
    
    func configureCell(_ cell: PostActionCell, with post: Post) {
        cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
        print("\(#function) : \(post.isLiked)")
        cell.likeButton.isSelected = post.isLiked
        cell.likeCountLabel.text = "\(post.likeCount) interested"
    }
    
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        //print(posts.count)
        //MARK: - Potential error
        return self.posts.count
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            let editVC = segue.destination as! EditPostVC
            editVC.delegate = self
        } else {
            //do smth else
        }
    }

}


extension MainViewController: PostActionCellDelegate {
    
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        // 1
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        // 2
        likeButton.isUserInteractionEnabled = false
        // 3
        let post = posts[indexPath.section]
        
        // 4
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            // 5
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            // 6
            guard success else { return }
            
            // 7
            print("\(#function): \(post.isLiked)")
            post.likeCount += !post.isLiked ? 1 : -1
            post.isLiked = !post.isLiked
            
            // 8
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
                else { return }
            
            // 9
            DispatchQueue.main.async {
                self.configureCell(cell, with: post)
            }
        }
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return PostHeaderCell.height
            
        case 1:
            return PostDisplayCell.height
            
        case 2:
            return PostActionCell.height
            
        default:
            fatalError()
        }
    }
}
