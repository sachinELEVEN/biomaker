//
//  PDFManagement.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation

class FileManagerHelper {
    static let shared = FileManagerHelper()
    
    func savePDF(url: URL) -> URL? {
        let fileName = UUID.init().uuidString//create a random pdf file name
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            print("/FileManagerHelper: File saved to local file system with url \(destinationURL)")
            return destinationURL
        } catch {
            print("/FileManagerHelper: Error saving file: \(error)")
            return nil
        }
    }
    
    func getPDF(fileName: String) -> URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}


import SwiftUI
import UIKit
import PDFKit

struct PDFUploaderView: View {
    @State private var pdfURL: URL? = nil
    @State private var showDocumentPicker = false
    @State private var showPDFViewer = false
    @State private var tempMedicalDocument : MedicalDocument? = nil
    @State private var showMedicalDocument = false
    @Binding var showSelf: Bool 
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(spacing: 20) {
                
                HStack{
                    Text("Add Medical Report")
                        .multilineTextAlignment(.leading)
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        Spacer()
                }
                    
                    .sheet(isPresented: $showDocumentPicker) {
                        DocumentPickerView { selectedPDFURL in
                            if let selectedPDFURL = selectedPDFURL {
                                if let savedURL = FileManagerHelper.shared.savePDF(url: selectedPDFURL) {
                                    //create a new medical record
                                    pdfURL = savedURL
                                    self.tempMedicalDocument = MedicalDocument(pdfDocumentUrl: savedURL)
                                }
                            }
                        }
                    }
                
                if let pdfURL = pdfURL {
                    //                Button("View PDF") {
                    //                    showPDFViewer.toggle()
                    //                }
                    //                .sheet(isPresented: $showPDFViewer) {
                    //                    PDFViewer(url: pdfURL)
                    //                }
                    
                    PDFViewer(url: pdfURL)
                    //.frame(width: (size.height*0.4)/1.77,height: size.width*0.4)
                        .frame(width: system.fullWidth*0.85,height: (system.fullHeight*0.5))
                        .cornerRadius(20)
                    
                    
                    if tempMedicalDocument != nil{
                        Spacer()
                        Text("It may take a few seconds to analyse your file depending on the file size")
                            .font(.subheadline)
                            .padding([.horizontal])
                            .padding(.top, 3)
                            .foregroundStyle(Color.secondary)
                        
                        Button(action:{
                            system.generateNewMedicalTestRecords(medicalDocument: tempMedicalDocument!){
                                success, msg in
                                //processing done
                                print("Document process was successful? \(success) with msg: \(msg)")
                            }
                        }){
                            
                            
                            label("Add to Biomarker", textColor: .primaryInvert, bgColor: .primary, imgName: "doc.text.image", imgColor: .primaryInvert, width: 300, radius: 10)
                        }
                        
                        //                    Button("Process Document"){
                        //                        system.generateNewMedicalTestRecords(medicalDocument: tempMedicalDocument!){
                        //                            success, msg in
                        //                            //processing done
                        //                            print("Document process was successful? \(success) with msg: \(msg)")
                        //                        }
                        //                    }
                        
                        //                    Button("Show medical doc"){
                        //                        showMedicalDocument.toggle()
                        //                    }
                        //                    .sheet(isPresented: $showMedicalDocument){
                        //                        MedicalDocumentViewerHandler(size: CGSize(width: system.fullWidth,height: system.fullHeight), doc: tempMedicalDocument!)
                        //                    }
                        
                    }
                    
                    
                    
                }
            }.onAppear{
                showDocumentPicker.toggle()
            }
        }
        .padding()
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    var onPDFPicked: (URL?) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first else { return }
            parent.onPDFPicked(selectedURL)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onPDFPicked(nil)
        }
    }
}



struct PDFViewer: View {
    let url: URL
    
    var body: some View {
        PDFKitView(url: url)
            .edgesIgnoringSafeArea(.all)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
