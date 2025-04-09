//  MainTabView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.

import SwiftUI
import SwiftData

class TabManager: ObservableObject {
    @Published var selectedTab: Int = 0
}

struct MainTabView: View {
    @StateObject private var tabManager = TabManager()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
                .tag(1)
        }
        .environmentObject(tabManager)
        .onAppear {
            Task {
                populateMenuItems(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    MainTabView()
}

func populateMenuItems(modelContext: ModelContext) {
    do {
        let existingItems: [MenuItem] = try modelContext.fetch(FetchDescriptor<MenuItem>())
        guard existingItems.isEmpty else { return }

        let sampleMenuItems = [
            MenuItem(name: "Ayam Asam Manis", price: 11000, category: "Poultry"),
            MenuItem(name: "Nasi Goreng", price: 15000, category: "Rice Dishes"),
            MenuItem(name: "Mie Goreng", price: 13000, category: "Noodles"),
            MenuItem(name: "Tahu Goreng", price: 5000, category: "Vegetables"),
            MenuItem(name: "Tempe Orek", price: 6000, category: "Vegetables")
        ]

        for item in sampleMenuItems {
            modelContext.insert(item)
        }
        try modelContext.save()
    } catch {
        print("Error populating menu items: \(error)")
    }
}

