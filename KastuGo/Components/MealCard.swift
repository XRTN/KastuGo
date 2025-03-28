//
//  MealCard.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI

struct MealCard: View {
    let meal: Meal
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Meal \(index)")
                    .font(.headline)
                    .bold()
                Spacer()
                Button(action: {
                    print("Delete \(meal.id) tapped")
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            HStack {
                Text("Add menu")
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    print("Add menu for \(meal.id) tapped")
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}
