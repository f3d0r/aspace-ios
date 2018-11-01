//
//  CardPartPagedViewCardController.swift
//  CardParts_Example
//
//  Created by Roossin, Chase on 5/23/18.
//  Copyright © 2018 Intuit. All rights reserved.
//

import Foundation
import CardParts

class DirectionsPages: UIViewController {
    var currentRoutes: [RoutingResponse]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadRouteInfo(routes: [RoutingResponse], indexToLoad: Int) {
        currentRoutes = routes
        setupCardParts(getCards(index: indexToLoad))
    }
    
    func getCards(index: Int) -> [CardPartPagedView] {
        var stackViews: [CardPartStackView] = []
        
        currentRoutes![index].resContent!.routes![0].forEach { currentSegment in
            
            let sv = CardPartStackView()
            sv.margins = UIEdgeInsets(top: -20, left: 0, bottom: -20, right: 0)
            sv.spacing = 4
            stackViews.append(sv)
            sv.axis = .horizontal
            
            if (currentSegment.name == "drive_park") {
                
                let transportImage = CardPartImageView(image: UIImage(named: "drive_marker")?.resize(targetSize: CGSize(width: 30, height: 10)))
                sv.addArrangedSubview(transportImage)
                let destInfo = CardPartTextView(type: .normal)
                if (currentSegment.dest?.meta?.name)?.count >= 33) {
                    destInfo.text = "Drive to " + (currentSegment.dest?.meta?.name)?.substring(to: 30)!
                } else {
                    
                }
                
                sv.addArrangedSubview(destInfo)
                
            } else if (currentSegment.name == "walk_dest") {
                
                let transportImage = CardPartImageView(image: UIImage(named: "walk_marker")?.resize(targetSize: CGSize(width: 30, height: 10)))
                sv.addArrangedSubview(transportImage)
                let destInfo = CardPartTextView(type: .normal)
                destInfo.text = "Walk to your destination"
                sv.addArrangedSubview(destInfo)
                
            } else if (currentSegment.name == "walk_bike") {
                
                let transportImage = CardPartImageView(image: UIImage(named: "walk_marker")?.resize(targetSize: CGSize(width: 30, height: 10)))
                sv.addArrangedSubview(transportImage)
                let destInfo = CardPartTextView(type: .normal)
                destInfo.text = "Walk to " + ((currentSegment.dest?.meta?.company)!) + ", " + ((currentSegment.dest?.meta!.id)!)
                sv.addArrangedSubview(destInfo)
                
            } else if (currentSegment.name == "bike_dest") {
                
                let transportImage = CardPartImageView(image: UIImage(named: "bike_marker")?.resize(targetSize: CGSize(width: 30, height: 10)))
                sv.addArrangedSubview(transportImage)
                let destInfo = CardPartTextView(type: .normal)
                destInfo.text = "Bike to your destination"
                sv.addArrangedSubview(destInfo)
                
            } else {
                let transportImage = CardPartImageView(image: UIImage(named: "drive_marker")?.resize(targetSize: CGSize(width: 30, height: 10)))
                sv.addArrangedSubview(transportImage)
            }
            
            let navButton = CardPartButtonView()
            navButton.setTitle("Navigate", for: UIControl.State.normal)
            navButton.
            sv.addArrangedSubview(navButton)
        }
        
        let cgfloat = CGFloat(35)
        
        let cardPartPagedView = CardPartPagedView(withPages: stackViews, andHeight: cgfloat)
        
        return [cardPartPagedView]
    }
}
