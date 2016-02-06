//
//  MapViewController.swift
//  DivvyFindr
//
//  Created by Matt Deuschle on 2/5/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{

    @IBOutlet weak var mapView: MKMapView!

    // make var of custom class
    var bikeObject: Divvy!

    // vars for MKPoint and LM
    let bikesAnnotation = MKPointAnnotation()
    var locationManager = CLLocationManager()

    // string to hold directions for alert
    var directions: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = bikeObject.name

        // set up LM
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true

        let location = CLLocationCoordinate2D(
            latitude: bikeObject.lat,
            longitude: bikeObject.long        )

        let span = MKCoordinateSpanMake(0.015, 0.015)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)

        // set up annotations
        bikesAnnotation.coordinate = bikeObject.CLCoordinate
        bikesAnnotation.title = bikeObject.name

        // convert number of bikes to string
        let double = bikeObject.bikes
        let stringFromDouble = "Bikes available: \(double)"

        bikesAnnotation.subtitle = stringFromDouble

        mapView.addAnnotation(bikesAnnotation)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isEqual(mapView.userLocation)
        {
            return nil
        }
        else if annotation.isEqual(bikesAnnotation)
        {
            let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.image = UIImage(named: "bikePin")
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)

            return pin
        }
        else
        {
            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)

            return pin
        }
    }


    // set up accessory action on annotation
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        locationManager.startUpdatingLocation()

        mapView.setRegion(MKCoordinateRegionMake(view.annotation!.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)

        showActionSheet()
    }

    func showActionSheet()
    {
        let alertController = UIAlertController(title: "Directions", message: self.directions, preferredStyle: .ActionSheet)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(CancelAction)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Left

        let messageText = NSMutableAttributedString(
            string: self.directions,
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSFontAttributeName: UIFont.systemFontOfSize(13.0)
            ]
        )
        alertController.setValue(messageText, forKey: "attributedMessage")
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

    // if Location did update
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.first
        if location?.verticalAccuracy < 1000 && location?.horizontalAccuracy < 1000
        {
            reverseGeocode(location!)
            locationManager.stopUpdatingLocation()
        }
    }

    func reverseGeocode(location:CLLocation)
    {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            let placemark = placemarks?.first
            _ = "\(placemark!.subThoroughfare!) \(placemark!.subThoroughfare!)\n\(placemark!.locality!)"

            // call function to locate Divvy Station
            self.findBikeNear(location)
        }
    }

    func findBikeNear(location: CLLocation)
    {
        // find divvy station
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = bikeObject.name
        request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1))
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response: MKLocalSearchResponse?, error: NSError?) -> Void in
            let mapItems = response?.mapItems
            let mapItem = mapItems?.first
            self.directions = "Go directly to \(mapItem!.name!)"

            // pass in mapItem to get directions function
            self.getDirectionsTo(mapItem!)
        }
    }

    // GET DIRECTIONS

    func getDirectionsTo(destinationItem: MKMapItem)
    {
        // current location
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destinationItem
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error: NSError?) -> Void in
            let routes = response?.routes
            let route = routes?.first

            var x = 1
            let directionsString = NSMutableString()
            for step in route!.steps
            {
                directionsString.appendString("\(x): \(step.instructions)\n")
                x++
            }
            
            // save directions in string to add to AC
            self.directions = directionsString as String
        }
    }


}
