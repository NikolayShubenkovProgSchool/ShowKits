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
    var photos:[Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        mapView.delegate = self
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
                
                self.photos = success
                self.updateMapView()
                
        }
    }
    
    func updateMapView(){
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        if self.photos != nil {
            self.mapView.addAnnotations(self.photos!)
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

extension CatsViewController:MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let photoToShow = annotation as? Photo else {
            return nil
        }
        
        var photoView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationIdentifier)
        
        if photoView == nil {
            photoView = MKPinAnnotationView(annotation: annotation,
                reuseIdentifier: Constants.AnnotationIdentifier)
        }
        
        photoView?.leftCalloutAccessoryView  = UIImageView(frame: Constants.imageViewFrame)
        photoView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        //чтобы показались кнопка и картинка
        photoView?.canShowCallout = true
        
        return photoView
    }
}



//MARK: - Constants

extension CatsViewController {
    private struct Constants {
        static let AnnotationIdentifier = "PhotoAnnotationView"
        static let imageViewFrame = CGRect(x: 0, y: 0, width: 50, height:50)
    }
}

















