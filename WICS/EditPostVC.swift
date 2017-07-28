//
//  EditPostVC.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/14/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import MapKit


 protocol EditPostVCDelegate: class {
    func postEditingFinished()
}

class EditPostVC: UIViewController, SearchViewControllerDelegate {
    
    var city: String
    var longitude: String
    var latitude: String

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    weak var delegate: EditPostVCDelegate? 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   //required init means that all subclasses must use the init as well
    required init?(coder aDecoder: NSCoder) {
        
        self.city = ""
        self.longitude = ""
        self.latitude = ""
        
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
        
        
    }
    
    
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var locationField: UIButton!
    @IBOutlet weak var descriptionField: UITextField!
    
    
    var isEditingPost: Bool = false
    
    func sendAddress(placemark: MKPlacemark) {
        locationField.setTitleColor(.black, for: .normal)
        locationField.setTitle(placemark.title, for: .normal)
        city = placemark.locality!
        latitude = placemark.coordinate.latitude.description
        longitude = placemark.coordinate.longitude.description
        print("\(#function) \(latitude)")
        print("\(#function) \(longitude)")
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let title = titleField.text else { return }
        guard let eventDate = dateField.text else { return }
        guard let address = locationField.titleLabel?.text else { return }
        guard let description = descriptionField.text else { return }
        
        PostService.create(title: title, eventDate: eventDate, address: address, city: city, latitude: latitude, longitude: longitude, description: description, completion: { (succeeded) in
            
            if succeeded! {
                //DispatchQueue.main.async {
                    self.dismiss(animated: true)
                
            }
            else {
                print("timeline was not uploaded correctly after user hit done for posting")
                //DispatchQueue.main.async {
                    self.dismiss(animated:true)
                
            }
            self.delegate?.postEditingFinished()
        })
       
        //spinner
        
        if !isEditingPost {
            //
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLocation" {
            let searchVC = segue.destination as! SearchViewController
            searchVC.delegate = self
        } else {
            //do smth else
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true) //check if this is okay
    }
    
}



extension EditPostVC: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        //the way it is presented such as dimming the below view controller
        
        return DimmingPC(presentedViewController: presented, presenting: presenting)
        
    }//this return a controller
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //the animation to present the controller such as popping up 
        
        return BounceCAT()

    }//returns action
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //the animation to dismiss the controller, this gets called when the view controller is dimissed
        return SlideOutCAT()
        
    }//return action
    
    
}
