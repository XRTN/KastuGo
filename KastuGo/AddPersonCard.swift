//
//  AddPersonCard.swift
//  KastuGo
//
//  Created by sam on 24/03/25.
//

import SwiftUI

struct AddPersonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Add Person ")
                    .font(.headline)
                    .bold()
                Spacer()
                Button(action: {
                    print("Delete tapped")
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                }
            }
            
          
            
        }
        .padding()
        .background(Color.gray.opacity(0.2)) // Light gray background
        .cornerRadius(15) // Rounded corners
    }
}

#Preview {
    AddPersonCard()
}
