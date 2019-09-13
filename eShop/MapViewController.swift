//
//  MapViewController.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/13/19.
//  Copyright © 2019 SE. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapOutlet: MKMapView!
    
    var latitude :CLLocationDegrees?
    var longitude :CLLocationDegrees?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let latitude: CLLocationDegrees = self.latitude ?? 0
        let longitude: CLLocationDegrees = self.longitude ?? 0
        let latDelta: CLLocationDegrees = 0.0275
        let longDelta: CLLocationDegrees = 0.0275
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinates, span: span)
        mapOutlet.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapOutlet.addAnnotation(annotation)
    }

}
