//
//  MainTabView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            OrderSummaryView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Order")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
                .tag(2)
        }
    }
}


#Preview {
    MainTabView()
}
