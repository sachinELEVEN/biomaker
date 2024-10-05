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
            
//            SearchView()
//                .tabItem {
//                    Label("Search", systemImage: "magnifyingglass")
//                }
//            
            VariationView()
                .tabItem {
                    Label("Variation", systemImage: "chart.bar.fill")
                }
            
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }.onAppear{
            BiomarkerFileSystem.loadModelDataFromFile()
        }
        .accentColor(.primary)
    }
    
   public static func setMockMedicalDocument(){
   
        
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
            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "19", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
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
           // mockDocumentSection2.addNewMedicalTestRecords(testRecords: record)
        }
        
        for record in records2{
            mockDocumentSection2.addNewMedicalTestRecords(testRecords: record)
        }
        
        let date1 = Date(timeIntervalSince1970: 20000)
        let mockMedicalDocument = MedicalDocument(pdfDocumentUrl: mockPdfUrl!,date: date1)
        let date2 = Date()
        let mockMedicalDocument2 = MedicalDocument(pdfDocumentUrl: mockPdfUrl!,date: date2)
        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
//        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
//        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
//        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
        
//        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
//        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
//        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
        
        mockMedicalDocument.name = "LFT and KFT with other gastonomical tests"
        mockMedicalDocument.summary = "Everything looks good, you can consult a gastrologist for in-depth analysis"
        
        //adding to the system
        system.medicalDocuments.append(mockMedicalDocument)
        system.medicalDocuments.append(mockMedicalDocument2)

    }
    
    public static func getSampleDataForProd()->[MedicalDocument]{
        
        
        //creating mock test records
        let records: [BasicMedicalTestRecordv1] = [
            BasicMedicalTestRecordv1(test: "Bilirubin Total", value: "0.57", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:"0.1", plottablerefupperlimit: "1.2"),
            BasicMedicalTestRecordv1(test: "Bilirubin Direct", value: "0.25", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:"0", plottablerefupperlimit: "0.2"),
            BasicMedicalTestRecordv1(test: "Bilirubin Indirect", value: "0.43", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.2", plottablerefupperlimit: "0.8"),
            BasicMedicalTestRecordv1(test: "Albumin", value: "4.24", unit: "g/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "3.5", plottablerefupperlimit: "5.2"),
            BasicMedicalTestRecordv1(test: "Vitamin D", value: "32.2", unit: "ng/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "30.0", plottablerefupperlimit: "90.0"),
            BasicMedicalTestRecordv1(test: "ESR", value: "15", unit: "mm/hr", plottable: "yes", plottableref: "no", plottablereflowerlimit: nil, plottablerefupperlimit: nil)
        ]
        
        
//        let records2: [BasicMedicalTestRecordv1] = [
//            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
//            BasicMedicalTestRecordv1(test: "Haemoglobin", value: "16", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
//            BasicMedicalTestRecordv1(test: "Free Testosterone", value: "1.24", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.5", plottablerefupperlimit: "2.0"),
//            BasicMedicalTestRecordv1(test: "Free Testosterone", value: "1.24", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.5", plottablerefupperlimit: "2.0"),
//            BasicMedicalTestRecordv1(test: "Vitamin D", value: "32.2", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "20.0", plottablerefupperlimit: "50.0"),
//        ]
        
        

        
        //creating mock medical document section for document 1
        let mockDocumentSection1ForDoc1 = MedicalDocumentSection()
        let mockDocumentSection2ForDoc1 = MedicalDocumentSection()
        
        mockDocumentSection1ForDoc1.addNewMedicalTestRecords(testRecords: records[0])
        mockDocumentSection1ForDoc1.addNewMedicalTestRecords(testRecords: records[1])
        mockDocumentSection1ForDoc1.addNewMedicalTestRecords(testRecords: records[2])
        mockDocumentSection1ForDoc1.addNewMedicalTestRecords(testRecords: records[3])
        
        mockDocumentSection2ForDoc1.addNewMedicalTestRecords(testRecords: records[4])
        mockDocumentSection2ForDoc1.addNewMedicalTestRecords(testRecords: records[5])
        
        //creating mock medical document section for document 2
//        let mockDocumentSectionForDoc2 = MedicalDocumentSection()
//        let mockDocumentSection2ForDoc2 = MedicalDocumentSection()
//        
//        mockDocumentSectionForDoc2.addNewMedicalTestRecords(testRecords: records[0])
//        mockDocumentSectionForDoc2.addNewMedicalTestRecords(testRecords: records[1])
//        mockDocumentSectionForDoc2.addNewMedicalTestRecords(testRecords: records[2])
//        
//        mockDocumentSectionForDoc2.addNewMedicalTestRecords(testRecords: records[3])
//        mockDocumentSectionForDoc2.addNewMedicalTestRecords(testRecords: records[4])
//        
        
        
        
        let date1 = Date(timeIntervalSince1970: 1700000000)//15 november 2023
        let mockMedicalDocument1 = MedicalDocument(pdfDocumentUrl: mockPdfUrl!,date: date1)
        mockMedicalDocument1.addNewMedicalSection(section: mockDocumentSection1ForDoc1)
        mockMedicalDocument1.addNewMedicalSection(section: mockDocumentSection2ForDoc1)
        //let date2 = Date(timeIntervalSinceNow: -500000)
      //  let mockMedicalDocument2 = MedicalDocument(pdfDocumentUrl: mockPdfUrl!,date: date2)
       // mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
//        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
//        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
//        mockMedicalDocument.addNewMedicalSection(section: mockDocumentSection)
        
//        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
//        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
//        mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
      //  mockMedicalDocument2.addNewMedicalSection(section: mockDocumentSection2)
        
        mockMedicalDocument1.name = "(Sample) LFT with Vitamin D Report- November 23"
        mockMedicalDocument1.summary = "This sample document shows you how your medical reports will appear in Biomarker. Checkout report charts and variations"
        
//        mockMedicalDocument2.name = "(Sample) LFT with Vitamin D Report- January"
//        mockMedicalDocument2.summary = ""

        
        return [mockMedicalDocument1]
//        system.medicalDocuments.append(mockMedicalDocument1)
//        system.medicalDocuments.append(mockMedicalDocument2)

    }

}



// MARK: - Home View
struct HomeView: View {
    @ObservedObject var sys = system
    @State var showPdfUploadScreen = false
    var body: some View {
        NavigationView{
           
                VStack {
                    GeometryReader{ geo in
                        ScrollView(showsIndicators: false){
                        
                            Text("You have \(sys.medicalDocuments.count) medical \(sys.medicalDocuments.count==1 ? "document" : "documents") containing \(sys.totalTestRecordsCount()) tests")
                            .fontWeight(.bold)
                            .padding()
                        
                            Button(action:{
                                showPdfUploadScreen.toggle()
                            }){
                                label("Add Medical Report (PDF)", textColor: .primaryInvert, bgColor: .primary, imgName: "doc.text.image", imgColor: .primaryInvert, width: geo.size.width*0.8, radius: 10)
                            }
                            .sheet(isPresented: $showPdfUploadScreen){
                                PDFUploaderView(showSelf: $showPdfUploadScreen)
                            }
                           
                            
                        if sys.medicalDocuments.count != 0{
                            ForEach(sys.medicalDocuments.sorted { $0.date > $1.date }){ doc in
                                MedicalDocumentViewerSmall(size: geo.size, doc: doc)
                                //MedicalDocumentViewer(size: geo.size, doc: sys.medicalDocuments.first!)
                            }
                        }else{
                            // ContentView()
                           // PDFUploaderView()
                            Text("Add your first medical pdf report and store, manage, analyze it with Biomarker")
                                .fontWeight(.bold)
                                .font(.largeTitle)
                                .foregroundStyle(.brightpurple)
                                .padding()
                                .padding([.top,.top])
                        }
                        
                    }
                }
            }
                
                .padding([.horizontal])
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




