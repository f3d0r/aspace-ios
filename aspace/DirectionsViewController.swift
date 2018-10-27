//
//  MainViewController.swift
//  CardParts
//
//  Created by tkier on 11/27/2017.
//  Copyright (c) 2017 tkier. All rights reserved.
//

import UIKit
import CardParts

class DirectionsViewController: CardsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var directionsPages = CardPartPagedViewCardController();
        directionsPages.someVar = "this is a test"
        let cards: [CardPartsViewController] = [
            directionsPages
        ]
        loadCards(cards: cards)
    }
}
