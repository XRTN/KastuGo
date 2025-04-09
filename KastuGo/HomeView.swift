//
//  HomeView.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//
import SwiftUI
import SwiftData

// MARK: - Modal Sheet Management
enum ActiveSheet: Identifiable {
    case menu(meal: Meal)
    case orderSummary
    
    var id: String {
        switch self {
        case .menu(let meal):
            return "menu_\(meal.id)"
        case .orderSummary:
            return "orderSummary"
        }
    }
}

struct HomeView: View {
    @Query(filter: #Predicate<Meal> { $0.isInCart == true })
    private var cartMeals: [Meal]
    
    @Environment(\.modelContext) private var modelContext
    @State private var mealToDelete: Meal? = nil
    @State private var showDeleteConfirmation = false
    @State private var activeSheet: ActiveSheet? = nil
    @State private var showDraftSavedAlert = false
    @State private var showIncompleteMealWarning = false
    @State private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path:$navPath) {
            VStack {
                // Top Title
                HStack {
                    Text("List of Meals")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Add Meal Section
                    Section {
                        Button(action: {
                            let newMeal = CartManager.shared.createMeal(modelContext: modelContext)

                                // 2. Immediately open MenuView for that new meal
                                DispatchQueue.main.async {
                                    activeSheet = .menu(meal: newMeal)
                                }
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.blue)
                                .padding(.trailing, 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                List {
                    // Meals Section (No header anymore)
                    ForEach(Array(zip(cartMeals.indices, cartMeals)), id: \.0) { (index, meal) in
                        Button {
                            DispatchQueue.main.async {
                                activeSheet = .menu(meal: meal)
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Meal \(index + 1)")
                                    Spacer()
                                    Text(meal.items.isEmpty ? "Add Item" : "\(meal.items.count) Items")
                                        .foregroundColor(.gray)
                                }
                                
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
                }
                .listStyle(.insetGrouped)
                // Primary & Secondary Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        if cartMeals.contains(where: { $0.items.isEmpty || $0.subtotal == 0 }) {
                            showIncompleteMealAlert()
                        } else {
                            saveCurrentCartAsDraft()
                        }
                    }) {
                        Text("Save as Draft")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        if cartMeals.contains(where: { $0.items.isEmpty || $0.subtotal == 0 }) {
                            showIncompleteMealAlert()
                        } else {
                            activeSheet = .orderSummary
                        }
                    }) {
                        Text("Order Summary")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)

            }
            .onAppear {
                if cartMeals.isEmpty {
                    CartManager.shared.createMeal(modelContext: modelContext)
                }
            }
            .alert("Delete Meal?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let meal = mealToDelete {
                        modelContext.delete(meal)
                        try? modelContext.save()
                    }
                }
            }
            .alert("Draft Saved!", isPresented: $showDraftSavedAlert) {
                Button("OK", role: .cancel) {}
            }.alert("Incomplete Meal Detected", isPresented: $showIncompleteMealWarning) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("There’s a meal that still has no item. Please complete your meal before proceeding.")
            }.sheet(item: $activeSheet) { item in
                switch item {
                case .menu(let meal):
                    MenuView(meal: meal)
                case .orderSummary:
                    OrderSummaryView(navPath: $navPath)
                }
            }
        }
    }
    
    // MARK: - Save current cart as draft
    private func saveCurrentCartAsDraft() {
        let cartMeals = CartManager.shared.getCartMeals(modelContext: modelContext)
        
        guard !cartMeals.isEmpty else { return }
        
        let draftMeals = cartMeals.map { $0.deepCopy() }
        let newDraft = draftOrder(meals: draftMeals, timestamp: Date())
        
        modelContext.insert(newDraft)
        
        for meal in cartMeals {
            modelContext.delete(meal)
        }
        
        try? modelContext.save()
        
        showDraftSavedAlert = true
        
        DispatchQueue.main.async {
            _ = CartManager.shared.createMeal(modelContext: modelContext)
        }
    }
    private func showIncompleteMealAlert() {
        showIncompleteMealWarning = true
    }
}
