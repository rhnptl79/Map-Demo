//
//  ViewController.swift
//  TryingMap
//
//  Created by user187410 on 1/23/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var directionBtn: UIButton!
    
    
    //Create a location manager
    let locationManager = CLLocationManager()
    
    //Create destination variable
    var destination: CLLocationCoordinate2D!
    
    //Create a Places Array
    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.showsUserLocation = true
        directionBtn.isHidden = true
        
        
        //we assign the delegate property of the location manager to be in the class
        locationManager.delegate = self
        
        //we define the accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //request for the permission to access the location
        locationManager.requestWhenInUseAuthorization()
        
        //start updating the location
        locationManager.startUpdatingLocation()
        
        //1st step is to define latitude and longitude
        let latitude: CLLocationDegrees = 43.64
        let longitude: CLLocationDegrees = -79.38
        
        //2nd Display the marker on the map
        //displayLocation(latitude: latitude, longitude: longitude, title: "Toronto City", subtitle: "You are here.")
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotation))
        map.addGestureRecognizer(uilpgr)
        
        //Add Double Tap
        addDoubleTap()
        
        //Giving the delegate of MKMapViewDelegate to this class
        map.delegate = self
        
        //add annotation for places
        //addAnnotationForPlaces()
        
        //add polyline
        //addPolyline()
        
        //add polygon
        //addPolygon()
    }
    
    
    //MARK: - Draw Route between two places
    @IBAction func drawRoute(_ sender: UIButton) {
        //1st remove all overlays from the map
        map.removeOverlays(map.overlays)
        
        //Find your Source placemark and Destination placemark
        let sourcePlacemark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        //request direction
        let directionRequest = MKDirections.Request()
        
        //assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        
        //Transporation Type
        directionRequest.transportType = .automobile
        
        //Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else { return }
            
            //Create Route
            let route = directionResponse.routes[0]
            
            //Drwaing a Polyline
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            //Define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            //self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
    }
    
    
    //MARK: - didUpdate the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        removePin()
        //print(locations.count)
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "You are here!", subtitle: "")
    }
    
    
    //MARK: - add annotation for the places
    func addAnnotationForPlaces(){
        map.addAnnotations(places)
        
        let overlays = places.map {MKCircle(center: $0.coordinate, radius: 2000)}
        map.addOverlays(overlays)
    }
    
    //MARK: - Add Polyline method
    func addPolyline()
    {
        let coordinate = places.map{$0.coordinate}
        let polyline = MKPolyline(coordinates: coordinate, count: coordinate.count)
        map.addOverlay(polyline)
    }
    
    //MARK: - Add Polygon method
    func addPolygon()
    {
        let coordinate = places.map{$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinate, count: coordinate.count)
        map.addOverlay(polygon)
    }
    
    //MARK: - Double Tap
    func addDoubleTap(){
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        removePin()
        //Add annotation
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        let annotation = MKPointAnnotation()
        annotation.title = "My Destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
        directionBtn.isHidden = false
        
    }
    
    
    //MARK: - Adding Long Press Gesture for the annotation
    @objc func addLongPressAnnotation(gestureRecognizer: UIGestureRecognizer){
        
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        //Add anotation for the coordinate
        let annotation = MKPointAnnotation()
        annotation.title = "My favorite"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
    }
    
    //MARK: - remover pin from the map
    func removePin(){
        
        for annotation in map.annotations{
            map.removeAnnotation(annotation)
        }
        //Doing the same ->  map.removeAnnotations(map.annotations)
    }

    //MARK: - Display User Location
    func displayLocation(latitude:CLLocationDegrees, longitude:CLLocationDegrees, title:String, subtitle: String) {
        
        //2nd step - define span (like a zoom level on the map )
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta:CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        
        //3rd step - define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //4th step - Define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        //5th step - set the region for the map
        map.setRegion(region, animated: true)
        
        //6th step - Add annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }
}

extension ViewController: MKMapViewDelegate{
    
    //MARK: - viewFor Annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        
        
        
        /*let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: " Drop Location ")
        pinAnnotation.animatesDrop = true
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        pinAnnotation.canShowCallout = true
        pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinAnnotation*/
        
        //Add Custom Annotation
        let pinAnnotation = map.dequeueReusableAnnotationView(withIdentifier: "Dropable Pin") ?? MKPinAnnotationView()
        pinAnnotation.image = UIImage(named: "ic_place_2x")
        pinAnnotation.canShowCallout = true
        pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinAnnotation
        
        //Cutom Marker
        /*let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "My Marker")
        annotationView.markerTintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        return annotationView*/
    }
    
    //MARK: - Callout Accesory Control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Location", message: "A nice place to visit!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:  nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Rendrer for overley func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }else if overlay is MKPolyline{
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        }else if overlay is MKPolygon{
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.yellow
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}
