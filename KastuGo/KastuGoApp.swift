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
        let schema = Schema([MealOwner.self, Meal.self, MealItem.self]) // ✅ Include all models
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false) // ✅ Corrected argument
        return try! ModelContainer(for: schema, configurations: [modelConfiguration])
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer) // ✅ Attach SwiftData storage
        }
    }
}
