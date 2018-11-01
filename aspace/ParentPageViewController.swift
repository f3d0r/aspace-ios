//
//  ParentPageViewController.swift
//  aspace
//
//  Created by Fedor Paretsky on 10/30/18.
//  Copyright © 2018 aspace, Inc. All rights reserved.
//

import Foundation
import UIKit
import Pageboy
import Mapbox

class ParentPageViewController: PageboyViewController {
    
    var pageControllers: [UIViewController] = []
    
    var routeResponse: RoutingResponse?
    
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
    }
    
    func initView() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        print("HERE 1")
        var viewControllers = [UIViewController]()
        routeResponse?.resContent?.routes![0].forEach { currentSegment in
            let viewController = storyboard.instantiateViewController(withIdentifier: "DirectionsViewController") as! DirectionsViewController
            viewController.routeSegment = currentSegment
            viewControllers.append(viewController)
        }
        pageControllers = viewControllers
        scrollToPage(.first, animated: true)
        reloadPages()
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
    }
}

// MARK: PageboyViewControllerDataSource
extension ParentPageViewController: PageboyViewControllerDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return pageControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return pageControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

// MARK: PageboyViewControllerDelegate
extension ParentPageViewController: PageboyViewControllerDelegate {
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        var coords = routeResponse?.resContent?.routes?[0][index].directions?.routes?[0].geometry?.coordinates
        var lngLats: [LngLat] = []
        for i in 0..<coords!.count {
            lngLats.append(LngLat(lng: coords![i][0], lat: coords![i][1]))
        }
        moveMapToBbox(coords: lngLats)
    }
}
