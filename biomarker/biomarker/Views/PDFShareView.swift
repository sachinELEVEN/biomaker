//
//  PDFShareView.swift
//  biomarker
//
//  Created by sachin jeph on 02/10/24.
//

import Foundation
import SwiftUI
import UIKit

struct SharePDFView: View {
    let pdfURL: URL // URL to the locally stored PDF file
    var width: CGFloat = 300
    
    @State private var isSharePresented = false
    
    var body: some View {
        VStack {
            // Display PDF name or any other content
//            Text("Share PDF")
//                .font(.headline)
            
            // Share button
            Button(action: {
                isSharePresented = true
            }) {
                label("Share", textColor: .white, bgColor: .blue, imgName: "square.and.arrow.up.fill", imgColor: .white, width: width, radius: 10)
            }
            .sheet(isPresented: $isSharePresented) {
                ShareSheet(activityItems: [pdfURL])
            }
        }
        .padding()
    }
}

// UIKit wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
