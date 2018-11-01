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
import EPContactsPicker
import Pageboy

class MapController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, TwicketSegmentedControlDelegate, EPPickerDelegate  {
    
    //MARK: UI VIEWS
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var whereToButton: LGButton!
    @IBOutlet weak var directionsContainer: UIView!
    @IBOutlet weak var helpButton: LGButton!
    @IBOutlet weak var currLocButton: LGButton!
    @IBOutlet weak var referButton: LGButton!
    var segmentedControl: TwicketSegmentedControl!
    
    //MARK: UI VIEW UTILS/STATE
    var locationManager: CLLocationManager!
    let cellPercentWidth: CGFloat = 0.7
    var initMapLocation = false
    
    //MARK: CURRENT LOCATION STATE
    var currentLat : Double!
    var currentLng : Double!
    var currLocationEnabled = true
    
    //MARK: DIRECTIONS DATA
    var currentDirections: [RoutingResponse]!
    var viewingRoute = false
    var viewingRouteIndex: Int!
    
    //MARK: MAP STATE
    var visibleAnnotations: [MGLAnnotation] = []
    
    //MARK: ROUTE PREVIEW STATE
    var parentPageViewController: ParentPageViewController! = nil
    
    var deviceId: String?
    var accessCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Defaults.getUserSession)
        
        //MARK: MAP VIEW INIT
        mapView.isRotateEnabled = false;
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
        mapView.showsUserLocation = true
        mapView.delegate = self
        
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
        
        //MARK: CURRENT LOC BUTTON INIT
        var currLocButtonPressedGesture = UITapGestureRecognizer()
        currLocButtonPressedGesture = UITapGestureRecognizer(target: self, action: #selector(MapController.currLocPressed(_:)))
        currLocButtonPressedGesture.numberOfTapsRequired = 1
        currLocButtonPressedGesture.numberOfTouchesRequired = 1
        currLocButton.addGestureRecognizer(currLocButtonPressedGesture)
        currLocButton.isUserInteractionEnabled = true
        
        //MARK: REFER BUTTON INIT
        var referButtonPressedGesture = UITapGestureRecognizer()
        referButtonPressedGesture = UITapGestureRecognizer(target: self, action: #selector(MapController.logoutPressed(_:)))
        referButtonPressedGesture.numberOfTapsRequired = 1
        referButtonPressedGesture.numberOfTouchesRequired = 1
        referButton.addGestureRecognizer(referButtonPressedGesture)
        referButton.isUserInteractionEnabled = true
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //MARK: SEGMENTED CONTROL INIT
        let titles = ["Park & Bike", "Park & Walk", "Just Park"]
        var topDelta = (mapView.frame.maxY - view.frame.minY) - (mapView.frame.height)
        let frame = CGRect(x: 0, y: view.frame.height-topDelta-40, width: view.frame.width, height: 40)
        segmentedControl = TwicketSegmentedControl(frame: frame)
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        segmentedControl.isHidden = true
        segmentedControl.sliderBackgroundColor = UIColor(red:0.24, green:0.77, blue:1.00, alpha:1.0)
        
        mapView.addSubview(segmentedControl)
        
        showTitle()
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
                if let finalLat = currentLat as? Double {
                    if let finalLng = currentLng as? Double {
                        moveMapToLatLng(latitude: finalLat, longitude: finalLng)
                    } else {
                        moveMapToLatLng(latitude: 0, longitude: 0)
                    }
                } else {
                    moveMapToLatLng(latitude: 0, longitude: 0)
                }
            }
        }
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            return MGLAnnotationImage(image: UIImage(named: (castAnnotation.name)!)!.resize(targetSize: CGSize(width: 50, height: 50)), reuseIdentifier: castAnnotation.name!)
        } else {
            return nil;
        }
    }
    
    @objc func hideKeyBoard(sender: UITapGestureRecognizer? = nil){
        view.endEditing(true)
    }
    
    private func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) -> Bool {
        return true
    }
    
    
    func moveMapToLatLng(latitude: Double, longitude: Double, fromDistance: Double = 1250) {
        let camera = MGLMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), fromDistance: fromDistance, pitch: 0, heading: 0)
        self.mapView.setCamera(camera, withDuration: 2, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
    }
    
    // Zoom to the annotation when it is selected
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
        mapView.fly(to: camera, completionHandler: nil)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func moveMapToBbox(coords: [LngLat]) {
        var annotations: [MGLAnnotation] = []
        coords.forEach { currentCoord in
            let pointA = MyCustomPointAnnotation()
            pointA.coordinate = CLLocationCoordinate2D(latitude: currentCoord.lat, longitude: currentCoord.lng)
            pointA.name = currentCoord.name
            annotations.append(pointA)
        }
        mapView.showAnnotations(annotations, edgePadding: UIEdgeInsets(top: 90, left: 15, bottom: 150, right: 15), animated: true)
        mapView.addAnnotations(annotations)
        visibleAnnotations = annotations
    }
    
    func getRoute(fromLat: Double, fromLng: Double, toLat: Double, toLng: Double, routeType: String) {
        let group = DispatchGroup()
        
        let driveBikeUrl = getRoutingURL(routeType: "get_drive_bike_route", originLat: fromLat, originLng: fromLng, destLat: toLat, destLng: toLng, sessionStarting: "0", accessCode: accessCode ?? "", deviceId: deviceId!)
        
        let driveWalkUrl = getRoutingURL(routeType: "get_drive_walk_route", originLat: fromLat, originLng: fromLng, destLat: toLat, destLng: toLng, sessionStarting: "0", accessCode: accessCode ?? "", deviceId: deviceId!)
        
        let driveDirectUrl = getRoutingURL(routeType: "get_drive_direct_route", originLat: fromLat, originLng: fromLng, destLat: toLat, destLng: toLng, sessionStarting: "0", accessCode: accessCode ?? "", deviceId: deviceId!)
        
        group.enter()
        var driveBikeResponse: RoutingResponse!
        var driveWalkResponse: RoutingResponse!
        var driveDirectResponse: RoutingResponse!
        Alamofire.request(driveBikeUrl, method: .post).responseRoutingResponse { response in
            if let driveBike = response.result.value {
                driveBikeResponse = driveBike
                group.leave()
            } else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
                print(driveBikeUrl)
            }
        }
        group.enter()
        Alamofire.request(driveWalkUrl, method: .post).responseRoutingResponse { response in
            if let driveWalk = response.result.value {
                driveWalkResponse = driveWalk
                group.leave()
            } else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
                print(driveWalkUrl)
            }
        }
        group.enter()
        Alamofire.request(driveDirectUrl, method: .post).responseRoutingResponse { response in
            if let driveDirect = response.result.value {
                driveDirectResponse = driveDirect
                group.leave()
            } else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
                print(driveDirectUrl)
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
                self.currentDirections = [driveBikeResponse, driveWalkResponse, driveDirectResponse]
                self.viewingRoute = true;
                self.switchRoute(index: 0, initRouteInfoView: true)
                self.segmentedControl.fadeIn()
                self.directionsContainer.fadeIn()
            }
        }
    }
    
    func clearMap() {
        mapView.style?.layers.forEach { currLayer in
            let layerID = currLayer.identifier.substring(to: 5)
            if (layerID == "route") {
                mapView.style?.removeLayer(currLayer)
            }
        }
        mapView.style?.sources.forEach { currSource in
            let sourceID = currSource.identifier.substring(to: 5)
            if (sourceID == "route") {
                mapView.style?.removeSource(currSource)
            }
        }
        mapView.removeAnnotations(visibleAnnotations)
    }
    
    func drawRoute(coordinates: [[Double]], lineColor: UIColor, lineID: String) {
        var mapCoordinates: [CLLocationCoordinate2D] = []
        coordinates.forEach { coordinate in
            let currCoord = CLLocationCoordinate2D(latitude: coordinate[1], longitude: coordinate[0])
            mapCoordinates.append(currCoord)
        }
        let polyline = MGLPolyline(coordinates: mapCoordinates, count: UInt(mapCoordinates.count))
        
        let source = MGLShapeSource(identifier: "route-" + lineID, shape: polyline, options: nil)
        mapView.style?.addSource(source)
        
        let layer = MGLLineStyleLayer(identifier: "route-polyline-" + lineID, source: source)
        
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        
        layer.lineColor = NSExpression(forConstantValue: lineColor)
        
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 2, 18: 20])
        
        let casingLayer = MGLLineStyleLayer(identifier: "route-polyline-case-" + lineID, source: source)
        casingLayer.lineJoin = layer.lineJoin
        casingLayer.lineCap = layer.lineCap
        casingLayer.lineGapWidth = layer.lineWidth
        casingLayer.lineColor = NSExpression(forConstantValue: lineColor)
        casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])
        
        mapView.style?.addLayer(layer)
        mapView.style?.insertLayer(casingLayer, below: layer)
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
    
    func switchRoute(index: Int, initRouteInfoView: Bool) {
        clearMap()
        mapView.showsUserLocation = false
        var coords: [LngLat] = []
        currentDirections[index].resContent?.routes?[0].forEach { routeSegment in
            guard let id = routeSegment.name else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
                return
            }
            if (id == "drive_park") {
                coords.append(LngLat(lng: (routeSegment.origin?.lng)!, lat: (routeSegment.origin?.lat)!, name: "origin"))
                coords.append(LngLat(lng: (routeSegment.dest?.lng)!, lat: (routeSegment.dest?.lat)!, name: "parking_0"))
            } else if (id == "walk_bike") {
                coords.append(LngLat(lng: (routeSegment.dest?.lng)!, lat: (routeSegment.dest?.lat)!, name: "biking_0"))
            } else if (id == "bike_dest") {
                coords.append(LngLat(lng: (routeSegment.dest?.lng)!, lat: (routeSegment.dest?.lat)!, name: "destination"))
            } else if (id == "walk_dest"){
                coords.append(LngLat(lng: (routeSegment.dest?.lng)!, lat: (routeSegment.dest?.lat)!, name: "destination"))
            }
        }
        currentDirections[index].resContent?.routes?[0].forEach { routeSegment in
            guard let coordinates = routeSegment.directions?.routes?[0].geometry?.coordinates else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
                return
            }
            guard let id = routeSegment.name else {
                self.sendErrorMessage(title: "Error", message: "Whoops! Looks like something went wrong. Please try again.")
                return
            }
            if (id == "drive_park") {
                let color = UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
                self.drawRoute(coordinates: coordinates, lineColor: color, lineID: id)
            } else if (id == "walk_bike") {
                let color = UIColor.lightGray
                self.drawRoute(coordinates: coordinates, lineColor: color, lineID: id)
            } else if (id == "bike_dest") {
                let color = UIColor.green
                self.drawRoute(coordinates: coordinates, lineColor: color, lineID: id)
            } else if (id == "walk_dest"){
                let color = UIColor.lightGray
                self.drawRoute(coordinates: coordinates, lineColor: color, lineID: id)
            }
        }
        loadRouteInfoView(index: index, initRouteInfoView: initRouteInfoView)
        moveMapToBbox(coords: coords)
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
            self.switchRoute(index:segmentIndex, initRouteInfoView: false);
        }
    }
    
    @objc func whereToPressed(_ sender: UITapGestureRecognizer) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        whereToButton.isLoading = true
    }
    
    @objc func referPressed(_ sender: UITapGestureRecognizer) {
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.phoneNumber)
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func logoutPressed(_ sender: UITapGestureRecognizer) {
        Defaults.clearUserData()
        Intercom.logout()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginPhoneViewController") as! LoginPhoneViewController
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts : [EPContact]) {
        contacts.forEach { contact in
            print(contact.firstName)
        }
    }
    
    @objc func helpPressed(_ sender: UITapGestureRecognizer) {
        Intercom.presentMessenger()
    }
    
    @objc func currLocPressed(_ sender: UITapGestureRecognizer) {
        currLocToggle()
    }
    
    func currLocToggle() {
        currLocationEnabled = !currLocationEnabled;
        if (currLocationEnabled) {
            currLocButton.leftIconColor = UIColor(red:0.24, green:0.77, blue:1.00, alpha:1.0)
            currLocButton.borderColor = UIColor(red:0.24, green:0.77, blue:1.00, alpha:1.0)
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: true)
        } else {
            mapView.showsUserLocation = false
            mapView.setUserTrackingMode(.none, animated: true)
            currLocButton.leftIconColor = UIColor.lightGray;
            currLocButton.borderColor = UIColor.lightGray;
        }
    }
    
    func loadRouteInfoView(index: Int, initRouteInfoView: Bool) {
        if (initRouteInfoView) {
            parentPageViewController = (self.storyboard?.instantiateViewController(withIdentifier: "ParentPageViewController") as! ParentPageViewController)
            parentPageViewController.routeResponse = currentDirections[index]
            parentPageViewController.mapView = mapView
            parentPageViewController.initView()
            parentPageViewController.view.frame = directionsContainer.bounds
            directionsContainer.addSubview(parentPageViewController.view)
            addChild(parentPageViewController)
            parentPageViewController.didMove(toParent: self)
        } else {
            parentPageViewController?.routeResponse = currentDirections[index]
            parentPageViewController.initView()
        }
    }
    
    func showTitle() {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 250)
        messageView.configureContent(title: "Hey There!", body: "Thanks for giving aspace a try. We're currently available in Seattle and Portland, but if you want to suggest a city for us to bring onboard, press the '?' icon in the top-left to send us a message.", iconImage: nil, iconText: "👋", buttonImage: nil, buttonTitle: "OK!") { _ in
            SwiftMessages.hide()
        }
        messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
        messageView.backgroundView.layer.cornerRadius = 10
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.duration = .forever
        config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
        config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
        SwiftMessages.show(config: config, view: messageView)
    }
}

extension MapController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        clearMap()
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
        directionsContainer.isHidden = true
        segmentedControl.isHidden = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        directionsContainer.isHidden = true
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

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

class MyCustomPointAnnotation: MGLPointAnnotation {
    var name: String?
}
