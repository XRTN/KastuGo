//
//  HistoryDetailsView.swift
//  KastuGo
//
//  Created by sam on 02/04/25.
//

import SwiftUI
import SwiftData

struct HistoryDetailsView: View {
    let order: Order
    @Environment(\.modelContext) private var modelContext
    @State private var showReorderConfirmation = false
    @State private var showReorderAllConfirmation = false
    @State private var selectedMeal: Meal?
    @State private var showReorderCompleteToast = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(order.meals.enumerated()), id: \.element.id) { index, meal in
                    // Meal section header
                    HStack {
                        Text("Meal \(index + 1)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemGroupedBackground))
                    
                    // Meal items
                    VStack(spacing: 0) {
                        ForEach(meal.items) { item in
                            HStack {
                                Text(item.name)
                                    .font(.body)
                                Spacer()
                                Text("x\(item.quantity)")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.systemBackground))
                            Divider()
                                .padding(.leading)
                        }
                        
                        // Subtotal for this meal
                        HStack {
                            Text("Subtotal")
                                .font(.subheadline)
                            Spacer()
                            Text("Rp \(calculateMealSubtotal(meal))")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.systemBackground))
                        
                        // Reorder button
                        Button(action: {
                            selectedMeal = meal
                            showReorderConfirmation = true
                        }) {
                            Text("Reorder")
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .background(Color(UIColor.systemBackground))
                    }
                }
                
                // Total section
                VStack(spacing: 0) {
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("Rp \(Int(order.total))")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(UIColor.systemGroupedBackground))
                    
                    // Reorder All button
                    .safeAreaInset(edge: .bottom) {
                        VStack {
                            Button(action: {
                                showReorderAllConfirmation = true
                            }) {
                                Text("Reorder All")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            .padding(.bottom, 8) // Prevents overlap with TabView
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Order #\(order.id.uuidString.prefix(8).uppercased())")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .alert("Reorder this meal?", isPresented: $showReorderConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reorder", role: .none) {
                if let meal = selectedMeal {
                    reorderMeal(meal)
                }
            }
        } message: {
            Text("This meal will be added to your current order.")
        }
        .alert("Reorder all meals?", isPresented: $showReorderAllConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reorder All", role: .none) {
                reorderAllMeals()
            }
        } message: {
            Text("All \(order.meals.count) meals will be added to your current order.")
        }
        .overlay(
            showReorderCompleteToast ?
            VStack {
                Spacer()
                Text("Added to your order")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
            : nil
        )
    }
    
    // Helper function to calculate the subtotal for a meal
    private func calculateMealSubtotal(_ meal: Meal) -> Int {
        let subtotal = meal.items.reduce(0) { $0 + $1.price * Double($1.quantity) }
        return Int(subtotal)
    }
    
    // Reorder a single meal
    private func reorderMeal(_ meal: Meal) {
        // Add the meal to the current cart
        let cartMeal = CartManager.shared.createMeal(modelContext: modelContext)
        
        // Copy items from the historical meal to the new cart meal
        for item in meal.items {
            if let menuItem = item.menuItem {
                let newItem = MealItem(menuItem: menuItem, quantity: item.quantity)
                cartMeal.items.append(newItem)
            }
        }
        
        // Save the changes
        try? modelContext.save()
        
        // Show confirmation toast
        showReorderCompleteToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showReorderCompleteToast = false
        }
    }
    
    // Reorder all meals in the order
    private func reorderAllMeals() {
        // Reorder each meal in the order
        for meal in order.meals {
            reorderMeal(meal)
        }
    }
}
