//
//  HomeView.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var mealOwnerName: String = ""
    @Binding var isConfirmed: Bool  // Binding to switch views

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "fork.knife.circle.fill").resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.gray)

            Text("Welcome")
                          .font(.largeTitle)
                          .bold()
            Text("To")
                          .font(.largeTitle)
                          .bold()
            Text("KastuGo")
                          .font(.largeTitle)
                          .bold()
                      
                      Text("You can enter your name below to start ordering meals")
                          .foregroundColor(.gray)
                      
                      // Name Input
                      Text("What is your name?")
                          .font(.headline)
            TextField("Enter Name", text: $mealOwnerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Spacer()
            Button(action: {
                guard !mealOwnerName.isEmpty else { return }
                
                let newMealOwner = MealOwner(name: mealOwnerName)
                modelContext.insert(newMealOwner)  // ✅ Actually insert into SwiftData
                
                isConfirmed = true  // ✅ Switch to ListMeals
            }) {
                Text("Confirm")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
