//
//  MainViewController.swift
//  CardParts
//
//  Created by tkier on 11/27/2017.
//  Copyright (c) 2017 tkier. All rights reserved.
//

import Foundation
import UIKit
import CardParts
import LGButton
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class DirectionsViewController: UIViewController {
    
    @IBOutlet weak var routeTypeImage: UIImageView!
    @IBOutlet weak var originText: UITextView!
    @IBOutlet weak var toText: UITextView!
    @IBOutlet weak var destinationText: UITextView!
    @IBOutlet weak var startNavigationButton: LGButton!
    
    var routeSegment: RoutingResContentRoute?
    
    var originName: String?
    var destName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var startNavigationButtonPressed = UITapGestureRecognizer()
        startNavigationButtonPressed = UITapGestureRecognizer(target: self, action: #selector(DirectionsViewController.startNavPressed(_:)))
        startNavigationButtonPressed.numberOfTapsRequired = 1
        startNavigationButtonPressed.numberOfTouchesRequired = 1
        startNavigationButton.addGestureRecognizer(startNavigationButtonPressed)
        startNavigationButton.isUserInteractionEnabled = true
        
        originText.sizeToFit()
        originText.centerVertically()
        let fixedWidth = originText.frame.size.width
        let newSize = originText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        originText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        toText.sizeToFit()
        toText.centerVertically()
        let fixedWidth2 = toText.frame.size.width
        let newSize2 = toText.sizeThatFits(CGSize(width: fixedWidth2, height: CGFloat.greatestFiniteMagnitude))
        toText.frame.size = CGSize(width: max(newSize2.width, fixedWidth2), height: newSize2.height)
        
        destinationText.sizeToFit()
        destinationText.centerVertically()
        let fixedWidth3 = destinationText.frame.size.width
        let newSize3 = destinationText.sizeThatFits(CGSize(width: fixedWidth3, height: CGFloat.greatestFiniteMagnitude))
        destinationText.frame.size = CGSize(width: max(newSize3.width, fixedWidth3), height: newSize3.height)
        
        if (routeSegment!.name == "drive_park") {
            routeTypeImage.image = UIImage(named: "drive_marker")!.resize(targetSize: CGSize(width: 30, height: 30))
            originText.text = "Your location"
            destinationText.text = routeSegment?.dest?.meta?.name
        } else if (routeSegment!.name == "walk_dest") {
            routeTypeImage.image = UIImage(named: "walk_marker")!.resize(targetSize: CGSize(width: 30, height: 30))
            originText.text = routeSegment?.origin?.meta?.name
            destinationText.text = "Your destination"
        } else if (routeSegment!.name == "walk_bike") {
            routeTypeImage.image = UIImage(named: "walk_marker")!.resize(targetSize: CGSize(width: 30, height: 30))
            originText.text = routeSegment?.origin?.meta?.name
            destinationText.text = (routeSegment?.dest?.meta?.company)! + ", " + (routeSegment?.dest?.meta?.id)!
        } else if (routeSegment!.name == "bike_dest") {
            routeTypeImage.image = UIImage(named: "bike_marker")!.resize(targetSize: CGSize(width: 30, height: 30))
            originText.text = (routeSegment?.origin?.meta?.company)! + ", " + (routeSegment?.origin?.meta?.id)!
            destinationText.text = "Your destination"
        }
    }
    
    @objc func startNavPressed(_ sender: UITapGestureRecognizer) {
        let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: (routeSegment?.origin!.lat)!, longitude: routeSegment!.origin!.lng!), name: originText.text)
        let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: routeSegment!.dest!.lat!, longitude: routeSegment!.dest!.lng!), name: destinationText.text)
        
        var profile: MBDirectionsProfileIdentifier?
        if (routeSegment!.name == "drive_park") {
            profile = MBDirectionsProfileIdentifier.automobileAvoidingTraffic
        } else if (routeSegment!.name == "walk_dest") {
            profile = MBDirectionsProfileIdentifier.walking
        } else if (routeSegment!.name == "walk_bike") {
            profile = MBDirectionsProfileIdentifier.walking
        } else if (routeSegment!.name == "bike_dest") {
            profile = MBDirectionsProfileIdentifier.cycling
        }
        
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: profile)
        
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first else { return }
            
            let viewController = NavigationViewController(for: route)
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(0, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
