//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Dwayne George on 5/29/15.
//  Copyright (c) 2015 Dwayne George. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var prevTextLocation: String? = nil //save previous text location to avoid duplicate Geo calls

class PostViewController: UIViewController {
    
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnFind: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtURL: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblQuestion: UILabel!
    
    var savePinLocation: CLLocationCoordinate2D? = nil //save geo coordinates
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // manage text fields and buttons
        txtLocation.hidden = false
        btnFind.hidden = false
        btnSubmit.hidden = true
        txtURL.hidden = true
        self.lblQuestion.text = "Where are you studying?"
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        //segue to map/tabbed view
        NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
            self.performSegueWithIdentifier("PostViewToTab", sender: self)  //go to tab view
        }
    }
    
    
    @IBAction func findOnMap(sender: AnyObject) {
        

        if txtLocation.text.isEmpty {
            NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                self.displayAlert("Please enter a valid location")  //display error
            }
            
            return
        }
        
        var pinLocation: CLPlacemark //store coordinates returned from conversion of address
        var geoCoder: CLGeocoder = CLGeocoder() //convert address to location

        if(prevTextLocation != txtLocation.text ||  prevTextLocation == nil) { //don't make duplicate requests
                prevTextLocation = txtLocation.text! //make copy of this geocode request data
                activityIndicator.startAnimating() //not certain how long this will taken start activity indicator
                
                geoCoder.geocodeAddressString(txtLocation.text, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                    if error != nil {//an error occurred getting address translation
                        NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                            self.displayAlert("error getting location: \(error)")  //display error
                        }
                    } else {
                        if let placePin = placemarks[0] as? CLPlacemark {
                            //add pin using coordinates to map
                            var pin = MKPointAnnotation()
                            pin.coordinate = placePin.location.coordinate
                            self.savePinLocation = pin.coordinate //store to use when posting to server
                            self.mapView.addAnnotation(pin)
                            self.mapView.centerCoordinate = pin.coordinate
                            self.mapView.selectAnnotation(pin, animated: true)
                            
                            //manage text fields and buttons
                            self.txtLocation.hidden = true
                            self.btnFind.hidden = true
                            self.btnSubmit.hidden = false
                            self.txtURL.hidden = false
                            self.lblQuestion.text = "What is your associated link?"
                        }
                    }
                    
                    self.activityIndicator.stopAnimating()
                    }
                )
        } else {
            println("Duplicate Geo request")
        }
    }

    @IBAction func submitLocation(sender: AnyObject) {
        
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if txtURL.text.isEmpty {
            NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                self.displayAlert("Please enter a valid URL")  //display error
            }
            
            return
        }

        if let goodURL: NSURL = NSURL(string: txtURL.text) { //validate URL
            //post to server if good
            var post = PostStudentLocation()
            
            post.postStudent(appDelegate.userInfo, mapString: txtLocation.text, mediaURL: txtURL.text, location: savePinLocation!, completionHandler: { (success, retError) -> Void in
                if success == true { //post to server was successful
                    //segue to map/tabbed view
                    NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                        self.performSegueWithIdentifier("PostViewToTab", sender: self)  //go to tab view
                    }
                    
                } else { //post to server failed
                    NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                        self.displayAlert("Post to server failed: \(retError)")  //display error
                    }
                 }
            })
            
        } else { //bad URL
            NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                self.displayAlert("URL not formatted properly: \(self.txtURL.text)")  //display error
            }
            println("URL not formatted properly: \(self.txtURL.text)")
            txtURL.text = "" //clear old text
        }
    }

        func displayAlert(message: String)
        { //display an alert message with 'ok' to dismiss
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            let actionOK = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(actionOK)
            
            self.presentViewController(alertController, animated: true, completion: nil) //display alert
            
        }
        
}
