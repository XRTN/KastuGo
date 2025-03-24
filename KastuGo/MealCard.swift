//
//  MealCard.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//
import SwiftUI

struct MealCard: View {
    let mealOwner: MealOwner  // Accept a MealOwner object

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(mealOwner.name)'s Meal")
                    .font(.headline)
                    .bold()
                Spacer()
                Button(action: {
                    print("Delete \(mealOwner.name) tapped")
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
            }

            Divider() // Line under the meal name

            HStack {
                Text("Add menu")
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    print("Add menu for \(mealOwner.name) tapped")
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2)) // Light gray background
        .cornerRadius(15) // Rounded corners
    }
}
