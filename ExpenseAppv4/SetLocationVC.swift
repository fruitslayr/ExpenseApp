//
//  SetLocationVC.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 2/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit
import MapKit

class SetLocationVC: UIViewController, MKMapViewDelegate {

    var userLocation: CLLocationCoordinate2D!
    var setLocation: MKPointAnnotation! = MKPointAnnotation()
    
    @IBOutlet weak var mapView:MKMapView!
    
    var delegate: SetLocationDelegate! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
  
        setLocation.setCoordinate(userLocation)
        mapView.addAnnotation(setLocation)
        
        var region = mapView.region as MKCoordinateRegion
        region.center = userLocation
        region.span.longitudeDelta = 0.08
        region.span.latitudeDelta = 0.08
        mapView.setRegion(region, animated: true)

        self.mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView.draggable = true
            pinView.canShowCallout = false
        } else {
            pinView.annotation = annotation
        }
        
        return pinView
    }

    override func viewWillDisappear(animated: Bool) {
        delegate.updateLocation(self, location: setLocation.coordinate)
    }
    
}

protocol SetLocationDelegate {
    func updateLocation(controller: SetLocationVC, location: CLLocationCoordinate2D)
}
