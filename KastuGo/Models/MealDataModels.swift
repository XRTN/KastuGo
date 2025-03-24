//
//  MealDataModels.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//
import SwiftData
import Foundation

@Model
class MealOwner {
    var id: UUID
    var name: String
    var meals: [Meal]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.meals = []
    }
}

@Model
class Meal {
    var id: UUID
    var owner: MealOwner
    var items: [MealItem]
    
    init(owner: MealOwner) {
        self.id = UUID()
        self.owner = owner
        self.items = []
    }
}

@Model
class MealItem {
    var id: UUID
    var name: String
    var price: Double
    
    init(name: String, price: Double) {
        self.id = UUID()
        self.name = name
        self.price = price
    }
}
