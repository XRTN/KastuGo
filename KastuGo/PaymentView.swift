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
    let cartMeals: [Meal]
    @Binding var navPath: NavigationPath

    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var showPDFPreview = false
    @State private var showSuccessToast = false
    @State private var showNewOrderAlert = false
    @Environment(\.dismiss) private var dismiss

    var total: Double {
        cartMeals.reduce(0) { $0 + $1.subtotal }
    }

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
            Text("Payment")
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

            Text("Rp \(formattedCurrency(value: total))")
                .font(.title)
                .bold()

            Text("Thank You!")
                .font(.headline)
                .bold()

            Text("Please send the invoice below to Kasturi!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

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
                showNewOrderAlert = true
            }) {
                Text("Start a new Order")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding()
            .alert("Start a new order?", isPresented: $showNewOrderAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    let _ = CartManager.shared.checkoutCart(modelContext: modelContext)

                    DispatchQueue.main.async {
                        navPath = NavigationPath()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            CartManager.shared.clearCart(modelContext: modelContext)
                        }
                        dismiss()
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to start a new order? Make sure you've saved or sent your invoice first.")
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
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
        .navigationBarBackButtonHidden(true)

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
                let fileName = "KastuGo_QR_\(UUID().uuidString.prefix(8)).png"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try imageData.write(to: fileURL)
                    // Show sharing sheet for the QR code
                    pdfURL = fileURL
                    showShareSheet = true
                } catch {
                    print("Failed to save QR code: \(error)")
                }
            }
        }
    }

    private func generatePDF() -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("KastuGo_CartInvoice.pdf")

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
                drawText("Date: \(dateFormatter.string(from: Date()))", font: .systemFont(ofSize: 12), rect: CGRect(x: 30, y: headerY + 80, width: 300, height: 20))

                var yOffset = headerY + 120
                for (index, meal) in cartMeals.enumerated() {
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

                drawText("Total Amount: Rp \(formattedCurrency(value: total))", font: .boldSystemFont(ofSize: 16), rect: CGRect(x: 30, y: yOffset, width: pageRect.width - 60, height: 30), alignment: .right)
                yOffset += 40

                drawText("Thank you for your order!\nPlease send this invoice along with your proof of payment.",
                         font: .systemFont(ofSize: 12),
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
