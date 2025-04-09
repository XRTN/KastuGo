//  Models.swift
//  KastuGo
//
//  Created by sam on 27/03/25.

import SwiftData
import Foundation

// MARK: - Meal Model
@Model
class Meal {
    @Attribute(.unique) var id: UUID = UUID()
    @Relationship(deleteRule: .cascade) var items: [MealItem] = []
    var createdAt: Date = Date()
    var notes: String = ""
    var isInCart: Bool = true  // Flag to identify if meal is in active cart

    @Transient
    var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    init(items: [MealItem] = [], notes: String = "", isInCart: Bool = true) {
        self.items = items
        self.notes = notes
        self.isInCart = isInCart
    }

    /// Create a deep copy of this Meal
    func deepCopy() -> Meal {
        let copiedMeal = Meal(items: [], notes: self.notes, isInCart: false)

        for item in self.items {
            if let menuItem = item.menuItem {
                copiedMeal.items.append(MealItem(menuItem: menuItem, quantity: item.quantity))
            }
        }

        return copiedMeal
    }
}

// MARK: - MealItem Model
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

// MARK: - MenuItem Model
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

// MARK: - Order Model
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

// MARK: - DraftOrder Model
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

// MARK: - Cart Model
@Model
class Cart {
    @Attribute(.unique) var id: UUID = UUID()
    var lastUpdated: Date = Date()

    static var shared: Cart {
        fatalError("Access Cart through CartManager instead")
    }

    init() {}
}
