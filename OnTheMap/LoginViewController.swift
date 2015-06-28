//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Dwayne George on 5/29/15.
//  Copyright (c) 2015 Dwayne George. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!    
    @IBOutlet weak var txtPassword: UITextField!
    
    var authFailMsg: String? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        txtEmail.text = "" //clear previous login information
        txtPassword.text = ""
    }
   
    @IBAction func btnLogin(sender: AnyObject) {        
        //create login credential object
        var loginInfo: AuthenticateUser.userLoginInfo = ["udacity": ["username": txtEmail.text, "password": txtPassword.text]]
        var Authenticate = AuthenticateUser()  //instantiate authentication object
        
        Authenticate.login(loginInfo) { success, strError, error, authFail in
            if success == true { //login was successfull
                println("login was successful")
                //segue to table tabbed view
                NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                    self.performSegueWithIdentifier("TabView", sender: self)  //go to tab view
                }
            } else { //login failed, determine if authentication failed
                
                if authFail == true {  //indicate to user that authentication has failed
                    println("Authentication failed")
                    self.authFailMsg = "Authentication failed! "
                } else { //tell user about error that occurred other than authentication
                    println("\(strError): \(error)")
                    self.authFailMsg = "\(strError): \(error)"
                }
                //display Alert view
                NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                    self.displayAlert(self.authFailMsg!)
                }
            }
        }
    }
    
    func displayAlert(message: String)
    { //display an alert message with 'ok' to dismiss
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(actionOK)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func btnSignUp(sender: AnyObject) {
        if let signUpURL = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            if UIApplication.sharedApplication().openURL(signUpURL) != true {
                println("Unable to launch link to signup URL")
            }
        }
    }
}