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
        //to prevent the NSCocoaErrorDomain Code=257, go the solution from here -> https://stackoverflow.com/questions/58223929/how-do-i-get-around-nscocoaerrordomain257-when-pulling-a-file-from-the-files-ap
        let isAccessing = url.startAccessingSecurityScopedResource()
        // Create a file name based on the current date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = "-biomarker-" + dateFormatter.string(from: Date()) + ".pdf"
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            // If a file already exists at the destination, remove it
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            // Copy the file from the provided URL to the destination URL
            try FileManager.default.copyItem(at: url, to: destinationURL)
            print("/FileManagerHelper: File saved to local file system with url \(destinationURL)")
            if isAccessing {
                url.stopAccessingSecurityScopedResource()
            }
            return destinationURL
        } catch {
            print("/FileManagerHelper: Error saving file: \(error)")
            if isAccessing {
                url.stopAccessingSecurityScopedResource()
            }
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
    @State private var documentProcessingStatus = 0//0 means not started, 1 means in progress, 2 means success, -1 means failed
    @Binding var showSelf: Bool
    @State var isScannedDocument = true//we will force the backend to use OCR for processing, its better than its embedded text based processing
    
    var body: some View {
        GeometryReader{ geo in
            NavigationView{
                ScrollView(showsIndicators: false){
                    VStack(spacing: 20) {
                        
                        //                HStack{
                        //                    Text("Add Medical Report")
                        //                        .multilineTextAlignment(.leading)
                        //                        .fontWeight(.bold)
                        //                        .font(.title)
                        //                        .padding()
                        //                        Spacer()
                        //                }
                        
                        Text("")
                            .sheet(isPresented: $showDocumentPicker) {
                                DocumentPickerView { selectedPDFURL in
                                    if let selectedPDFURL = selectedPDFURL {
                                        
                                        if let savedURL = FileManagerHelper.shared.savePDF(url: selectedPDFURL) {
                                            //create a new medical record
                                            //WORKAROUND- For some reason changing the pdfUrl is not updating the pdf we display, so this below workaround works. i am not going into detail as to why its happening for now, its very late and chances are this side project will be dead soon, so who cares (i care but i care about other things more for now, like getting this app ready for v1 release)
                                            pdfURL = nil
                                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                                                pdfURL = savedURL
                                            })
                                            
                                            self.tempMedicalDocument = MedicalDocument(pdfDocumentUrl: savedURL)
                                        }
                                    }
                                }.ignoresSafeArea(.all)
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
                                .frame(width: geo.size.width*0.85,height: (geo.size.height*0.5))
                                .cornerRadius(20)
                            
                            
                            if tempMedicalDocument != nil && documentProcessingStatus != 2{
                                Spacer()
                                Text("It may take a few seconds to analyze your file depending on the file size")
                                    .font(.subheadline)
                                    .padding([.horizontal])
                                    .padding(.top, 3)
                                    .foregroundStyle(Color.secondary)
                                /*
                                 Button(action:{
                                 isScannedDocument.toggle()
                                 }){
                                 imageView(systemName: isScannedDocument ? "checkmark.square.fill" : "square",color: isScannedDocument ? .blue : .secondary)
                                 Text("Treat as camera scanned document")
                                 .font(.caption)
                                 .foregroundStyle(Color.secondary)
                                 .multilineTextAlignment(.leading)
                                 }
                                 */
                                
                                Button(action:{
                                    //start loading indicator
                                    if documentProcessingStatus == 1{
                                        return
                                    }
                                    documentProcessingStatus = 1
                                    system.generateNewMedicalTestRecords(medicalDocument: tempMedicalDocument!, isScannedDocument: isScannedDocument){
                                        success, msg in
                                        //processing done
                                        //finish loading indicator with status update on the biomarker button, ability to analyze the document
                                        print("Document process was successful? \(success) with msg: \(msg)")
                                        documentProcessingStatus = success ? 2 : -1
                                    }
                                }){
                                    
                                    VStack{
                                        
                                        if documentProcessingStatus == 1{
                                            ActivityIndicator(shouldAnimate: .constant(true))
                                        }
                                        
                                        label(processingButtonText(), textColor: .primaryInvert, bgColor: .primary, imgName: "doc.text.image", imgColor: .primaryInvert, width: 300, radius: 10)
                                    }
                                    
                                    
                                    
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
                            
                            
                            if tempMedicalDocument != nil && documentProcessingStatus == 2{
                                
                                Text("Successfully processed your medical document and added to your Biomarker app")
                                    .font(.subheadline)
                                    .padding([.horizontal])
                                    .padding(.top, 3)
                                    .foregroundStyle(Color.secondary)
                                //successfully document processed
                                NavigationLink(destination: MedicalDocumentViewerHandler(size: geo.size, doc: tempMedicalDocument!)){
                                    label("View Your Medical Record", textColor: .white, bgColor: .blue, imgName: "doc.text.image", imgColor: .white, width: 300, radius: 10)
                                }
                            }
                            
                            
                            
                        }
                        
                        
                        if documentProcessingStatus != 2{
                            //as of now we do not allow multiple uploads one after another without closing the screen
                            //choose pdf
                            Button(action:{
                                reset()
                                showDocumentPicker.toggle()
                            }){
                                label("Select Medical Record (PDF)", textColor: .primary, bgColor: .secondary.opacity(0.15), imgName: "doc.text.image", imgColor: .primary, width: 300, radius: 10)
                            }
                        }
                        
                    }.onAppear{
                        if documentProcessingStatus == 0{
                            //we only wanna aut toggle this to true on the first launch of the upload sheet
                            showDocumentPicker.toggle()
                        }
                    }
                }
                .ignoresSafeArea(.all)
                .padding()
                .navigationTitle("Add Medical Report")
                .navigationBarTitleDisplayMode(.inline)
                .edgesIgnoringSafeArea(.bottom)
                .toolbar {
                    
                    Button("Close") {
                        showSelf.toggle()
                    }
                    
                    
                }
            }
        }
    }
    
    func processingButtonText()->String{
        if documentProcessingStatus == 1{
            return "Processing..."
        }
        if documentProcessingStatus == 0{
            return "Analyze with Biomarker"
        }
        if documentProcessingStatus == -1{
            return "Something went wrong. Try again..."
        }
        
        return ""
    }
    
    func reset(){
        //resets the state to the original state
        pdfURL = nil
        tempMedicalDocument = nil
        documentProcessingStatus = 0
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
        if url.absoluteString == mockPdfUrl!.absoluteString {
            // Load the sample PDF from the assets folder
            if let samplePDFUrl = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
                PDFKitView(url: samplePDFUrl)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Sample PDF not found. This should not happen")
            }
        } else {
            PDFKitView(url: url)
                .edgesIgnoringSafeArea(.all)
        }
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
