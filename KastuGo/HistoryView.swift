//  HistoryView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.

import SwiftUI
import SwiftData

enum HistoryTab: String, CaseIterable {
    case drafts = "Drafts"
    case history = "History"
}

struct HistoryView: View {
    @Query(sort: \Order.timestamp, order: .reverse) private var orders: [Order]
    @Query(filter: #Predicate<draftOrder> { !$0.meals.isEmpty }, sort: \draftOrder.timestamp, order: .reverse)
    private var drafts: [draftOrder]

    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: HistoryTab = .history
    @State private var orderToDelete: Order? = nil
    @State private var draftToDelete: draftOrder? = nil
    @State private var showDeleteConfirmation = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("History")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)

                Picker("Select Tab", selection: $selectedTab) {
                    ForEach(HistoryTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Group {
                    if selectedTab == .history {
                        orderList
                    } else {
                        draftList
                    }
                }
                .animation(.default, value: selectedTab)
            }
            .alert("Delete Order or Draft?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let order = orderToDelete {
                        modelContext.delete(order)
                        try? modelContext.save()
                    }
                    if let draft = draftToDelete {
                        modelContext.delete(draft)
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var orderList: some View {
        if orders.isEmpty {
            ContentUnavailableView(
                "No Order History",
                systemImage: "clock.arrow.circlepath",
                description: Text("Your completed orders will appear here")
            )
        } else {
            List {
                ForEach(orders) { order in
                    NavigationLink(destination: HistoryDetailsView(order: order)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Order ID #\(order.id.uuidString.prefix(8).uppercased())")
                                .font(.headline)
                            Text("Date: \(dateFormatter.string(from: order.timestamp)) Time: \(timeFormatter.string(from: order.timestamp))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Total: Rp \(Int(order.total))")
                                .font(.subheadline)
                                .bold()
                        }
                        .padding(.vertical, 8)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            orderToDelete = order
                            draftToDelete = nil
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private var draftList: some View {
        if drafts.isEmpty {
            ContentUnavailableView(
                "No Draft Orders",
                systemImage: "square.and.pencil",
                description: Text("Your draft orders will appear here")
            )
        } else {
            List {
                ForEach(drafts) { draft in
                    NavigationLink(destination: DraftDetailView(draft: draft)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Draft ID #\(draft.id.uuidString.prefix(8).uppercased())")
                                .font(.headline)
                            Text("Created: \(dateFormatter.string(from: draft.timestamp))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Subtotal: Rp \(Int(draft.total))")
                                .font(.subheadline)
                                .bold()
                        }
                        .padding(.vertical, 8)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            draftToDelete = draft
                            orderToDelete = nil
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
