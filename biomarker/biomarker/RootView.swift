//
//  ContentView.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import SwiftUI

import SwiftUI

struct RootTabView: View {
    @ObservedObject var sys = system
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
            
            VariationView()
                .tabItem {
                    Label("Variation", systemImage: "chart.bar.fill")
                }
            
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }.onAppear{
            setMockMedicalDocument()
        }
        .accentColor(.primary)
    }
    
    func setMockMedicalDocument(){
   
        
        //creating mock test records
        let records: [BasicMedicalTestRecordv1] = [
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "16", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "19", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "21", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Free Testosterone", value: "1.24", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.5", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Vitamin D", value: "32.2", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "20.0", plottablerefupperlimit: "50.0"),
            BasicMedicalTestRecordv1(test: "Bilirubin", value: "1.5", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.3", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Haemoglobin2", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit:"5", plottablerefupperlimit: "10"),
            BasicMedicalTestRecordv1(test: "Haemoglobin3", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Free Testosterone2", value: "1.24", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.5", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Vitamin D3", value: "32.2", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "20.0", plottablerefupperlimit: "50.0"),
            BasicMedicalTestRecordv1(test: "Bilirubin4", value: "1.5", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.3", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Haemoglobin9", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit:"5", plottablerefupperlimit: "10"),
            BasicMedicalTestRecordv1(test: "Bilirubin7", value: "1.5", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.3", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Haemoglobin10", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit:"5", plottablerefupperlimit: "10")
        ]
        
        let records2: [BasicMedicalTestRecordv1] = [
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "16", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "19", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "21", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Free Testosterone", value: "1.24", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.5", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Vitamin D", value: "32.2", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "20.0", plottablerefupperlimit: "50.0"),
            BasicMedicalTestRecordv1(test: "Bilirubin", value: "1.5", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.3", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Haemoglobin2", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit:"5", plottablerefupperlimit: "10"),
            BasicMedicalTestRecordv1(test: "Haemoglobin3", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
            BasicMedicalTestRecordv1(test: "Free Testosterone2", value: "1.24", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.5", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Vitamin D3", value: "32.2", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "20.0", plottablerefupperlimit: "50.0"),
            BasicMedicalTestRecordv1(test: "Bilirubin4", value: "1.5", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.3", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Haemoglobin9", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit:"5", plottablerefupperlimit: "10"),
            BasicMedicalTestRecordv1(test: "Bilirubin7", value: "1.5", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.3", plottablerefupperlimit: "2.0"),
            BasicMedicalTestRecordv1(test: "Haemoglobin10", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit:"5", plottablerefupperlimit: "10")
        ]

        
        //creating mock medical document section
        let mockDocumentSection = MedicalDocumentSection()
        let mockDocumentSection2 = MedicalDocumentSection()
        for record in records{
            mockDocumentSection.addNewMedicalTestRecords(testRecords: record)
            mockDocumentSection2.addNewMedicalTestRecords(testRecords: record)
        }
        
        for record in records2{
            mockDocumentSection2.addNewMedicalTestRecords(testRecords: record)
        }
        
        let date1 = Date(timeIntervalSince1970: 20000)
        let mockMedicalDocument = MedicalDocument(pdfDocumentUrl: mockPdfUrl!,date: date1)
        let date2 = Date()
        let mockMedicalDocument2 = MedicalDocument(pdfDocumentUrl: mockPdfUrl!,date: date2)
        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
        
        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
        
        mockMedicalDocument.name = "LFT and KFT with other gastonomical tests"
        mockMedicalDocument.summary = "Everything looks good, you can consult a gastrologist for in-depth analysis"
        
        //adding to the system
        system.medicalDocuments.append(mockMedicalDocument)
        system.medicalDocuments.append(mockMedicalDocument2)

    }

}



// MARK: - Home View
struct HomeView: View {
    @ObservedObject var sys = system
    var body: some View {
        NavigationView{
           
                VStack {
                    GeometryReader{ geo in
                        ScrollView(showsIndicators: false){
                        
                            Text("You have \(sys.medicalDocuments.count) medical \(sys.medicalDocuments.count==1 ? "document" : "documents") containing \(sys.totalTestRecordsCount()) tests")
                            .fontWeight(.bold)
                            .padding()
                        
                        if sys.medicalDocuments.count != 0{
                            ForEach(sys.medicalDocuments){ doc in
                                MedicalDocumentViewerSmall(size: geo.size, doc: doc)
                                //MedicalDocumentViewer(size: geo.size, doc: sys.medicalDocuments.first!)
                            }
                        }else{
                            // ContentView()
                            PDFUploaderView()
                        }
                        
                    }
                }
            }
            .padding()
            .navigationTitle("Home")
        }
    

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




