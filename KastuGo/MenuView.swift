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
    
    // Store original items separately
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

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(groupedMenuItems(), id: \.key) { category, items in
                        Section(header: Text(category).bold()) {
                            ForEach(items, id: \.name) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                        Text("Rp. \(item.price, specifier: "%.0f")")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Stepper(value: Binding(
                                        get: { quantityForMenuItem(item) },
                                        set: { newValue in
                                            updateMealItem(item: item, quantity: newValue)
                                        }
                                    ), in: 0...10) {
                                        Text("x\(quantityForMenuItem(item))")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText)
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
}

extension MealItem {
    func copy() -> MealItem {
        guard let menuItem = self.menuItem else {
            fatalError("menuItem is nil while copying MealItem")
        }
        return MealItem(menuItem: menuItem, quantity: self.quantity)
    }
}
