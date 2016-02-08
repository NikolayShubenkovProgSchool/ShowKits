//
//  CatsViewController.swift
//  ShowKits
//
//  Created by Nikolay Shubenkov on 04/02/16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

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
        
        let imageView = UIImageView(frame: Constants.imageViewFrame)
        imageView.contentMode = .ScaleAspectFill
        
        photoView?.leftCalloutAccessoryView  = imageView
        photoView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        //чтобы показались кнопка и картинка
        photoView?.canShowCallout = true
        
        return photoView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let imageView   = view.leftCalloutAccessoryView as? UIImageView,
              let photoToShow = view.annotation as? Photo  else {
            return
        }
        
//        update(imageView, url: photoToShow.photoURL)
        
        imageView.updateImageWith(photoToShow)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("Show Image Detailes", sender: view.annotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let detailedPhoto = segue.destinationViewController as? PhotoDetailedViewController,
            let photo = sender as? Photo else {
                return
        }
        detailedPhoto.photo = photo
    }
    
    
    func update(imageView:UIImageView, url:String){
        guard let url = NSURL(string: url) else {
                return
        }
        
        guard let data = NSData(contentsOfURL: url) else {
            return
        }
        
        let image = UIImage(data: data)
        
        imageView.image = image
        
    }
}



//MARK: - Constants

extension CatsViewController {
    private struct Constants {
        static let AnnotationIdentifier = "PhotoAnnotationView"
        static let imageViewFrame = CGRect(x: 0, y: 0, width: 50, height:50)
    }
}

//MARK: - UIImageView Extention 

extension UIImageView {
    func updateImageWith(photo:Photo?) {
        guard let photoToApply = photo else {
            self.image = nil
            return
        }
        
        sd_setImageWithURL(NSURL(string: photoToApply.photoURL),
            placeholderImage: nil,
            options: [ .ProgressiveDownload])
        
    }
}















