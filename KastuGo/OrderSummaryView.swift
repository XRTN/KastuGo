//
//  OrderSummaryView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI
import SwiftData

struct OrderSummaryView: View {
    @Query(filter: #Predicate<Meal> { $0.isInCart == true }, sort: \Meal.createdAt)
    var cartMeals: [Meal]
    
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmationAlert = false
    @State private var navigateToPayment = false
    @Binding var navPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navPath) {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(cartMeals.enumerated()), id: \.element.id) { index, meal in
                            OrderSumCard(meal: meal, mealIndex: index)
                                
                        }
                    }
                    .padding(.vertical)
                }
                Divider()
                totalRow(total: cartMeals.reduce(0) { $0 + $1.subtotal })
                Spacer()
                confirmButton()
            }

            .navigationTitle("Order Summary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Confirm Order", isPresented: $showConfirmationAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    navigateToPayment = true
                }
            } message: {
                Text("After confirming, you will not be able to make changes to your order.")
            }
            .navigationDestination(isPresented: $navigateToPayment) {
                PaymentView(cartMeals: cartMeals, navPath: $navPath)
            }
        }
    }
    
    private func totalRow(total: Double) -> some View {
        HStack {
            Text("Total")
            Spacer()
            Text("Rp \(Int(total))")
        }
        .fontWeight(.bold)
        .padding(.vertical, 10)
        .padding(.horizontal, 50)
    }
    
    @ViewBuilder
        private func confirmButton() -> some View {
            Button(action: {
                showConfirmationAlert = true
            }) {
                Text("Confirm")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(cartMeals.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
            .disabled(cartMeals.isEmpty)
        }
}
