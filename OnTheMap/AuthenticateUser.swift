//
//  AuthenticateUser.swift
//  OnTheMap
//
//  Created by Dwayne George on 5/30/15.
//  Copyright (c) 2015 Dwayne George. All rights reserved.
//

import UIKit

class AuthenticateUser {
    
    struct stUserInfo { //create structure to hold login information for student
        var sessionID: String? = nil    //store login session ID
        var userID: String? = nil       //store user ID
        var first_name: String? = nil   //store student first name
        var last_name: String? = nil    // store student last name
    }
    
    
    /* Get the app delegate */
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    typealias userLoginInfo = [String: [String: String]] //create a dictionary typedef to hold user login information
    
    //function logs into Udacity site
    func login (userInfo: userLoginInfo, completionHandler: (success: Bool, errorString: String?, retError: NSError?, authFail: Bool? ) -> Void) {

        self.appDelegate.userInfo.sessionID = nil //reset sessionID
        
        var error: NSError? = nil
        
        let convJSON = NSJSONSerialization.dataWithJSONObject(userInfo, options: nil, error: &error)
        if error != nil { //handle dictionary to JSON conversion error
            completionHandler(success: false, errorString: "Failed to parse user login info into JSON", retError: error, authFail: nil)
        }
        
        //build POST request to login in and get session id
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.HTTPBody = convJSON

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // exit with error
                completionHandler(success: false, errorString: "Login error occured during POST", retError: error, authFail: nil)
            }
            //get response data
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            //determine login if authentication failed or passed
            var parseError: NSError? = nil
            
            //convert JSON response to dictionary
            let jsonParseResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
            if let account = jsonParseResult["account"] as? NSDictionary { //get account information
                if let registered = account["registered"] as? Bool { //get registration status
                    if registered == true { //user successfully logged in
                        self.appDelegate.userInfo.userID = account["key"] as? String
                        if let session = jsonParseResult["session"] as? NSDictionary { //get session information
                            if let sessionID = session["id"] as? String { //get session ID
                                self.appDelegate.userInfo.sessionID = sessionID //store session ID for later use
                                self.getUserPublicInfo() //get UserID
                            } else { //unable to get sessionID
                                completionHandler(success: false, errorString: "Session ID not found", retError: nil, authFail: true)
                            }
                        } else { // unable to get session information
                            completionHandler(success: false, errorString: "Session information not found", retError: nil, authFail: true)
                        }
                        completionHandler(success: true, errorString: nil, retError: nil, authFail: nil) //indicate successful login
                    } else { //registered == false, assume that this is a authenctication failed login
                        completionHandler(success: false, errorString: "Not registered", retError: nil, authFail: true)
                    }
                } else { //unexpected error, API returned account information but no registration statu...assume authentication failed and not connection failure because a response was returned
                    completionHandler(success: false, errorString: "Not registration information provided", retError: nil, authFail: true)
                }
            } else { //unexpected error.  convert to JSON was successfull, but data expected was not found
                completionHandler(success: false, errorString: "Expected JSON dictionary not found", retError: nil, authFail: true)
            }            
        }
        task.resume()
    }
    
    
     func getUserPublicInfo()
     { //get specific public account information for user
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var parseError: NSError? = nil
        
        let requestURL = "https://www.udacity.com/api/users/" + appDelegate.userInfo.userID!
        let request = NSMutableURLRequest(URL: NSURL(string: requestURL)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                println("Error occurred while getting public information for user: \(error)")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            //convert JSON response to dictionary
            let jsonParseResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
            if let user = jsonParseResult["user"] as? NSDictionary { //get  and store user account information
                if let last_name = user["last_name"] as? String {
                    self.appDelegate.userInfo.last_name = last_name
                }
                if let first_name = user["first_name"] as? String {
                    self.appDelegate.userInfo.first_name = first_name
                }
            }
        }
        
        task.resume()
    }
    
    
    static func logout() {
        
         //modified example code from Udacity API
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { //print error
                println("Logout error: \(error)")
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        
    }
    
    
    
}