//
//  ViewController.swift
//  location
//
//  Created by Imdad, Suleman on 7/11/18.
//  Copyright © 2018 Imdad, Suleman. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var centerView: UIView!
    var isUpdated:Bool = false
    
    private let locationManager = LocationManager.shared
    
    fileprivate let coreDataStack = CoreDataStack(modelName: "location")
    
    private var lastLocation:CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self;
        mapView.showsUserLocation = true
        startLocationUpdates()
        
        centerView.clipsToBounds = true
        centerView.layer.cornerRadius = 38
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
           plotLocations()
    }
    
    private func plotLocations(){
        
        if let locations = Location.fetchAll(context: coreDataStack.managedObjectContext) as [Location]?{
            for (index, _) in locations.enumerated() where index > 0 {
                let coordinates = [locations[index - 1].coordinate(), locations[index].coordinate()]
                mapView.add(MKPolyline(coordinates: coordinates, count: 2))
            }
            guard let coordinate = locations.last?.coordinate() else {
                return
            }
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 5000, 5000)
            mapView.setRegion(region, animated: true)
        
        }
    }
    
    
    @IBAction func zoomInCurrentLocation(_ sender: Any) {
        
        guard let lastLocation = lastLocation else {
            return
        }
        
        let region = MKCoordinateRegionMakeWithDistance(lastLocation.coordinate, 2000, 2000)
        mapView.setRegion(region, animated: true)

    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    
    private func add(location: CLLocation) {
        
        let locationObj = Location(context: coreDataStack.managedObjectContext)
        locationObj.latitude = location.coordinate.latitude
        locationObj.longitude = location.coordinate.longitude
        locationObj.timestamp = Date()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    @IBAction func handleTap(gestureReconizer: UITapGestureRecognizer) {
        if let mapView = self.view.viewWithTag(999) as? MKMapView { // set tag in IB
            // remove current annons except user location
            let annotationsToRemove = mapView.annotations.filter
            { $0 !== mapView.userLocation }
            mapView.removeAnnotations( annotationsToRemove )
            
            // add new annon
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,
                                             toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }

}

// MARK: - Map View Delegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        showPopover(annotationView: view)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        dismiss(animated: true, completion: nil)

    }
    

    func showPopover(annotationView:MKAnnotationView){

        guard let addressViewController: AddressViewController = storyboard?.instantiateViewController(withIdentifier: "popover") as? AddressViewController else {
            return
        }
        
        addressViewController.modalPresentationStyle = .popover
        addressViewController.preferredContentSize = CGSize(width: 200, height: 100)
        let popover = addressViewController.popoverPresentationController!
        popover.permittedArrowDirections = .up
        popover.delegate = self
        popover.sourceView = annotationView
        popover.sourceRect = annotationView.bounds
        addressViewController.coordinate = annotationView.annotation?.coordinate
        present(addressViewController, animated: true, completion:nil)

    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                let pin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
                pin.image = UIImage(named: "pin")
                return pin
            }
            return nil
    }
}

// MARK: - Popover Delegate
extension ViewController:UIPopoverPresentationControllerDelegate{
     func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Location Manager Delegate

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else {
                continue
            }
            if let lastLocation = lastLocation {
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.add(MKPolyline(coordinates: coordinates, count: 2))
                add(location: newLocation)
                
                if (isUpdated == false) { // runs only the first time to get the correct location zoomed
                    let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 50000, 50000)
                    mapView.setRegion(region, animated: true)
                    isUpdated = true
                }
            }
            
            lastLocation = newLocation
        }
    }
}



