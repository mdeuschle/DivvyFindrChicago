//
//  Divvy.swift
//  DivvyFindr
//
//  Created by Matt Deuschle on 2/5/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import Foundation


import CoreLocation

class Divvy
{
    //need these properties from JSON
    var name: String    = ""
    var bikes: Int      = 0
    var long: Double    = 0
    var lat: Double     = 0
    var CLCoordinate    = CLLocationCoordinate2D()
    var distance: Double = 0

    init(bikeDictionary: NSDictionary, userLocation: CLLocation)
    {
        name            = bikeDictionary["stAddress1"] as! String
        bikes           = bikeDictionary["availableBikes"] as! Int
        long            = bikeDictionary["longitude"] as! Double
        lat             = bikeDictionary["latitude"] as! Double
        distance        = userLocation.distanceFromLocation(CLLocation(latitude: lat, longitude: long))

        // cordinate from lat and long
        CLCoordinate    = CLLocationCoordinate2DMake(lat, long)
    }
}
