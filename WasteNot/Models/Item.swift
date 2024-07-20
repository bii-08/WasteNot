//
//  Item.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/15.
//

import Foundation
import UIKit
import SwiftData
 
@Model class Item: Identifiable, Equatable, Hashable {
    let id = UUID()
    var name: String
    var quantity: Int
    var purchasedDate: Date = Date.now
    var expiryDate: Date = Date.now
    @Attribute(.externalStorage) var image: Data
    var enumCaseString: String?
    var dayLeft: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date.now, to: expiryDate)
        return components.day ?? 0
    }
    var offset: CGFloat = 0.0
    
    // Equatable
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(name: String, quantity: Int, purchasedDate: Date, expiryDate: Date, image: Data, enumCaseString: String?, offset: CGFloat = 0.0) {
        self.name = name
        self.quantity = quantity
        self.purchasedDate = purchasedDate
        self.expiryDate = expiryDate
        self.image = image
        self.enumCaseString = enumCaseString
        self.offset = offset
    }
}
