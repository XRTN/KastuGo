//
//  HomeView.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//
import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var meals: [Meal]
    @Environment(\.modelContext) private var modelContext
    @State private var mealToDelete: Meal? = nil
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            VStack {
                // App title
                Text("KastuGo")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)

                List {
                    // Meals Section
                    Section(header: Text("Your Order").font(.headline).foregroundColor(.gray)) {
                        ForEach(Array(zip(meals.indices, meals)), id: \.0) { (index, meal) in
                            NavigationLink(destination: MenuView(meal: meal)) {
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
                            .swipeActions {
                                Button(role: .destructive) {
                                    mealToDelete = meal
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    // Add Meal Section
                    Section {
                        Button(action: {
                            let newMeal = Meal(items: [], notes: "")
                            modelContext.insert(newMeal)
                            try? modelContext.save()
                        }) {
                            HStack {
                                Text("Add Meal")
                                Spacer()
                                Image(systemName: "plus")
                            }
                        }
                    }

                    // Order Details Section
                    Section {
                        Button(action: {
                            print("Order Details tapped")
                        }) {
                            Text("Order Details")
                                .bold()
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .listStyle(.insetGrouped)
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
    }
}
