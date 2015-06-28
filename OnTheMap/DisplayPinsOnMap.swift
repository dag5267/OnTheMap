//
//  DisplayPinsOnMap.swift
//  OnTheMap
//
//  Created by Dwayne George on 6/17/15.
//  Copyright (c) 2015 Dwayne George. All rights reserved.
//

import MapKit

class DisplayPinsOnMap: NSObject, MKAnnotation
{ //class to handle objects on map
    let title: String
    let nameOfLocation: String
    let coordinate: CLLocationCoordinate2D
    let subtitle: String
    
    init(title: String, nameOfLocation: String, coordinate: CLLocationCoordinate2D, subtitle: String) {
      //initialize class to provided values
        self.title = title
        self.subtitle = subtitle
        self.nameOfLocation = nameOfLocation
        self.coordinate = coordinate
        super.init()
    }
    

}
