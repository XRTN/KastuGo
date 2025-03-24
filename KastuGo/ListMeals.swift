//
//  ListMeals.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//

import SwiftUI
import SwiftData

struct ListMeals: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealOwners: [MealOwner]  // Fetch all MealOwners

    var body: some View {
        VStack {
            HStack {
                Button {
                    // Back action
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }
                
                Text("List of Meals").font(.largeTitle).fontWeight(.bold).foregroundColor(.gray)
                Spacer()
                
                Button {
                    // Show history
                } label: {
                    Image(systemName: "clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 50)
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 10) {
                    if mealOwners.isEmpty {
                        Text("No meals added yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(mealOwners) { owner in
                            MealCard(mealOwner: owner)  // Display dynamic meal cards
                        }
                    }
                    AddPersonCard()  // Button to add a new person
                }
            }

            Spacer()

            Button(action: {
                print("Details button tapped")
            }) {
                Text("Details")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20) // Rounded corners
            }
            .padding(.bottom)
        }
    }
}
