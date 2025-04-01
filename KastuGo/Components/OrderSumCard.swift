//
//  OrderSumCard.swift
//  KastuGo
//
//  Created by Angeline Rachel on 01/04/25.
//

import SwiftUI

struct OrderSumCard: View {
    @Bindable var meal: Meal  //Bindable for SwiftData updates
    @State private var isNavigating: Bool = false
    @State private var showCancelAlert = false
    @State private var itemToRemove: MealItem? = nil
    
    var mealIndex: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Meal \(mealIndex + 1)")
                .padding(.horizontal)
                .fontWeight(.regular)
            
            VStack(alignment: .leading) {
                mealItemsList()  //Extracted into a separate function
                Button(action: { isNavigating = true }) {
                    HStack {
                        Spacer()
                        Text("Add Item")
                            .fontWeight(.regular)
                            .padding(.leading)
                        Image(systemName: "chevron.right")
                            .padding(.trailing)
                    }
                }
                Divider()
                subtotalRow(meal:meal)
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(10)
            .padding(.horizontal)
            .navigationDestination(isPresented: $isNavigating){
                MenuView(meal: meal)
            }
        }
        .padding()
    }
    
    
    //Function for Meal Items List
    @ViewBuilder
    private func mealItemsList() -> some View {
        ForEach(meal.items.indices, id: \.self) { index in
            mealItemRow(index: index)
            Divider()
        }
    }
    
    //Function for Each Meal Item Row
    @ViewBuilder
    private func mealItemRow(index: Int) -> some View {
        let item = meal.items[index]
        
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                Text("Rp \(Int(item.price))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("x \(item.quantity)")
                .fontWeight(.regular)
            
            Button(action: {
                if item.quantity == 1 {
                    itemToRemove = item
                    showCancelAlert = true
                } else {
                    item.quantity -= 1
                }
            }) {
                Image(systemName: "minus")
                    .frame(width: 12, height: 12)
                    .padding(6)
                    .clipShape(Circle())
            }
            
            Button(action: {
                item.quantity += 1
            }) {
                Image(systemName: "plus")
                    .frame(width: 12, height: 12)
                    .padding(6)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .alert("Are you sure you want to cancel?", isPresented: $showCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Remove", role: .destructive) {
                if let itemToRemove = itemToRemove {
                    if let indexToRemove = meal.items.firstIndex(where: { $0.id == itemToRemove.id }) {
                        meal.items.remove(at: indexToRemove)
                    }
                }
            }
        } message: {
            Text("This will remove the item from your order.")
        }
    }
    
}

private func dynamicHeight(for meal: Meal) -> CGFloat {
    let baseHeight: CGFloat = 50 // Base padding height
    let rowHeight: CGFloat = 40  // Estimated height per item
    return baseHeight + (rowHeight * CGFloat(meal.items.count))
}

@ViewBuilder
private func subtotalRow(meal: Meal) -> some View {
    HStack {
        Text("Subtotal")
            .fontWeight(.bold)
        Spacer()
        Text("Rp \(Int(meal.subtotal))") //Dynamically fetch subtotal
            .fontWeight(.bold)
    }
    .padding(.horizontal)
    .padding(.vertical, 5)
}

extension Double {
    var formattedRupiah: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return "Rp \(formatter.string(from: NSNumber(value: self)) ?? "0")"
    }
}
