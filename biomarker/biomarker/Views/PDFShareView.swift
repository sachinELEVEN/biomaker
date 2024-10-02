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
                label("Share Original Document (PDF)", textColor: .primaryInvert, bgColor: .primary, imgName: "square.and.arrow.up.fill", imgColor: .primaryInvert, width: 300, radius: 10)
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
