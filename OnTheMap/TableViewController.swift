//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Dwayne George on 6/2/15.
//  Copyright (c) 2015 Dwayne George. All rights reserved.
//

import UIKit
import MapKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var downLoadFailMsg: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { //display table items
        
        let cellReuseId = "StudentIdCell"
        
        let studentObj = appDelegate.studentLocationInformation.arrayStudentInfo[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseId) as! UITableViewCell
        cell.textLabel!.text = "\(studentObj.firstName) \(studentObj.lastName)"
        cell.imageView!.image = UIImage(named: "postPin")

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return appDelegate.studentLocationInformation.arrayStudentInfo.count  //number of student info
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let studentObj = appDelegate.studentLocationInformation.arrayStudentInfo[indexPath.row]
        
        if let goodURL: NSURL = NSURL(string: studentObj.mediaURL) { //validate URL
            UIApplication.sharedApplication().openURL(goodURL) //launch browser to URL if it exists
        } else {
            println("Bad URL \(studentObj.mediaURL)")
        }
    }
    
    @IBAction func refreshTableView(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
            self.refreshActivityIndicator.startAnimating() //show activity monitor while refreshing
        }
        
        //refresh student information array and update view
        appDelegate.studentLocationInformation.getStudentLocationInfo() { (error) in
            if error == nil { //getting student location information was successful
                dump(self.appDelegate.studentLocationInformation.arrayStudentInfo)
                NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                    self.tableView.reloadData() //reload student information
                }
            } else {
                self.downLoadFailMsg = "Unable to download student information"
                //show Alert view
                NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                    self.displayAlert(self.downLoadFailMsg!)  //display error
                }
                println("\(error)")
            }
            NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                self.refreshActivityIndicator.stopAnimating() //show activity monitor while refreshing
            }

        }
    }
    
    func displayAlert(message: String)
    { //display an alert message with 'ok' to dismiss
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(actionOK)
        
        self.presentViewController(alertController, animated: true, completion: nil) //display alert
    }
    
    @IBAction func logout(sender: AnyObject) {
    
        AuthenticateUser.logout()
        self.dismissViewControllerAnimated(true, completion: nil) //go back to login screen
    }
}