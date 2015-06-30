//
//  StudentLocationInformation.swift
//  OnTheMap
//
//  Created by Dwayne George on 6/3/15.
//  Copyright (c) 2015 Dwayne George. All rights reserved.
//

import Foundation

//class used to store student location information downloaded from Udacity site
class StudentLocationInformation {
 
    typealias studentInfoDict = [String: AnyObject] //define dictionary passed from Udacity site
    var arrayStudentInfo = [studentInfoItem]() //create an array to hold all student information
    
    struct studentInfoItem { //create structure hold student location information
        var createdAt: NSDate    //holds creation date and time of record
        var firstName: String    //holds first name of student
        var lastName: String     //holds last name of student
        var latitude: Double     //holds latitude of student location
        var longitude: Double    //holds longitude of student location
        var mapString: String    //holds map string entered by student
        var mediaURL: String     //holds URL entered by student
        var objectId: String     //object id for this entry
        var uniqueKey: String    //key for this entry
        var updatedAt: NSDate    //last updated date/time
        
        init(dictItem: studentInfoDict)
        { //loop through provided dictionary adding the items to the array for later use
            
            //get and store createdAt date
            var date = dictItem["createdAt"] as! String
            let formatDate = NSDateFormatter()
            formatDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            if let convDate = formatDate.dateFromString(date) {
                self.createdAt = convDate
            } else {
                self.createdAt = NSDate() //just use current date
               println("unable to convert createAt date: \(date)")
            }
            
            //get and store updateAt date
            date = dictItem["updatedAt"] as! String
            if let convDate = formatDate.dateFromString(date) {
                self.updatedAt = convDate
            } else {
                println("unable to convert updatedAt date: \(date)")
                self.updatedAt = NSDate() //just use current date
            }
            
            //get and store firstName
            if let strData = dictItem["firstName"] as? String {
                self.firstName = strData
            } else {
                println("Warning: firstName not given")
                self.firstName = ""
            }
            
            //get and store lastName
            if let strData = dictItem["lastName"] as? String {
                self.lastName = strData
            } else {
                println("Warning: lastName not given")
                self.lastName = ""
            }
            
            //get and store mapString
            if let strData = dictItem["mapString"] as? String {
                self.mapString = strData
            } else {
                println("Warning: mapString not given")
                self.mapString = ""
            }
            
            //get and store mediaURL
            if let strData = dictItem["mediaURL"] as? String {
                self.mediaURL = strData
            } else {
                println("Warning: mediaURL not given")
                self.mediaURL = ""
            }
            
            //get and store objectId
            if let strData = dictItem["objectId"] as? String {
                self.objectId = strData
            } else {
                println("Warning: objectId not given")
                self.objectId = ""
            }
            
            //get and store uniqueKey
            if let strData = dictItem["uniqueKey"] as? String {
                self.uniqueKey = strData
            } else {
                println("Warning: uniqueKey not given")
                self.uniqueKey = ""
            }
            
            //get and store latitude
            if let doubleData = dictItem["latitude"] as? Double {
                self.latitude = doubleData
            } else {
                println("Warning: latitude not given")
                self.latitude = 34.0
            }
            
            //get and store longitude
            if let doubleData = dictItem["longitude"] as? Double {
                self.longitude = doubleData
            } else {
                println("Warning: longitude not given")
                self.longitude = 86.0
            }
        }
    }
    
    func addStudentInfo(info: studentInfoItem) {
        //add structure to array
        arrayStudentInfo.append(info)
    }
    
    func getStudentLocationInfo(completionHandler: (error: NSError?) -> Void)
    {
        let recordLimit = 100 //limit download to 100 entries
        
        //modified example code from Udacity API
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=\(recordLimit)")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(error: error)
                println("Error getting student information")
            } else {
                
                //populate structure with alll student data
                let parseResults = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                if let studentLocationItems = parseResults["results"] as? [studentInfoDict] { //get array of students
                    self.arrayStudentInfo.removeAll(keepCapacity: false) //delete any old student items in the array
                    for nextStudentLocation in studentLocationItems { //add all students to array
                        self.addStudentInfo(studentInfoItem(dictItem: nextStudentLocation)) //add this student
                    }
                    completionHandler(error: nil); //complete with no errors
                }
            }
        }
        task.resume()
    }
}