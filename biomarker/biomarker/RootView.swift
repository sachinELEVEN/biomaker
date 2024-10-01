//
//  ContentView.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var sys = system
    var body: some View {
        VStack {
            GeometryReader{ geo in
                MedicalDocumentViewer(size: geo.size, doc: sys.medicalDocuments.first ?? MedicalDocument(pdfDocumentUrl: mockPdfUrl!))
                
            }
        }
        .padding()
    }
}
