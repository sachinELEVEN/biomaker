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
                    

                  
                    ForEach(doc.sections){ section in
                       
                        if MedicalDocumentViewerDetailed.getSectionTestRecords(section: section,val: testRecordPicker).count != 0{
                            Text(section.name.isEmpty ? "Report Section \(doc.findIndexOfSection(section: section)+1)" : section.name)
                                .fontWeight(.bold)
                                .font(.title)
                                .padding(.horizontal)
                                .padding([.top,.top])
                                .padding(.bottom,4)
                        }
                        
                        ForEach(MedicalDocumentViewerDetailed.getSectionTestRecords(section: section,val: testRecordPicker)){ testRecord in
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
                    }

                }
            }
        }
    }
}
