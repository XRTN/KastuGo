// OrderInvoiceView.swift
// KastuGo
// Created by sam on 09/04/25.

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct OrderInvoiceView: View {
    let order: Order
    
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var showPDFPreview = false
    @State private var showSuccessToast = false
    @State private var showQRSavedToast = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter
    }
    
    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Order Invoice")
                .font(.largeTitle)
                .bold()
            
            Text("KASTURI GOP 9")
                .font(.headline)
                .foregroundColor(.gray)
            
            // QR code with download button
            ZStack(alignment: .bottom) {
                Image("qr_code")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Button(action: downloadQRCode) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                        .padding(.bottom, -12)
                }
            }
            .padding(.bottom, 12)
            
            Text("Rp \(formattedCurrency(value: order.total))")
                .font(.title)
                .bold()
            
            Text("Order ID: #\(order.id.uuidString.prefix(8).uppercased())")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Date: \(dateFormatter.string(from: order.timestamp))")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                Button(action: downloadInvoice) {
                    Text("Get Invoice")
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    generatePDF()
                    showPDFPreview = true
                }) {
                    Text("Preview")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("Close")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .navigationTitle("Invoice")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $showPDFPreview) {
            if let url = pdfURL {
                PDFPreviewController(url: url)
            }
        }
        .overlay(
            showSuccessToast ?
            VStack {
                
            }
            : nil
        )
       
    }
    
    private func formattedCurrency(value: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
    
    private func downloadQRCode() {
        // Get the QR code image from the view
        if let qrImage = UIImage(named: "qr_code") {
            // Save image to temporary directory
            if let imageData = qrImage.pngData() {
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "KastuGo_QR_\(order.id.uuidString.prefix(8)).png"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try imageData.write(to: fileURL)
                    // Show sharing sheet for the QR code
                    pdfURL = fileURL
                    showShareSheet = true
                    showSuccessToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessToast = false
                    }
                } catch {
                    print("Failed to save QR code: \(error)")
                    showSuccessToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessToast = false
                    }
                }
            }
        }
    }
    
    private func generatePDF() -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("KastuGo_OrderInvoice_\(order.id.uuidString.prefix(8)).pdf")
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        do {
            try renderer.writePDF(to: fileURL) { context in
                context.beginPage()
                
                func drawText(_ text: String, font: UIFont, rect: CGRect, alignment: NSTextAlignment = .left) {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = alignment
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .paragraphStyle: paragraphStyle
                    ]
                    text.draw(in: rect, withAttributes: attributes)
                }
                
                let headerY: CGFloat = 30
                drawText("KASTURI GOP 9", font: .boldSystemFont(ofSize: 22), rect: CGRect(x: 30, y: headerY, width: pageRect.width - 60, height: 30), alignment: .center)
                drawText("ORDER INVOICE", font: .boldSystemFont(ofSize: 18), rect: CGRect(x: 30, y: headerY + 40, width: pageRect.width - 60, height: 30), alignment: .center)
                drawText("Order ID: #\(order.id.uuidString.prefix(8).uppercased())", font: .systemFont(ofSize: 12), rect: CGRect(x: 30, y: headerY + 70, width: 300, height: 20))
                drawText("Date: \(dateFormatter.string(from: order.timestamp))", font: .systemFont(ofSize: 12), rect: CGRect(x: 30, y: headerY + 90, width: 300, height: 20))
                
                var yOffset = headerY + 120
                for (index, meal) in order.meals.enumerated() {
                    drawText("Meal \(index + 1)", font: .boldSystemFont(ofSize: 14), rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 20))
                    yOffset += 25
                    
                    for item in meal.items {
                        drawText(item.name, font: .systemFont(ofSize: 12), rect: CGRect(x: 40, y: yOffset, width: 200, height: 20))
                        drawText("\(item.quantity)", font: .systemFont(ofSize: 12), rect: CGRect(x: 250, y: yOffset, width: 50, height: 20), alignment: .center)
                        drawText("Rp \(formattedCurrency(value: item.price * Double(item.quantity)))", font: .systemFont(ofSize: 12), rect: CGRect(x: 320, y: yOffset, width: 100, height: 20), alignment: .right)
                        yOffset += 20
                    }
                    
                    drawText("Meal Subtotal: Rp \(formattedCurrency(value: meal.subtotal))", font: .boldSystemFont(ofSize: 12), rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 20), alignment: .right)
                    yOffset += 30
                    
                    if yOffset > pageRect.height - 100 {
                        context.beginPage()
                        yOffset = 50
                    }
                }
                
                drawText("Total Amount: Rp \(formattedCurrency(value: order.total))",
                         font: .boldSystemFont(ofSize: 16),
                         rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 30),
                         alignment: .right)
                yOffset += 40

                drawText("Thank you for your order!\nPlease send this invoice along with your proof of payment.",
                         font: .systemFont(ofSize: 12),
                         rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 40),
                         alignment: .center)
            }
            
            pdfURL = fileURL
            return fileURL
        } catch {
            print("Failed to generate PDF: \(error)")
            return nil
        }
    }
    
    private func downloadInvoice() {
        if let fileURL = generatePDF() {
            showShareSheet = true
            showSuccessToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSuccessToast = false
            }
        }
    }
}


