//
//  CartManager.swift
//  KastuGo
//
//  Created by sam on 02/04/25.
//


import SwiftUI
import SwiftData

// This class manages cart operations and maintains a single cart instance
class CartManager {
    static let shared = CartManager()
    
    private init() {}
    
    // Get all meals in the cart
    func getCartMeals(modelContext: ModelContext) -> [Meal] {
        let fetchDescriptor = FetchDescriptor<Meal>(predicate: #Predicate { $0.isInCart == true })
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Error fetching cart meals: \(error)")
            return []
        }
    }
    
    // Create a new cart meal
    func createMeal(modelContext: ModelContext) -> Meal {
        let newMeal = Meal(items: [], notes: "", isInCart: true)
        modelContext.insert(newMeal)
        try? modelContext.save()
        return newMeal
    }
    
    // Clear the current cart and start a new one
    func clearCart(modelContext: ModelContext) {
        let meals = getCartMeals(modelContext: modelContext)
        
        for meal in meals {
            modelContext.delete(meal)
        }
        
        // Create a new meal for the new cart
        createMeal(modelContext: modelContext)
        try? modelContext.save()
    }
    
    // Convert the current cart to an order, return the created order
    func checkoutCart(modelContext: ModelContext) -> Order {
        let cartMeals = getCartMeals(modelContext: modelContext)
        
        // Create deep copies of all meals for the order
        let orderMeals = cartMeals.map { $0.deepCopy() }
        
        // Insert copies into the model context
        for meal in orderMeals {
            modelContext.insert(meal)
        }
        
        // Create the order with these copies
        let newOrder = Order(meals: orderMeals, timestamp: Date())
        modelContext.insert(newOrder)
        
        try? modelContext.save()
        return newOrder
    }
}
