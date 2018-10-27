//
//  CardPartPagedViewCardController.swift
//  CardParts_Example
//
//  Created by Roossin, Chase on 5/23/18.
//  Copyright © 2018 Intuit. All rights reserved.
//

import Foundation
import CardParts

class CardPartPagedViewCardController: CardPartsViewController {
    let emojis: [String] = ["😎", "🤪", "🤩", "👻", "🤟🏽", "💋", "💃🏽"]
    
    var someVar: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(someVar)
        var stackViews: [CardPartStackView] = []
        
        for i in 0...3 {
            
            let sv = CardPartStackView()
            sv.margins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            sv.spacing = 2
            stackViews.append(sv)
            sv.axis = .vertical
            
            let title = CardPartTextView(type: .title)
            title.text = "This is page #\(i)"
//            title.textAlignment = .center
            sv.addArrangedSubview(title)
            let emoji = CardPartTextView(type: .normal)
            emoji.text = self.emojis[i]
//            emoji.textAlignment = .center
            sv.addArrangedSubview(emoji)
        }
        
        let int: Int = 35
        print("DIRECTIONS CONTROLLER HEIGHT:")
        print(UserDefaults.standard.integer(forKey: "directionsControllerHeight"))
        let cgfloat = CGFloat(int)
        
        let cardPartPagedView = CardPartPagedView(withPages: stackViews, andHeight: cgfloat)
        
        setupCardParts([cardPartPagedView])
    }
}
