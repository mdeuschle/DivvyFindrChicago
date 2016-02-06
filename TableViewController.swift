//
//  TableViewController.swift
//  DivvyFindr
//
//  Created by Matt Deuschle on 2/5/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import UIKit
import MapKit

var bikes = [NSDictionary]()
var bikeObjects = [Divvy]()

var isSearchActive: Bool = false
var filtered = [Divvy]()

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate
{

    let locationManager = CLLocationManager()

    // string to hold current location
    var currentLocation = CLLocation()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        self.title = "Divvy Findr"

        // call function to load bikes
        loadBikes()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    // find current location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = locations.first!
    }


    func loadBikes()
    {

        // pull from JSON
        let url = NSURL(string: "http://www.divvybikes.com/stations/json/")!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            do{
                // create Dic
                let bikesDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary

                bikes = bikesDictionary.objectForKey("stationBeanList") as! [NSDictionary]
                //                print(bikes.first)

                //Added
                for dict: NSDictionary in bikes {
                    let bikeObject: Divvy = Divvy(bikeDictionary: dict, userLocation: self.currentLocation)
                    bikeObjects.append(bikeObject)
                }

                bikeObjects.sortInPlace({ $0.distance < $1.distance})

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }

            catch let error as NSError{
                print("jsonError: \(error.localizedDescription)")
            }

            //loads tableview without having to scroll the cells to get the intial data pull
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()}
        }
        task.resume()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        filtered.removeAll()

        for divvyObj in bikeObjects {
            if divvyObj.name.rangeOfString(self.searchBar.text!) != nil {
                filtered.append(divvyObj)
            }
        }

        if searchText == "" {
            isSearchActive = false
        }
        else {
            isSearchActive = true
        }
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID") as! TableViewCell

        if isSearchActive {

            cell.cellTitle.text = filtered[indexPath.row].name
            cell.numberOfBikes.text = "Available Bikes: \(filtered[indexPath.row].bikes)"

            let meters = filtered[indexPath.row].distance
            let miles = meters / 1609.344
            let result = String(format: "Distance: %4.1f Miles", miles)
            cell.distanceLabel.text = result

            cell.cellImage.image = UIImage(imageLiteral: "map")
        }
        else {
            cell.cellTitle.text = bikeObjects[indexPath.row].name
            cell.numberOfBikes.text = "Available Bikes: \(bikeObjects[indexPath.row].bikes)"

            let meters = bikeObjects[indexPath.row].distance
            let miles = meters / 1609.344
            let result = String(format: "Distance: %4.1f Miles", miles)
            cell.distanceLabel.text = result

            cell.cellImage.image = UIImage(imageLiteral: "map")
        }
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filtered.count
        }
        else {
            return bikes.count
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let indexPath = tableView.indexPathForSelectedRow!
        let dvc = segue.destinationViewController as! MapViewController
        
        // pass along custom class objects
        dvc.bikeObject = bikeObjects[indexPath.row]
    }
}




