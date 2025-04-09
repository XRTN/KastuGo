//
//  HomeView.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//
import SwiftUI
import SwiftData

struct HomeView: View {
    // Query only meals that are in the cart
    @Query(filter: #Predicate<Meal> { $0.isInCart == true })
    private var cartMeals: [Meal]
    
    @Environment(\.modelContext) private var modelContext
    @State private var mealToDelete: Meal? = nil
    @State private var showDeleteConfirmation = false
    @State private var showMenuView = false
    @State private var selectedMeal: Meal? = nil
    @State private var showOrderSummary = false

    var body: some View {
        NavigationStack {
            List {
                // Meals Section - removed the section header
                ForEach(Array(zip(cartMeals.indices, cartMeals)), id: \.0) { (index, meal) in
                    Button {
                        selectedMeal = meal
                        showMenuView = true
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Meal \(index + 1)")
                                Spacer()
                                Text(meal.items.isEmpty ? "Add Item" : "\(meal.items.count) Items")
                                    .foregroundColor(.gray)
                            }
                            
                            // Display added menu items
                            if !meal.items.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(meal.items) { item in
                                            VStack(alignment: .leading) {
                                                Text(item.name)
                                                    .font(.caption)
                                                Text("x\(item.quantity)")
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(4)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    .swipeActions {
                        Button(role: .destructive) {
                            mealToDelete = meal
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                // Order Details Section
                Section {
                    Button {
                        showOrderSummary = true
                    } label: {
                        Text("Order Summary")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("List of Meals")
            .onAppear {
                // If there are no meals in the cart, create one
                if cartMeals.isEmpty {
                    CartManager.shared.createMeal(modelContext: modelContext)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Create a new meal
                        let newMeal = CartManager.shared.createMeal(modelContext: modelContext)
                        // Set it as the selected meal
                        selectedMeal = newMeal
                        // Open the MenuView
                        showMenuView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .alert("Delete Meal?", isPresented: $showDeleteConfirmation, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let meal = mealToDelete {
                    modelContext.delete(meal)
                    try? modelContext.save()
                }
            }
        })
        .sheet(isPresented: $showMenuView) {
            if let meal = selectedMeal {
                MenuView(meal: meal)
            }
        }
        .sheet(isPresented: $showOrderSummary) {
            OrderSummaryView()
        }
    }
}
