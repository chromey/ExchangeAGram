//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Christian Romeyke on 02/12/14.
//  Copyright (c) 2014 Christian Romeyke. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fbLoginView.delegate = self
        fbLoginView.readPermissions = ["public_profile", "publish_actions"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mapViewButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("mapSegue", sender: self)
    }
    
    // FBLoginViewDelegate
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("loginViewShowingLoggedInUser")
        profileImageView.hidden = false
        nameLabel.hidden = false
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        println("loginViewFetchedUserInfo")
        println(user)
        nameLabel.text = user.name
        let userImageUrl = NSURL(string: "https://graph.facebook.com/\(user.objectID)/picture?type=small")
        let imageData = NSData(contentsOfURL: userImageUrl!)
        profileImageView.image = UIImage(data: imageData!)
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("loginViewShowingLoggedOutUser")
        profileImageView.hidden = true
        nameLabel.hidden = true
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("Error: \(error.localizedDescription)")
    }

}
