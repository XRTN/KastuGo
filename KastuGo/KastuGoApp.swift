//
//  KastuGoApp.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//

import SwiftUI
import SwiftData

@main
struct KastuGoApp: App {
   
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Meal.self,MealItem.self,MenuItem.self,Order.self,draftOrder.self,Cart.self])
             let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
             return try! ModelContainer(for: schema, configurations: [modelConfiguration])
         }()
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(sharedModelContainer)
                
        }
    }
}


