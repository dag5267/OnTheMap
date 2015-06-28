//
//  PostStudentLocation.swift
//  OnTheMap
//
//  Created by Dwayne George on 6/23/15.
//  Copyright (c) 2015 Dwayne George. All rights reserved.
//

import UIKit
import MapKit

class PostStudentLocation {
    
    
    func postStudent(userInfo: AuthenticateUser.stUserInfo, mapString: String, mediaURL: String, location: CLLocationCoordinate2D, completionHandler: (success: Bool, retError: NSError?) -> Void)
    {
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //modified from Udacity API
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = "{\"uniqueKey\": \"\(userInfo.userID!)\", \"firstName\": \"\(userInfo.first_name!)\", \"lastName\": \"\(userInfo.last_name!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(location.latitude), \"longitude\": \(location.longitude)}"
        
        println(body)
        
        //build post parameters
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, retError: error) //return with error
            } else {//determine login if authentication failed or passed
                var parseError: NSError? = nil
                
                //convert JSON response to dictionary
                let jsonParseResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
                if let createDate = jsonParseResult["createdAt"] as? String { //get account information
                    completionHandler(success: true, retError: nil) //successful post
                } else {
                    let postReplyError = NSError(domain: "JSON",code: 1,userInfo: nil)
                    completionHandler(success: false, retError: postReplyError) //return with error
                }
                
            }
        }
        
        
        task.resume()
        
    }
    
}