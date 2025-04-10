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
            // Poultry
            MenuItem(name: "Ayam Teriyaki", price: 12000, category: "Poultry"),
            MenuItem(name: "Ayam Bistik", price: 12000, category: "Poultry"),
            MenuItem(name: "Ayam Asam Manis", price: 12000, category: "Poultry"),
            MenuItem(name: "Ayam Lada Hitam/ Fillet", price: 12000, category: "Poultry"),
            MenuItem(name: "Ayam Bakar", price: 13000, category: "Poultry"),
            MenuItem(name: "Ayam Goreng Balado", price: 12000, category: "Poultry"),

            // Beef
            MenuItem(name: "Sapi Lada Hitam", price: 15000, category: "Beef"),
            MenuItem(name: "Mapo Tofu", price: 14000, category: "Beef"),

            // Fish
            MenuItem(name: "Ikan Cakalang Suwir", price: 14000, category: "Fish"),
            MenuItem(name: "Ikan Dori Asam Manis", price: 14000, category: "Fish"),
            MenuItem(name: "Ikan Sarden Rica", price: 14000, category: "Fish"),
            MenuItem(name: "Ikan Tongkol Balado", price: 14000, category: "Fish"),

            // Seafood
            MenuItem(name: "Cumi Cabe Hijau", price: 15000, category: "Seafood"),
            MenuItem(name: "Otak Otak Spore Rica", price: 14000, category: "Seafood"),

            // Sausage & Others
            MenuItem(name: "Sosis Oseng Bawang Cabe Rawit", price: 11000, category: "Others"),
            MenuItem(name: "Mie Goreng Telor", price: 10000, category: "Noodles"),
            MenuItem(name: "Kentang Masak Balado", price: 9000, category: "Vegetables"),
            MenuItem(name: "Orek Tempe Balado", price: 8000, category: "Vegetables"),

            // Eggs
            MenuItem(name: "Telor Masak Semur", price: 9000, category: "Egg"),
            MenuItem(name: "Tahu Masak Semur", price: 9000, category: "Vegetables"),

            MenuItem(name: "Telor Dadar Tipis", price: 7000, category: "Egg"),
            MenuItem(name: "Telor Ceplok Balado", price: 8000, category: "Egg"),
            MenuItem(name: "Telor Ceplok Ponti Cabe Rawit", price: 8000, category: "Egg"),
            MenuItem(name: "Telor Bulat Balado", price: 8000, category: "Egg"),
            MenuItem(name: "Telor Puyuh Balado", price: 9000, category: "Egg"),

            // Vegetables
            MenuItem(name: "Sayur Sawi Putih", price: 6000, category: "Vegetables"),
            MenuItem(name: "Sayur Toge", price: 6000, category: "Vegetables"),
            MenuItem(name: "Sayur Labu", price: 6000, category: "Vegetables"),
            MenuItem(name: "Sayur Terong Balado", price: 7000, category: "Vegetables"),
            MenuItem(name: "Sayur Krecek", price: 7000, category: "Vegetables"),
            MenuItem(name: "Sayur Nangka", price: 7000, category: "Vegetables"),

            // Fried Snacks
            MenuItem(name: "Bakwan Jagung", price: 5000, category: "Fried Snacks"),
            MenuItem(name: "Martabak Telor", price: 8000, category: "Fried Snacks"),
            MenuItem(name: "Bakwan Sayur", price: 5000, category: "Fried Snacks"),

            // Rice
            MenuItem(name: "Nasi Putih 1 Porsi", price: 5000, category: "Rice"),
            MenuItem(name: "Nasi Putih 1/2 Porsi", price: 3000, category: "Rice"),
            MenuItem(name: "Nasi Merah 1 Porsi", price: 6000, category: "Rice"),
            MenuItem(name: "Nasi Merah 1/2 Porsi", price: 4000, category: "Rice"),

            // Sambal
            MenuItem(name: "Sambal Merah", price: 3000, category: "Condiments"),
            MenuItem(name: "Sambal Dabu Dabu", price: 3000, category: "Condiments"),
            MenuItem(name: "Sambal Hijau", price: 3000, category: "Condiments")
        ]


        for item in sampleMenuItems {
            modelContext.insert(item)
        }
        try modelContext.save()
    } catch {
        print("Error populating menu items: \(error)")
    }
}

