//
//  ContentView.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import SwiftUI

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "doc.text.below.ecg")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}



// MARK: - Home View
struct HomeView: View {
    @ObservedObject var sys = system
    var body: some View {
        NavigationView{
            VStack {
                GeometryReader{ geo in
                    if sys.medicalDocuments.first != nil{
                        MedicalDocumentViewerSmall(size: geo.size, doc: sys.medicalDocuments.first!)
                        //MedicalDocumentViewer(size: geo.size, doc: sys.medicalDocuments.first!)
                    }else{
                        // ContentView()
                        PDFUploaderView()
                    }
                    
                }
            }.onAppear{
                setMockMedicalDocument()
            }
            .padding()
            .navigationTitle("Home")
        }
    

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
        
        mockMedicalDocument.name = "LFT and KFT with other gastonomical tests"
        mockMedicalDocument.summary = "Everything looks good, you can consult a gastrologist for in-depth analysis"
        
        //adding to the system
        system.medicalDocuments.append(mockMedicalDocument)

    }
}


// MARK: - Search View
struct SearchView: View {
    var body: some View {
        NavigationView {
            Text("Search Page")
                .navigationTitle("Search")
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Settings Page")
                .navigationTitle("Settings")
        }
    }
}
