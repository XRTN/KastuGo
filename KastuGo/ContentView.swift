//
//  ContentView.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//
import SwiftUI

struct ContentView: View {
    @State private var isConfirmed = false
    
    var body: some View {
        NavigationStack {
            if isConfirmed {
                ListMeals()
            } else {
                HomeView(isConfirmed: $isConfirmed)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

#Preview {
    ContentView()
}
