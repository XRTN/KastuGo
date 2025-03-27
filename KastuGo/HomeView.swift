//
//  HomeView.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//

import SwiftUI

struct HomeView: View {
    @State private var meals: [Meal] = []

    var body: some View {
        NavigationStack {
            VStack {
                Text("KastuGo")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Text("Your Order")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                List {
                   
                    MealCard()
                
                    Button(action: {
                        
                    }) {
                        HStack {
                            Text("Add Meal")
                            Spacer()
                            Image(systemName: "plus")
                        }
                    }
                }

               
            }
        }
    }
}
