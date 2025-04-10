//
//  MenuView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI
import SwiftData

struct MenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let meal: Meal
    @Query private var menuItems: [MenuItem]
    
    @State private var selectedCategory: String? = nil
    @State private var searchText = ""
    @State private var originalItems: [MealItem] = []

    var filteredMenu: [MenuItem] {
        menuItems.filter { item in
            (selectedCategory == nil || item.category == selectedCategory) &&
            (searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    var uniqueCategories: [String] {
        Array(Set(menuItems.map { $0.category })).sorted()
    }

    var mealTotal: Double {
        meal.items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(groupedMenuItems(), id: \.key) { category, items in
                        Section(header: Text(category).bold()) {
                            ForEach(items, id: \.name) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.body)
                                        
                                        let itemQuantity = quantityForMenuItem(item)
                                        let displayedPrice = itemQuantity == 0 ? item.price : (item.price * Double(itemQuantity))
                                        
                                        Text("Rp \(formattedCurrency(value: displayedPrice))")
                                            .foregroundColor(.primary)
                                            .fontWeight(itemQuantity > 0 ? .bold : .regular)
                                            .font(.caption)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            let currentQuantity = quantityForMenuItem(item)
                                            if currentQuantity > 0 {
                                                updateMealItem(item: item, quantity: currentQuantity - 1)
                                            }
                                        }) {
                                            Image(systemName: "minus")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(.plain)
                                        .contentShape(Rectangle())
                                        
                                        Text("\(quantityForMenuItem(item))")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)

                                        Button(action: {
                                            let currentQuantity = quantityForMenuItem(item)
                                            if currentQuantity < 10 {
                                                updateMealItem(item: item, quantity: currentQuantity + 1)
                                            }
                                        }) {
                                            Image(systemName: "plus")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(.plain)
                                        .contentShape(Rectangle())
                                    }

                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText)
                
                // Total Section
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("Rp \(formattedCurrency(value: mealTotal))")
                            .font(.headline)
                            .bold()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGray6)) // Light background under total
            }
            .navigationTitle("Add to Meal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        meal.items = originalItems.map { $0.copy() }
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("All") { selectedCategory = nil }
                        Divider()
                        ForEach(uniqueCategories, id: \.self) { category in
                            Button(category) { selectedCategory = category }
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
            }
            .onAppear {
                originalItems = meal.items.map { $0.copy() }
            }
        }
    }

    // MARK: - Helper Functions
    func groupedMenuItems() -> [(key: String, value: [MenuItem])] {
        let grouped = Dictionary(grouping: filteredMenu) { $0.category }
        return grouped.sorted { $0.key < $1.key }
    }
    
    func quantityForMenuItem(_ menuItem: MenuItem) -> Int {
        return meal.items.first(where: { $0.name == menuItem.name })?.quantity ?? 0
    }
    
    func updateMealItem(item: MenuItem, quantity: Int) {
        if quantity == 0 {
            meal.items.removeAll { $0.name == item.name }
        } else {
            if let index = meal.items.firstIndex(where: { $0.name == item.name }) {
                meal.items[index].quantity = quantity
            } else {
                meal.items.append(MealItem(menuItem: item, quantity: quantity))
            }
        }
    }
    
    func formattedCurrency(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}

// MARK: - Extension to copy MealItem
extension MealItem {
    func copy() -> MealItem {
        guard let menuItem = self.menuItem else {
            fatalError("menuItem is nil while copying MealItem")
        }
        return MealItem(menuItem: menuItem, quantity: self.quantity)
    }
}

