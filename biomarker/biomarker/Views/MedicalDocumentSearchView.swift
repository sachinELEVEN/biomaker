//
//  MedicalDocumentSearchView.swift
//  biomarker
//
//  Created by sachin jeph on 29/12/24.
//

import Foundation
import SwiftUI

struct MedicalDocumentSearchView: View{
    @Binding var showSelf : Bool
    @State var testRecordPicker = 0
    var doc : MedicalDocument
    @State private var searchText = ""
    @State private var allTestRecords: [BasicMedicalTestRecordv1] = [] // Your full list of test records
    @State private var filteredTestRecords: [BasicMedicalTestRecordv1] = [] // Filtered list for display
    @State private var isSearching: Bool = false // Show a loading indicator during search- not using it for now, since its local seaarch and should be fast
    var body: some View{
        VStack(alignment: .leading){
           
            Text("Search")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding()
            
            TextField("Search tests in this medical document", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            ScrollView(showsIndicators: false){
                VStack(alignment:.leading){
                    Text("You can search for tests by their name, organs or body parts they are related to")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding([.bottom,.horizontal])
                    //Filtered tests
                    Picker("", selection: $testRecordPicker) {
                                    Text("All Tests").tag(0)
                                    Text("Out of Range Tests").tag(1)
                                    Text("Plain List").tag(2)
                                   
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                    

                  /*
                    ForEach(doc.sections){ section in
                       
                        if MedicalDocumentViewerDetailed.getSectionTestRecords(section: section,val: testRecordPicker).count != 0{
                            Text(section.name.isEmpty ? "Report Section \(doc.findIndexOfSection(section: section)+1)" : section.name)
                                .fontWeight(.bold)
                                .font(.title)
                                .padding(.horizontal)
                                .padding([.top,.top])
                                .padding(.bottom,4)
                        }
                        */
                        
                        ForEach(filteredTestRecords){ testRecord in
                            VStack{
                                if testRecordPicker == 2{
                                    TestRecordPlainView(testRecord: testRecord)
                                        .padding([.horizontal,.top])
                                    Divider().padding(.horizontal).padding(.vertical,3)
                                }else{
                                    TestRecordView(record: testRecord)
                                        .padding()
                                        //.background(Color.secondary.opacity(0.2))
                                            .background(CustomBlur(style: .prominent))
                                            .cornerRadius(20)
                                            .padding([.horizontal,.top])
                                }
                                
                                 // Text("")
                            }
                        }
                  //  }

                }
            }
        }.onAppear{
            loadAllTests()
        }
        .onChange(of: searchText){newValue in
            if newValue.isEmpty {
                filteredTestRecords = allTestRecords // No filtering needed
                } else {
                    performSearch(searchText: newValue)
                }
        }
    }
    
    private func loadAllTests() {
        print("/MedicalDocumentSearchView /loadAllTests - Loading all tests")
            // Simulate loading test records (replace with your actual logic)
        filteredTestRecords.removeAll()
        allTestRecords.removeAll()
        for section in doc.sections{
            for test in section.testRecords{
                allTestRecords.append(test)
                filteredTestRecords.append(test)
            }
        }
    }
    
    private func performSearch(searchText: String) {
            // Show loading indicator and perform the search on a background thread
            isSearching = true
            DispatchQueue.global(qos: .userInitiated).async {
                let searchResults = allTestRecords.filter { $0.satisfiesSearch(searchStr: searchText.lowercased()) }
                DispatchQueue.main.async {
                    // Update the UI with the filtered results on the main thread
                    filteredTestRecords = searchResults
                    isSearching = false
                }
            }
        }
}
