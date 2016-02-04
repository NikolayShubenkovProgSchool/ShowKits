//
//  CatsViewController.swift
//  ShowKits
//
//  Created by Nikolay Shubenkov on 04/02/16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

import UIKit
import MapKit
//import CoreLocation

class CatsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var apiClient = APIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate  = self
        locationManager.requestWhenInUseAuthorization()
    }
    

    @IBAction func showMeTheCats(sender: AnyObject) {
        
        let radius:Double = 5
        apiClient.find("cat",
            longitude: mapView.centerCoordinate.longitude,
            latitude: mapView.centerCoordinate.latitude,
            radius: radius) { (success, failure) -> Void in
                
                print(success)
        }
    }
    
    
}

extension CatsViewController:CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            
        case .AuthorizedWhenInUse,
             .AuthorizedAlways:
            
            self.mapView.showsUserLocation = true
            
            
        default:
            print("User denied location")
        }
    }
}





