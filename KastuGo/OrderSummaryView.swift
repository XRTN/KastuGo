//
//  OrderSummaryView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI
import SwiftData

struct OrderSummaryView: View {
    @Query(sort: \Meal.createdAt) var meals: [Meal]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        let sortedMeals = meals.sorted { $0.createdAt < $1.createdAt }

                        ForEach(Array(sortedMeals.enumerated()), id: \.element.id) { index, meal in
                            OrderSumCard(meal: meal, mealIndex: index)
                        }

                    }
                    .background(Color.gray.opacity(0.2))
                }

                Divider()

                let total = meals.reduce(0) { $0 + $1.subtotal }
                totalRow(total: total)

                Spacer()

                confirmButton()
                    .background(Color.gray.opacity(0.2))
            }
            .navigationTitle(Text("Order Summary"))
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func totalRow(total: Double) -> some View {
        HStack {
            Text("Total")
                .fontWeight(.bold)
            Spacer()
            Text("Rp \(Int(total))")
                .fontWeight(.bold)
                .frame(alignment: .trailing)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 50)
    }

    @ViewBuilder
    private func confirmButton() -> some View {
        Button(action: {
            print("Confirm Button Tapped")
        }) {
            Text("Confirm")
                .fontWeight(.regular)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.blue)
                .cornerRadius(10)
        }
        .padding()
    }
}
