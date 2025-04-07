//
//  PaymentView.swift
//  KastuGo
//
//  Created by sam on 27/03/25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PaymentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let order: Order
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var showPDFPreview = false
    @State private var showSuccessToast = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Payment")
                .font(.largeTitle)
                .bold()

            Text("KASTURI GOP 9")
                .font(.headline)
                .foregroundColor(.gray)

            Image("qr_code") // Replace with actual QR code image
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text("Rp \(Int(order.total))")
                .font(.title)
                .bold()

            Text("Thank You!")
                .font(.headline)
                .bold()

            Text("Order #\(order.id.uuidString.prefix(8).uppercased())") // Show first 8 chars
                .font(.headline)

            Text("Please send the invoice below to Kasturi!")
                          .font(.subheadline)
                          .multilineTextAlignment(.center)
                          .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                Button(action: {
                    downloadInvoice()
                }) {
                    Text("Download")
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
                // Clear the cart and create a new one
                CartManager.shared.clearCart(modelContext: modelContext)
                dismiss()
            }) {
                Text("Start New Order")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .navigationBarBackButtonHidden(true)
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
                Spacer()
                Text("Invoice downloaded successfully")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
            : nil
        )
    }

    private func generatePDF() -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "KastuGo_Order_\(order.id.uuidString.prefix(8)).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        
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
                drawText("KASTURI GOP 9", font: UIFont.boldSystemFont(ofSize: 22),
                         rect: CGRect(x: 30, y: headerY, width: pageRect.width - 60, height: 30), alignment: .center)
                
                drawText("ORDER INVOICE", font: UIFont.boldSystemFont(ofSize: 18),
                         rect: CGRect(x: 30, y: headerY + 40, width: pageRect.width - 60, height: 30), alignment: .center)
                
                let orderIdText = "Order #\(order.id.uuidString.prefix(8).uppercased())"
                drawText(orderIdText, font: UIFont.systemFont(ofSize: 12),
                         rect: CGRect(x: 30, y: headerY + 80, width: 300, height: 20))
                
                let dateText = "Date: \(dateFormatter.string(from: order.timestamp))"
                drawText(dateText, font: UIFont.systemFont(ofSize: 12),
                         rect: CGRect(x: 30, y: headerY + 100, width: 300, height: 20))
                
                var yOffset = headerY + 140
                
                for (index, meal) in order.meals.enumerated() {
                    drawText("Meal \(index + 1)", font: UIFont.boldSystemFont(ofSize: 14),
                             rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 20))
                    yOffset += 25
                    
                    for item in meal.items {
                        drawText(item.name, font: UIFont.systemFont(ofSize: 12),
                                 rect: CGRect(x: 40, y: yOffset, width: 200, height: 20))
                        drawText("\(item.quantity)", font: UIFont.systemFont(ofSize: 12),
                                 rect: CGRect(x: 250, y: yOffset, width: 50, height: 20), alignment: .center)
                        drawText("Rp \(Int(item.price * Double(item.quantity)))", font: UIFont.systemFont(ofSize: 12),
                                 rect: CGRect(x: 320, y: yOffset, width: 100, height: 20), alignment: .right)
                        yOffset += 20
                    }
                    
                    drawText("Meal Subtotal: Rp \(Int(meal.subtotal))", font: UIFont.boldSystemFont(ofSize: 12),
                             rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 20), alignment: .right)
                    
                    yOffset += 30
                    if yOffset > pageRect.height - 100 {
                        context.beginPage()
                        yOffset = 50
                    }
                }
                
                drawText("Total Amount: Rp \(Int(order.total))", font: UIFont.boldSystemFont(ofSize: 16),
                         rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 30), alignment: .right)
                
                yOffset += 40
                
                let footerText = "Thank you for your order!\nPlease send this invoice along with your proof of payment."
                drawText(footerText, font: UIFont.systemFont(ofSize: 12),
                         rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 40), alignment: .center)
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
        } else {
            print("Failed to generate PDF")
        }
    }

}

// ShareSheet for iOS document sharing
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// PDF Preview Controller
struct PDFPreviewController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        let pdfView = PDFView()
        pdfView.autoScales = true
        
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        let viewController = UIViewController()
        viewController.view = pdfView
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: context.coordinator,
            action: #selector(Coordinator.dismiss)
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: PDFPreviewController
        
        init(_ parent: PDFPreviewController) {
            self.parent = parent
        }
        
        @objc func dismiss() {
            let presentingVC = UIApplication.shared.windows.first?.rootViewController?.presentedViewController
            presentingVC?.dismiss(animated: true)
        }
    }
}
