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
//                MedicalDocumentViewer(size: geo.size, doc: sys.medicalDocuments.first ?? MedicalDocument(pdfDocumentUrl: mockPdfUrl!))
                if sys.medicalDocuments.first != nil{
                    MedicalDocumentViewer(size: geo.size, doc: sys.medicalDocuments.first!)
                }else{
                   // ContentView()
                    PDFUploaderView()
                }
                
            }
        }.onAppear{
            setMockMedicalDocument()
        }
        .padding()
    }
    
    func setMockMedicalDocument(){
   
        
        
        
        //creating mock test records
        let records: [BasicMedicalTestRecordv1] = [
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Free Testosterone", value: "1.24", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.5", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Vitamin D", value: "32.2", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "20.0", plottablerefupperlimit: "50.0"),
            BasicMedicalTestRecordv1(test: "Bilirubin", value: "1.5", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.3", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Haemoglobin2", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit:"5", plottablerefupperlimit: "10"),
        ]
        
        //creating mock medical document section
        let mockDocumentSection = MedicalDocumentSection()
        for record in records{
            mockDocumentSection.addNewMedicalTestRecords(testRecords: record)
        }
        
        let mockMedicalDocument = MedicalDocument(pdfDocumentUrl: mockPdfUrl!)
        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
        
        //adding to the system
        system.medicalDocuments.append(mockMedicalDocument)

    }
}
