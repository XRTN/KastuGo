//
//  MainTabView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "list.clipboard.fill")
                    Text("Order")
                }
                .tag(0)

//            OrderSummaryView()
//                .tabItem {
//                    Image(systemName: "list.bullet.rectangle")
//                    Text("Order")
//                }
//                .tag(1)

            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
                .tag(2)
        }
        .onAppear {
            Task {
                await populateMenuItems(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    MainTabView()
}

func populateMenuItems(modelContext: ModelContext) async {
    do {
        let existingItems: [MenuItem] = try modelContext.fetch(FetchDescriptor<MenuItem>())
        
        guard existingItems.isEmpty else { return }

        let sampleMenuItems = [
            MenuItem(name: "Ayam Asam Manis", price: 11_000, category: "Poultry"),
            MenuItem(name: "Ayam Lada Hitam", price: 11_000, category: "Poultry"),
            MenuItem(name: "Nasi Goreng", price: 15_000, category: "Rice Dishes"),
            MenuItem(name: "Mie Goreng", price: 13_000, category: "Noodles"),
            MenuItem(name: "Tahu Goreng", price: 5_000, category: "Vegetables"),
            MenuItem(name: "Tempe Orek", price: 6_000, category: "Vegetables")
        ]

        for item in sampleMenuItems {
            modelContext.insert(item)
        }
        try modelContext.save()
    } catch {
        print("Error populating menu items: \(error)")
    }
}
