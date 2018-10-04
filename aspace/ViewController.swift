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
import SHSearchBar
import MapboxGeocoder
import DropDown
import CircleMenu
import SwiftyJSON
import Alamofire
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MGLMapViewDelegate  {
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    var currLocationButton: UIButton!
    
    var initMapLocation = false
    
    var currentLat : Double!
    var currentLng : Double!
    
    let dropDown = DropDown()
    
    var currLocationEnabled = false
    
    let geocoder = Geocoder(accessToken: "pk.eyJ1IjoiZmVkb3ItYXNwYWNlIiwiYSI6ImNqbXJ6Zzc4NjFxdzYzcHFjYmNrb2Q2MGUifQ.mltUs2Zs9ufl4IOhHbD8BA")
    
    var directionsRoute: Route?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        mapView.delegate = self
        
//        button.contentVerticalAlignment = .fill
//        button.contentHorizontalAlignment = .fill
//        button.imageEdgeInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        dropDown.anchorView = searchBar
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.show()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
        
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        
        searchBar.barTintColor = UIColor.white
        searchBar.tintColor = UIColor.white
        searchBar.backgroundColor = UIColor.clear
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.tintColor = UIColor.white
        textFieldInsideSearchBar?.backgroundColor = UIColor.white
        textFieldInsideSearchBar?.textColor = UIColor.black
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.searchBar.text = item
            self.dropDown.hide()
            self.mapView.becomeFirstResponder()
            self.zoomToSearchText(searchItem: item);
        }
        
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
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {return}
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        if (!initMapLocation) {
            mapView.setCenter(CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude), zoomLevel: 15, animated: false)
            initMapLocation = true
        }
        currentLat = locValue.latitude
        currentLng = locValue.longitude
        if (currLocationEnabled) {
            moveMapToLatLng(latitude: currentLat, longitude: currentLng)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count > 0) {
            let options = ForwardGeocodeOptions(query: searchText)
            options.focalLocation = CLLocation(latitude: currentLat, longitude: currentLng)
            _ = geocoder.geocode(options) { (placemarks, attribution, error) in
                var resultsArray = [String]()
                let placeMarks = placemarks
                for currentPM in placeMarks! {
                    resultsArray.append(currentPM.qualifiedName ?? "")
                }
                self.dropDown.dataSource = resultsArray
                self.dropDown.show()
            }
        } else {
            self.dropDown.hide()
        }
    }
    
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
                
                
                let origin = CLLocationCoordinate2DMake(self.currentLat, self.currentLng)
                let destination = CLLocationCoordinate2DMake(coordinate!.latitude, coordinate!.longitude)
                
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
                            print(driveSegment);
                            print(walkSegment);
                            print(bikeSegment);
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
}
