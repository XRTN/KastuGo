//
//  OrderSummaryView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI
import SwiftData

struct OrderSummaryView: View {
    // Query only meals that are in the cart, sorted by creation date
    @Query(filter: #Predicate<Meal> { $0.isInCart == true }, sort: \Meal.createdAt)
    var cartMeals: [Meal]
    
    @Environment(\.modelContext) private var modelContext
    @State private var showConfirmationAlert = false
    @State private var navigateToPayment = false
    @State private var newOrder: Order?

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        let sortedMeals = cartMeals.sorted { $0.createdAt < $1.createdAt }
                        ForEach(Array(sortedMeals.enumerated()), id: \.element.id) { index, meal in
                            OrderSumCard(meal: meal, mealIndex: index)
                        }
                    }
                }

                Divider()

                let total = cartMeals.reduce(0) { $0 + $1.subtotal }
                totalRow(total: total)

                Spacer()

                confirmButton()
                    .background(Color.gray.opacity(0.2))
            }
            .navigationTitle(Text("Order Summary"))
            .navigationBarTitleDisplayMode(.large)
            .alert("Confirm Order", isPresented: $showConfirmationAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm", role: .destructive) {
                    createOrder()
                }
            } message: {
                Text("After confirming, you will not be able to make changes to your order.")
            }
            .navigationDestination(isPresented: $navigateToPayment) {
                if let order = newOrder {
                    PaymentView(order: order)
                }
            }
        }
    }

    @ViewBuilder
    private func totalRow(total: Double) -> some View {
        HStack {
            Text("Total")
            Spacer()
            Text("Rp \(Int(total))")

                .frame(alignment: .trailing)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 50)
    }

    @ViewBuilder
    private func confirmButton() -> some View {
        Button(action: {
            showConfirmationAlert = true
        }) {
            Text("Confirm")
                .fontWeight(.regular)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(10)
        }
        .padding()
    }

    private func createOrder() {
        // Use the CartManager to check out the current cart
        // This creates copies of the meals and marks them as not in cart
        let order = CartManager.shared.checkoutCart(modelContext: modelContext)
        
        // Set the new order for navigation
        newOrder = order
        navigateToPayment = true
    }
}

#Preview {
    MainTabView()
}

