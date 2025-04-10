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
                .fontWeight(.bold)
            
            mealItemsList()  //Extracted into a separate function
            Button(action: { isNavigating = true }) {
                HStack {
                    Spacer()
                    Text("Add Item")
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)
            subtotalRow(meal:meal)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(12)
        .padding(.horizontal)
        .navigationDestination(isPresented: $isNavigating){
            MenuView(meal: meal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
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
                Text("Rp \(Int(item.price * Double(item.quantity)))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
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
            
            Text("\(item.quantity)")
                .fontWeight(.regular)
            
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
    
    private func dynamicHeight(for meal: Meal) -> CGFloat {
        let baseHeight: CGFloat = 50 // Base padding height
        let rowHeight: CGFloat = 40  // Estimated height per item
        return baseHeight + (rowHeight * CGFloat(meal.items.count))
    }
    
    @ViewBuilder
    private func subtotalRow(meal: Meal) -> some View {
        HStack {
            Text("Subtotal")
            Spacer()
            Text("Rp \(Int(meal.subtotal))") //Dynamically fetch subtotal
        }
        .fontWeight(.bold)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}
