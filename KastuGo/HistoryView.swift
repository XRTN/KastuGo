//
//  HistoryView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Order.timestamp, order: .reverse) private var orders: [Order]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedOrder: Order?
    @State private var showOrderDetails = false
    @State private var orderToDelete: Order? = nil
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
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Order ID #\(order.id.uuidString.prefix(8).uppercased())")
                                                .font(.headline)
                                            
                                            Text("Date: \(dateFormatter.string(from: order.timestamp)) Time: \(timeFormatter.string(from: order.timestamp))")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            Text("Total: Rp \(Int(order.total))")
                                                .font(.subheadline)
                                                .bold()
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    orderToDelete = order
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
            .alert("Delete Order?", isPresented: $showDeleteConfirmation, actions: {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let order = orderToDelete {
                        modelContext.delete(order)
                        try? modelContext.save()
                    }
                }
            })
        }
    }
}
