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

class MapController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MGLMapViewDelegate, TwicketSegmentedControlDelegate  {
    
    var locationManager: CLLocationManager!
    
    let cellPercentWidth: CGFloat = 0.7
    
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var destinationSelected: LGButton!
    @IBOutlet weak var directionsController: UIView!
    
    var currLocationButton: UIButton!
    
    var initMapLocation = false
    
    var currentLat : Double!
    var currentLng : Double!
    
    var currLocationEnabled = false
    
    let geocoder = Geocoder(accessToken: "pk.eyJ1IjoiZmVkb3ItYXNwYWNlIiwiYSI6ImNqbXJ6Zzc4NjFxdzYzcHFjYmNrb2Q2MGUifQ.mltUs2Zs9ufl4IOhHbD8BA")
    
    var directionsRoute: Route?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: MAP VIEW INITIALIZATION
        mapView.delegate = self
        mapView.isRotateEnabled = false;
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
        
        
        var tapGesture = UITapGestureRecognizer()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapController.myviewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        destinationSelected.addGestureRecognizer(tapGesture)
        destinationSelected.isUserInteractionEnabled = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let titles = ["Park/Bike", "Park/Walk", "Park/Direct"]
        let frame = CGRect(x: 0, y: mapView.frame.height-120, width: view.frame.width, height: 40)
        let segmentedControl = TwicketSegmentedControl(frame: frame)
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        segmentedControl.isHidden = false
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
        
        let directionsViewController = self.storyboard?.instantiateViewController(withIdentifier: "DirectionsViewController") as! DirectionsViewController
        directionsViewController.view.frame = directionsController.bounds
        directionsController.addSubview(directionsViewController.view)
        addChild(directionsViewController)
        directionsViewController.didMove(toParent: self)
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
    
    //    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //        if (searchText.count > 0) {
    //            let options = ForwardGeocodeOptions(query: searchText)
    //            options.focalLocation = CLLocation(latitude: currentLat, longitude: currentLng)
    //            _ = geocoder.geocode(options) { (placemarks, attribution, error) in
    //                var resultsArray = [String]()
    //                let placeMarks = placemarks
    //                for currentPM in placeMarks! {
    //                    resultsArray.append(currentPM.qualifiedName ?? "")
    //                }
    //                self.dropDown.dataSource = resultsArray
    //                self.dropDown.show()
    //            }
    //        } else {
    //            self.dropDown.hide()
    //        }
    //    }
    
    func zoomToSearchText(searchItem: String) {
        if (searchItem.count > 0) {
            let options = ForwardGeocodeOptions(query: searchItem)
            options.focalLocation = CLLocation(latitude: currentLat, longitude: currentLng)
            _ = geocoder.geocode(options) { (placemarks, attribution, error) in
                guard let placemark = placemarks?.first else {
                    return
                }
                let coordinate = placemark.location?.coordinate
                let center = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
                
                let camera = MGLMapCamera(lookingAtCenter: center, fromDistance: 1500, pitch: 0, heading: 0)
                
                let marker = MGLPointAnnotation()
                marker.coordinate = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
                marker.title = "Your Destination"
                marker.subtitle = placemark.qualifiedName
                
                self.mapView.addAnnotation(marker)
                
                
                let _ = CLLocationCoordinate2DMake(self.currentLat, self.currentLng) //origin
                let _ = CLLocationCoordinate2DMake(coordinate!.latitude, coordinate!.longitude) //destination
                
                var url = "https://routing.trya.space/v1/get_drive_bike_route?origin_lat=" + String(self.currentLat) + "&origin_lng=" + String(self.currentLng);
                url += "&dest_lat=" + String(coordinate!.latitude) + "&dest_lng=" + String(coordinate!.longitude);
                url += "&session_starting=0&access_code=4b9b2841ba12c2b1df147234fa668121&device_id=a0944f8c-1e66-45eb-997f-3b460936708e";
                print(url);
                Alamofire.request(url, method: .post)
                    .responseJSON { response in
                        if response.data != nil {
                            let json = JSON(response.data!)
                            let driveSegment = json["res_content"]["routes"][0][0]["directions"]["routes"][0]["geometry"].rawString();
                            let walkSegment = json["res_content"]["routes"][0][1]["directions"]["routes"][0]["geometry"].rawString();
                            let bikeSegment = json["res_content"]["routes"][0][2]["directions"]["routes"][0]["geometry"].rawString();
                            if let newData = driveSegment!.data(using: String.Encoding.utf8) {
                                print(newData)
                                self.drawPolyline(geoJson: newData, lineColor: UIColor.blue, layerName: "driveSegment")
                            }
                            if let newData = walkSegment!.data(using: String.Encoding.utf8) {
                                print(newData)
                                self.drawPolyline(geoJson: newData, lineColor: UIColor.lightGray, layerName: "walkSegment")
                            }
                            if let newData = bikeSegment!.data(using: String.Encoding.utf8) {
                                print(newData)
                                self.drawPolyline(geoJson: newData, lineColor: UIColor.green, layerName: "bikeSegment")
                            }
                            //                                if let jsonObject = try? JSON(data: data) {
                            //                                    print("HERE---------------------")
                            //                                    print(jsonObject)
                            //
                            
                            //                                                        }
                        }
                }
                
                //                self.calculateRoute(from: origin, to: destination) { (route, error) in
                //                    if error != nil {
                //                        print("Error calculating route")
                //                    }
                //                }
                self.mapView.setCamera(camera, withDuration: 2, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
            }
        }
    }
    
    func drawRouteOnMap(driveSegment: Data, walkSegment: Data) {
        
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
        print("mapmoved")
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
        var urlString =  "https://routing.trya.space/v1/" + routeType + "?origin_lat="
        urlString += fromLat.toString() + "&origin_lng=";
        urlString += fromLng.toString() + "&dest_lng="
        urlString += toLng.toString() + "&dest_lat="
        urlString += toLat.toString() + "&session_starting=1&access_code=07fa1e185317402c043cff15c13da745&device_id=e2fad51a-da1c-40b1-9c7a-e8a12fbb3cb5"
        print("HERE")
        print(urlString)
        
        Alamofire.request(urlString, method: .post).responseDriveBikeResponse { response in
            if let driveDirect = response.result.value {
                print(driveDirect.resInfo?.code)
            } else {
                print("HERE OTHER")
            }
        }
    }
    
    func drawPolyline(geoJson: Data, lineColor: UIColor, layerName: String) {
        // Add our GeoJSON data to the map as an MGLGeoJSONSource.
        // We can then reference this data from an MGLStyleLayer.
        
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = self.mapView.style else { return }
        
        let shapeFromGeoJSON = try! MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue)
        let source = MGLShapeSource(identifier: layerName, shape: shapeFromGeoJSON, options: nil)
        style.addSource(source)
        
        // Create new layer for the line.
        let layer = MGLLineStyleLayer(identifier: layerName, source: source)
        
        // Set the line join and cap to a rounded end.
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        
        // Set the line color to a constant blue color.
        layer.lineColor = NSExpression(forConstantValue: lineColor)
        
        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 2, 18: 20])
        
        style.addLayer(layer)
        
        //        style.addLayer(dashedLayer)
        //        style.insertLayer(casingLayer, below: layer)
    }
    
    func didSelect(_ segmentIndex: Int) {
        print("options selected\(segmentIndex)")
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        destinationSelected.isLoading = true
    }
}

extension MapController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        getRoute(fromLat: currentLat, fromLng: currentLng, toLat: place.coordinate.latitude, toLng: place.coordinate.longitude, routeType: "get_drive_bike_route");
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension Double {
    func toString() -> String {
        return String(format: "%.10f",self)
    }
}