//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Dwayne George on 6/2/15.
//  Copyright (c) 2015 Dwayne George. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var viewMap: MKMapView!
    
    var downLoadFailMsg: String? = nil
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewMap.delegate = self
        loadMapView()//get intial student information
    }
    
    @IBAction func refreshMapView(sender: AnyObject) {
        loadMapView()
    }
    
    @IBAction func logout(sender: AnyObject) {
        AuthenticateUser.logout()
        //go back to login screen
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadMapView() {
        //refresh student information array and update view
        appDelegate.studentLocationInformation.getStudentLocationInfo() { (error) in
            if error == nil { //getting student location information was successful
                dump(self.appDelegate.studentLocationInformation.arrayStudentInfo)
                
                //add items to map
                for studentObj in self.appDelegate.studentLocationInformation.arrayStudentInfo
                { // create pin
                    let studentPin = DisplayPinsOnMap(title: "\(studentObj.firstName) \(studentObj.lastName)", nameOfLocation: studentObj.mediaURL,
                        coordinate: CLLocationCoordinate2D(latitude: studentObj.latitude, longitude: studentObj.longitude), subtitle: studentObj.mediaURL)
                    
                        self.viewMap.addAnnotation(studentPin) //place pin on map
                }
            } else {
                self.downLoadFailMsg = "Unable to download student information"
                //show Alert view
                NSOperationQueue.mainQueue().addOperationWithBlock { //switch to main thread
                    self.displayAlert(self.downLoadFailMsg!)  //display error
                }
                println("\(error)")
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
    
    
    func mapView(aMapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            let reuseIdentifier = "mapPin" // make reusable
            
            var pin = aMapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
            if pin == nil { //create custom annotation if it doesn't exist
                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                pin!.canShowCallout = true
                pin!.animatesDrop = true
                pin!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            }
            else {
                pin!.annotation = annotation //reuse if it already exists
            }
            
            return pin
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            if let goodURL: NSURL = NSURL(string: annotationView.annotation.subtitle!) { //validate URL
                UIApplication.sharedApplication().openURL(goodURL) //launch browser to URL if it exists
            } else {
                println("Bad URL \(annotationView.annotation.subtitle)")
            }
            
        }
    }
}
