//
//  Models.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftData
import Foundation
 
@Model
class Meal {
    @Attribute(.unique) var id: UUID = UUID()
    @Relationship(deleteRule: .cascade) var items: [MealItem] = []
    var createdAt: Date = Date()
    var notes: String = ""

    @Transient
    var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    init(items: [MealItem] = [], notes: String = "") {
        self.items = items
        self.notes = notes
    }
}

 
 @Model
class MealItem {
    @Attribute(.unique) var id: UUID = UUID()
    @Relationship(deleteRule: .nullify) var menuItem: MenuItem? = nil
    var quantity: Int

    var price: Double {
        menuItem?.price ?? 0
    }

    var name: String {
        menuItem?.name ?? "Unknown"
    }

    init(menuItem: MenuItem, quantity: Int = 1) {
        self.menuItem = menuItem
        self.quantity = quantity
    }
}

 
 @Model
 class MenuItem {
     var name: String
    var price: Double
    var category: String
     
     init(name: String, price: Double, category: String) {
         self.name = name
         self.price = price
         self.category = category
     }
 }

@Model
class Order {
    @Attribute(.unique) var id: UUID = UUID()
        @Relationship(deleteRule: .cascade) var meals: [Meal] = []
        var timestamp: Date = Date()

        var total: Double {
            meals.reduce(0) { $0 + $1.subtotal }
        }

        init(meals: [Meal] = [], timestamp: Date = Date()) {
            self.meals = meals
            self.timestamp = timestamp
        }
}

@Model
class draftOrder {
    @Attribute(.unique) var id: UUID = UUID()
       @Relationship(deleteRule: .cascade) var meals: [Meal] = []
       var timestamp: Date = Date()

       var total: Double {
           meals.reduce(0) { $0 + $1.subtotal }
       }

       init(meals: [Meal] = [], timestamp: Date = Date()) {
           self.meals = meals
           self.timestamp = timestamp
       }
}
