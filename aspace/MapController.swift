//
//  ViewController.swift
//  aspace
//
//  Created by Fedor Paretsky on 10/1/18.
//  Copyright © 2018 aspace, Inc. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import Mapbox
import MapboxGeocoder
import CircleMenu
import SwiftyJSON
import Alamofire
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import GooglePlaces
import TwicketSegmentedControl
import AlamofireObjectMapper
import PMSuperButton
import CardParts
import LGButton
import Async
import Intercom
import SwiftMessages

class MapController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate, TwicketSegmentedControlDelegate  {
    
    var locationManager: CLLocationManager!
    
    let cellPercentWidth: CGFloat = 0.7
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var whereToButton: LGButton!
    @IBOutlet weak var directionsController: UIView!
    @IBOutlet weak var helpButton: LGButton!
    var segmentedControl: TwicketSegmentedControl!
    var directionsViewController: DirectionsViewController!
    
    var currLocationButton: UIButton!
    
    var initMapLocation = false
    
    var currentLat : Double!
    var currentLng : Double!
    
    var currLocationEnabled = false
    
    let geocoder = Geocoder(accessToken: "pk.eyJ1IjoiZmVkb3ItYXNwYWNlIiwiYSI6ImNqbXJ6Zzc4NjFxdzYzcHFjYmNrb2Q2MGUifQ.mltUs2Zs9ufl4IOhHbD8BA")
    
    var directionsRoute: Route?
    
    var viewingRoute = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: MAP VIEW INIT
        mapView.delegate = self
        mapView.isRotateEnabled = false;
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
        
        //MARK: WHERE TO BUTTON INIT
        var whereToButtonPressedGesture = UITapGestureRecognizer()
        whereToButtonPressedGesture = UITapGestureRecognizer(target: self, action: #selector(MapController.whereToPressed(_:)))
        whereToButtonPressedGesture.numberOfTapsRequired = 1
        whereToButtonPressedGesture.numberOfTouchesRequired = 1
        whereToButton.addGestureRecognizer(whereToButtonPressedGesture)
        whereToButton.isUserInteractionEnabled = true
        
        //MARK: HELP BUTTON INIT
        var helpPressedGesture = UITapGestureRecognizer()
        helpPressedGesture = UITapGestureRecognizer(target: self, action: #selector(MapController.helpPressed(_:)))
        helpPressedGesture.numberOfTapsRequired = 1
        helpPressedGesture.numberOfTouchesRequired = 1
        helpButton.addGestureRecognizer(helpPressedGesture)
        helpButton.isUserInteractionEnabled = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let titles = ["Park & Bike", "Park & Walk", "Just Park"]
        let frame = CGRect(x: 0, y: mapView.frame.height-120, width: view.frame.width, height: 40)
        segmentedControl = TwicketSegmentedControl(frame: frame)
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        segmentedControl.isHidden = true
        segmentedControl.sliderBackgroundColor = UIColor(red:0.24, green:0.77, blue:1.00, alpha:1.0)
        
        mapView.addSubview(segmentedControl)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        
        self.view.addGestureRecognizer(tap)
        
        //        currLocationButton = UIButton(type: .custom)
        //        currLocationButton.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        //        currLocationButton.layer.cornerRadius = 0.5 * currLocationButton.bounds.size.width
        //        currLocationButton.clipsToBounds = true
        //        currLocationButton.setImage(UIImage(named:"curr_loc_disabled"), for: .normal)
        //        currLocationButton.backgroundColor = UIColor.white
        //        currLocationButton.addTarget(self, action: #selector(currLocationButtonPressed), for: .touchUpInside)
        //
        //        mapView.addSubview(currLocationButton)
        //
        //        currLocationButton.translatesAutoresizingMaskIntoConstraints = false
        //        currLocationButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        //        currLocationButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
        //
        //        currLocationButton.contentVerticalAlignment = .fill
        //        currLocationButton.contentHorizontalAlignment = .fill
        //        currLocationButton.imageEdgeInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
        
        directionsViewController = (self.storyboard?.instantiateViewController(withIdentifier: "DirectionsViewController") as! DirectionsViewController)
        directionsViewController.view.frame = directionsController.bounds
        directionsController.addSubview(directionsViewController.view)
        addChild(directionsViewController)
        directionsViewController.didMove(toParent: self)
        directionsController.isHidden = true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {return}
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate {
            if (!initMapLocation) {
                mapView.setCenter(CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude), zoomLevel: 15, animated: false)
                initMapLocation = true
            }
            currentLat = locValue.latitude
            currentLng = locValue.longitude
            if (currLocationEnabled) {
                moveMapToLatLng(latitude: currentLat, longitude: currentLng)
            }
        } else {
            if (!initMapLocation) {
                mapView.setCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0), zoomLevel: 15, animated: false)
                initMapLocation = true
            }
            if (currLocationEnabled) {
                moveMapToLatLng(latitude: currentLat, longitude: currentLng)
            }
        }
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    @objc func hideKeyBoard(sender: UITapGestureRecognizer? = nil){
        view.endEditing(true)
    }
    
    private func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) -> Bool {
        return true
    }
    
    @objc func currLocationButtonPressed() {
        currLocationEnabled = !currLocationEnabled;
        if (currLocationEnabled) {
            currLocationButton.setImage(UIImage(named: "curr_loc_enabled"), for: UIControl.State.normal)
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: true)
        } else {
            mapView.showsUserLocation = false
            mapView.setUserTrackingMode(.none, animated: false)
            currLocationButton.setImage(UIImage(named: "curr_loc_disabled"), for: UIControl.State.normal)
        }
    }
    
    func moveMapToLatLng(latitude: Double, longitude: Double, fromDistance: Double = 1250) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let camera = MGLMapCamera(lookingAtCenter: center, fromDistance: fromDistance, pitch: 0, heading: 0)
        self.mapView.setCamera(camera, withDuration: 2, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
    }
    
    func getRoute(fromLat: Double, fromLng: Double, toLat: Double, toLng: Double, routeType: String) {
        let group = DispatchGroup()
        
        let driveBikeUrl = getRoutingURL(routeType: "get_drive_bike_route", originLat: fromLat, originLng: fromLng, destLat: toLat, destLng: toLng, sessionStarting: "0", accessCode: "07fa1e185317402c043cff15c13da745", deviceId: "e2fad51a-da1c-40b1-9c7a-e8a12fbb3cb5")
        
        let driveWalkUrl = getRoutingURL(routeType: "get_drive_walk_route", originLat: fromLat, originLng: fromLng, destLat: toLat, destLng: toLng, sessionStarting: "0", accessCode: "07fa1e185317402c043cff15c13da745", deviceId: "e2fad51a-da1c-40b1-9c7a-e8a12fbb3cb5")
        
        let driveDirectUrl = getRoutingURL(routeType: "get_drive_direct_route", originLat: fromLat, originLng: fromLng, destLat: toLat, destLng: toLng, sessionStarting: "0", accessCode: "07fa1e185317402c043cff15c13da745", deviceId: "e2fad51a-da1c-40b1-9c7a-e8a12fbb3cb5")
        
        group.enter()
        var driveBikeResponse: DriveBikeResponse!
        var driveWalkResponse: DriveBikeResponse!
        var driveDirectResponse: DriveBikeResponse!
        Alamofire.request(driveBikeUrl, method: .post).responseDriveBikeResponse { response in
            if let driveBike = response.result.value {
                driveBikeResponse = driveBike
                group.leave()
            } else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
            }
        }
        group.enter()
        Alamofire.request(driveWalkUrl, method: .post).responseDriveBikeResponse { response in
            if let driveWalk = response.result.value {
                driveWalkResponse = driveWalk
                group.leave()
            } else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
            }
        }
        group.enter()
        Alamofire.request(driveDirectUrl, method: .post).responseDriveBikeResponse { response in
            if let driveDirect = response.result.value {
                driveDirectResponse = driveDirect
                group.leave()
            } else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
            }
        }
        
        group.notify(queue: .main) {
            self.whereToButton.isLoading = false
            if (driveBikeResponse.resInfo?.code == 42 || driveWalkResponse.resInfo?.code == 42 || driveDirectResponse.resInfo?.code == 42) {
                self.sendErrorMessage(title: "Error", message: "Looks like we there's no parking available with aspace here. Please try a different address.")
            } else if (driveBikeResponse.resInfo?.code == 45 || driveWalkResponse.resInfo?.code == 45 || driveDirectResponse.resInfo?.code == 45) {
                self.sendErrorMessage(title: "Error", message: "Looks like we don't have routing available there. Please try a different address.")
            } else if (driveBikeResponse.resInfo?.code != 31 || driveWalkResponse.resInfo?.code != 31 || driveDirectResponse.resInfo?.code != 31) {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
            } else {
                self.drawRoute(response: driveBikeResponse)
                self.directionsController.fadeIn()
                self.segmentedControl.move(to: 0)
                self.segmentedControl.fadeIn()
                self.viewingRoute = true
            }
        }
    }
    
    func clearMap() {
        mapView.style?.layers.forEach { currLayer in
            print(currLayer.identifier)
            let id = currLayer.identifier.substring(to: 5)
            if (id == "route") {
                mapView.style?.removeLayer(currLayer)
            }
        }
        mapView.style?.sources.forEach { currSource in
            print(currSource.identifier)
            if (currSource.identifier == "route") {
                mapView.style?.removeSource(currSource)
            }
        }
    }
    
    func drawRoute(response: DriveBikeResponse) {
        if let coordinates = response.resContent?.routes?[0][0].directions?.routes?[0].geometry?.coordinates {
            var mapCoordinates: [CLLocationCoordinate2D] = []
            
            coordinates.forEach { coordinate in
                let currCoord = CLLocationCoordinate2D(latitude: coordinate[1], longitude: coordinate[0])
                mapCoordinates.append(currCoord)
            }
            let polyline = MGLPolyline(coordinates: mapCoordinates, count: UInt(mapCoordinates.count))
            
            let source = MGLShapeSource(identifier: "route", shape: polyline, options: nil)
            mapView.style?.addSource(source)
            
            let layer = MGLLineStyleLayer(identifier: "route-polyline", source: source)
            
            layer.lineJoin = NSExpression(forConstantValue: "round")
            layer.lineCap = NSExpression(forConstantValue: "round")
            
            layer.lineColor = NSExpression(forConstantValue: UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1))
            
            layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                           [14: 2, 18: 20])
            
            let casingLayer = MGLLineStyleLayer(identifier: "route-polyline-case", source: source)
            casingLayer.lineJoin = layer.lineJoin
            casingLayer.lineCap = layer.lineCap
            // Line gap width represents the space before the outline begins, so should match the main line’s line width exactly.
            casingLayer.lineGapWidth = layer.lineWidth
            // Stroke color slightly darker than the line color.
            casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red: 41/255, green: 145/255, blue: 171/255, alpha: 1))
            // Use `NSExpression` to gradually increase the stroke width between zoom levels 14 and 18.
            casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])
            
            // Just for fun, let’s add another copy of the line with a dash pattern.
            let dashedLayer = MGLLineStyleLayer(identifier: "route-polyline-dash", source: source)
            dashedLayer.lineJoin = layer.lineJoin
            dashedLayer.lineCap = layer.lineCap
            dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.white)
            dashedLayer.lineOpacity = NSExpression(forConstantValue: 0.5)
            dashedLayer.lineWidth = layer.lineWidth
            // Dash pattern in the format [dash, gap, dash, gap, ...]. You’ll want to adjust these values based on the line cap style.
            dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
            
            mapView.style?.addLayer(layer)
            mapView.style?.addLayer(dashedLayer)
            mapView.style?.insertLayer(casingLayer, below: layer)
        }
        
    }
    
    func getRoutingURL(routeType: String, originLat: Double, originLng: Double, destLat: Double, destLng: Double, sessionStarting: String, accessCode: String, deviceId: String) -> String {
        var urlString =  "https://routing.trya.space/v1/" + routeType + "?origin_lat="
        urlString += originLat.toString() + "&origin_lng=";
        urlString += originLng.toString() + "&dest_lng="
        urlString += destLng.toString() + "&dest_lat="
        urlString += destLat.toString() + "&session_starting="
        urlString += sessionStarting + "&access_code="
        urlString += accessCode + "&device_id="
        urlString += deviceId
        return urlString
    }
    
    func sendErrorMessage(title: String, message: String) {
        let error = MessageView.viewFromNib(layout: .cardView)
        error.configureTheme(.error)
        error.configureContent(title: title, body: message)
        error.button?.setTitle("Dismiss", for: .normal)
        
        var errorConfig = SwiftMessages.defaultConfig
        errorConfig.presentationStyle = .top
        errorConfig.duration = .seconds(seconds: 4.0)
        
        SwiftMessages.show(config: errorConfig, view: error)
    }
    
    func didSelect(_ segmentIndex: Int) {
        if (viewingRoute) {
            clearMap()
            self.directionsViewController.updateRouteTypeView(index: segmentIndex)
        }
    }
    
    @objc func whereToPressed(_ sender: UITapGestureRecognizer) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        whereToButton.isLoading = true
    }
    
    @objc func helpPressed(_ sender: UITapGestureRecognizer) {
        Intercom.presentMessenger()
    }
}

extension MapController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        getRoute(fromLat: currentLat, fromLng: currentLng, toLat: place.coordinate.latitude, toLng: place.coordinate.longitude, routeType: "get_drive_bike_route");
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.whereToButton.isLoading = false
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        directionsController.isHidden = true
        segmentedControl.isHidden = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        directionsController.isHidden = true
        segmentedControl.isHidden = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension Double {
    func toString() -> String {
        return String(format: "%.10f",self)
    }
}

extension UIView {
    
    func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }) { (completed) in
            self.isHidden = true
            completion(true)
        }
    }
}

extension String {
    func substring(to: Int) -> String? {
        guard to < self.characters.count else { return nil }
        let toIndex = index(self.startIndex, offsetBy: to)
        return substring(to: toIndex)
    }
}
