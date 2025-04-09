//  CartManager.swift
//  KastuGo
//
//  Created by sam on 02/04/25.

import SwiftUI
import SwiftData

// MARK: - CartManager Class
/// This class manages cart operations and maintains a single cart instance
class CartManager {
    static let shared = CartManager()

    private init() {}

    /// Fetch all meals that are currently in the cart
    func getCartMeals(modelContext: ModelContext) -> [Meal] {
        let fetchDescriptor = FetchDescriptor<Meal>(predicate: #Predicate { $0.isInCart == true })
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Error fetching cart meals: \(error)")
            return []
        }
    }

    /// Create and insert a new empty cart meal
    func createMeal(modelContext: ModelContext) -> Meal {
        let newMeal = Meal(items: [], notes: "", isInCart: true)
        modelContext.insert(newMeal)
        
        DispatchQueue.main.async {
            try? modelContext.save()
        }
        return newMeal
    }

    /// Clear the current cart and start a new one
    func clearCart(modelContext: ModelContext) {
        let meals = getCartMeals(modelContext: modelContext)
        for meal in meals {
            modelContext.delete(meal)
        }

        createMeal(modelContext: modelContext)
        do {
            try modelContext.save()
        } catch {
            print("Error saving after clearing cart: \(error)")
        }
    }

    /// Checkout the current cart into a new Order
    func checkoutCart(modelContext: ModelContext) -> Order {
        let cartMeals = getCartMeals(modelContext: modelContext)

        let orderMeals = cartMeals.map { $0.deepCopy() }
        for meal in orderMeals {
            modelContext.insert(meal)
        }

        let newOrder = Order(meals: orderMeals, timestamp: Date())
        modelContext.insert(newOrder)

        do {
            try modelContext.save()
        } catch {
            print("Error saving after checkout: \(error)")
        }
        return newOrder
    }
}

// MARK: - Draft Loading Extension
extension CartManager {
    /// Load a draft order into the cart
    func loadDraft(_ draft: draftOrder, modelContext: ModelContext) {
        // Step 1: Delete all existing cart meals
        if let mealsInCart = try? modelContext.fetch(FetchDescriptor<Meal>(predicate: #Predicate { $0.isInCart == true })) {
            for meal in mealsInCart {
                modelContext.delete(meal)
            }
        }

        // Step 2: Load draft meals into the cart
        for draftMeal in draft.meals {
            let newMeal = Meal(items: [], notes: draftMeal.notes, isInCart: true)

            for draftItem in draftMeal.items {
                if let menuItem = draftItem.menuItem {
                    let copiedItem = MealItem(menuItem: menuItem, quantity: draftItem.quantity)
                    newMeal.items.append(copiedItem)
                } else {
                    print("Warning: Skipped copying a MealItem because menuItem was missing.")
                }
            }

            modelContext.insert(newMeal)
        }

        // Step 3: Save
        do {
            try modelContext.save()
        } catch {
            print("Error saving after loading draft: \(error)")
        }
    }
}
