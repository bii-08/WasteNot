//
//  ItemIcon.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/15.
//

import Foundation

enum ItemIcon: String, Identifiable, CaseIterable {
    var id: Self {
        return self
    }
    case apple
    case artichoke
    case baguette
    case banana
    case blueberry
    case broccoli
    case cabbage
    case carrot
    case cheese
    case cherryTomato = "cherry tomato"
    case cherry
    case chickenDrumsticks = "chicken drumsticks"
    case chicken
    case chiliPepper = "chili pepper"
    case coconut
    case corn
    case cucumber
    case doughnut
    case egg
    case eggplant
    case frenchFries = "french fries"
    case ginger
    case grapes
    case greenBean = "green bean"
    case greenOnion = "green onion"
    case hamburger
    case hotdog
    case iceCream = "ice cream"
    case ketchup
    case kiwi
    case lasagna
    case lemon
    case lettuce
    case macaroni
    case milk
    case mushroom
    case olive
    case onion
    case orangeJuice = "orange juice"
    case orange
    case peach
    case pepperBell = "pepper bell"
    case pineapple
    case pizza
    case popcorn
    case potato
    case radish
    case salad
    case sandwich
    case smoothie
    case soda
    case steak
    case strawberry
    case sundae
    case sushi
    case taco
    case toast
    case tomato
    case watermelon
    case yam
    case zucchini
    case honey
    case jam
    case oil
    case yogurt
    
    var name: String {
            self.rawValue
        }
    
}
