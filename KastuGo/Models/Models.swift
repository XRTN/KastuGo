//
//  Models.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import Foundation

struct Meal: Identifiable {
    var id = UUID()
    var items: [MealItem] = []
    var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    var notes: String
}

struct MealItem: Identifiable {
    var id = UUID()
    var name: String
    var price: Double
    var quantity: Int
    
}

struct MenuItem {
    var name: String
    var price: Double
    var category: String
}

struct Order: Identifiable {
    var id = UUID()
    var meals: [Meal] = []
    var total: Double {
        meals.reduce(0) { $0 + $1.subtotal }
    }
    var timestamp: Date = Date()
}

struct draftOrder: Identifiable {
    var id = UUID()
    var meals: [Meal] = []
    var total: Double {
        meals.reduce(0) { $0 + $1.subtotal }
    }
    var timestamp: Date = Date()
}


