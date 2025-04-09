//
//  DraftDetailsView.swift
//  KastuGo
//
//  Created by Angeline Rachel on 08/04/25.
//

import SwiftUI
import SwiftData

struct DraftDetailView: View {
    var draft: draftOrder

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var tabManager: TabManager

    @State private var showLoadAlert = false

    var body: some View {
        VStack {
            Text("Draft #\(draft.id.uuidString.prefix(8).uppercased())")
                .font(.title)
                .bold()
                .padding(.top)

            if draft.meals.isEmpty {
                Spacer()
                ContentUnavailableView(label: {
                    Label("No Meals", systemImage: "tray")
                }, description: {
                    Text("This draft has no meals.")
                })
                Spacer()
            } else {
                List {
                    ForEach(Array(zip(draft.meals.indices, draft.meals)), id: \.1.id) { (index, meal) in
                        Section(header: Text("Meal \(index + 1)").foregroundColor(.gray)) {
                            ForEach(meal.items) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text("x\(item.quantity)")
                                    Text("Rp \(Int(item.price))")
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }

            Spacer()

            Button(action: {
                showLoadAlert = true
            }) {
                Text("Continue This Draft")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding()
            }
        }
        .alert("Continue this draft?", isPresented: $showLoadAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Continue") {
                CartManager.shared.loadDraft(draft, modelContext: modelContext)
                tabManager.selectedTab = 0 // Go back to Home
            }
        } message: {
            Text("This will replace your current cart items.")
        }
    }
}
