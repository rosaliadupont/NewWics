//
//  LoginViewController.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase
import FirebaseFacebookAuthUI


typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }  
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        //this is for normal login
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        authUI.delegate = self
        
        // configure Auth UI for Facebook login
        let providers: [FUIAuthProvider] = [FUIFacebookAuth()]
        authUI.providers = providers
        
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
        
    }

}

extension LoginViewController: FUIAuthDelegate{
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        
        if let _ = error { //this is an error handler for loging in
            print("Error signing in")
            return
            
        }
        
        guard let user = user
            else { return }
        
        UserService.show(forUID: user.uid) { (user) in
            if let user = user {
                
                //handle existing user
                User.setCurrent(user, writeToUserDefaults: true)
                
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
            }
            
            else {
                // handle new user
                self.performSegue(withIdentifier: Constants.segue.toCreateUsername, sender: self)
            }
            
        }
    }
}
    

