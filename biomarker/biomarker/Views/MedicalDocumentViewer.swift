//
//  MedicalDocumentViewer.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation
import SwiftUI

struct MedicalDocumentViewerSmall: View{
    @ObservedObject var sys = system
    var size: CGSize
    var doc : MedicalDocument
    var allowNavtoMedicalDocumentViewerHandler = true
    var body: some View{
        if allowNavtoMedicalDocumentViewerHandler{
            NavigationLink(destination: MedicalDocumentViewerHandler(size: size, doc: doc)){
                MedicalDocumentViewerSmallInternal(size: size, doc: doc)
            }
        }else{
            MedicalDocumentViewerSmallInternal(size: size, doc: doc)
        }
        
    }
    
    struct MedicalDocumentViewerSmallInternal : View{
        @ObservedObject var sys = system
        var size: CGSize
        var doc : MedicalDocument
        var body : some View{
            VStack(alignment: .leading){
                
                HStack{
                    imageView(systemName: "doc.text.image", color: .primary)
                    
                    Text("Medical Report")
                        .fontWeight(.bold)
                    
                    
                }
                Text("\(doc.name)")
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
                    .padding([.bottom])
                
                HStack{
                    
                    imageView(systemName: "note.text", color: .primary)
                    
                    VStack(alignment: .leading){
                        Text("Summary")
                            .fontWeight(.bold)
                        
                        //.font(.title2)
                        // .padding([.top])
                        
                    }
                    
                    Spacer()
                }
                Text("\(doc.summary)")
                    .foregroundStyle(.secondary)
                    .padding([.bottom])
                    .multilineTextAlignment(.leading)
                
                HStack{
                    // Spacer()
                    VStack(alignment: .leading){
                        
                        //  Spacer()
                        HStack{
                            Text(Utils.formatDate(doc.date))
                            // .fontWeight(.bold)
                                .font(.headline)
                                .foregroundStyle(Color.secondary)
                            //.padding([.leading])
                            Spacer()
                        }
                        
                        
                        HStack{
                            Text("Tests")
                            // .fontWeight(.bold)
                                .font(.subheadline)
                            
                            
                            Text("\(doc.totalTestRecordsCount())")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        }
                        // Spacer()
                        HStack{
                            Text("Out of ref range")
                            //   .fontWeight(.bold)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                            
                            Text("\(doc.totalTestOutOfRangeCount())")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        }
                        
                    }
                    Spacer()
                }.foregroundColor(.primary)
                    .padding([.top])
            }
            .padding()
            .background(CustomBlur(style: .prominent))
            .cornerRadius(20)
            .padding([.horizontal,.top])
            .foregroundColor(.primary)
            
        }
    }
}

struct MedicalDocumentViewerHandler: View{
    @ObservedObject var sys = system
    var size: CGSize
    var doc : MedicalDocument
    @State var showAddTestManuallyScreen = false
    @State var testRecordPicker = 0//0- for full detail, 1 for brief, 2 for other options like share, delete, chart with ai etc
    var body: some View{
        VStack{
            Picker("", selection: $testRecordPicker) {
                            Text("Detailed").tag(0)
                            Text("Brief").tag(1)
                            Text("More").tag(2)
                           
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
            
            
            if testRecordPicker == 0 {
                MedicalDocumentViewerDetailed(size: size, doc: doc)
                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button(action: {
                                                // Your action here
                                                //print("Plus button tapped")
                                                self.showAddTestManuallyScreen.toggle()
                                            }) {
                                                Image(systemName: "plus")  // SF Symbol for plus icon
                                            }
                                        }
                                    }
                    .sheet(isPresented: $showAddTestManuallyScreen){
                        CreateTestRecordView(showSelf: $showAddTestManuallyScreen, document: doc)
                    }
            }
            
            if testRecordPicker == 1 {
                ScrollView{
                    //this should have AI features as well
                    MedicalDocumentViewerSmall(size: size, doc: doc, allowNavtoMedicalDocumentViewerHandler: false)
                        .navigationTitle("Medical Record")
                        
                }
            }
            
            if testRecordPicker == 2 {
                ScrollView{
//                    HStack{
//                        VStack(alignment: .leading){
//                            Text("Share original document")
//                                .fontWeight(.bold)
//                                .font(.headline)
//                            
//                        }.padding(.horizontal)
//                        Spacer()
//                    }
                    
                    SharePDFView(pdfURL: doc.pdfDocumentUrl)
                    
                    Button(action: {
                       print("Delete medical document- todo")
                    }) {
                        label("Delete Medical Document", textColor: .primaryInvert, bgColor: .red, imgName: "trash.fill", imgColor: .primaryInvert, width: 300, radius: 10)
                    }
                    
                    //delete, share original document, share biomarker data
                        .navigationTitle("Medical Record")
                    
                    
                        
                }
               // MedicalDocumentViewerDetailed(size: size, doc: doc)
            }
            

        }
    }
}

//This view is used to represent a MedicalDocumentView
struct MedicalDocumentViewerDetailed: View{
    @ObservedObject var sys = system
    var size: CGSize
    @State var showPDFViewer = false
    @State var testRecordPicker = 0//0- for all, 1 for out of range
    var doc : MedicalDocument
    var body: some View{
        ScrollView(showsIndicators: false){
            VStack(alignment: .leading){
                
                
                
                Button(action: {
                    showPDFViewer.toggle()
                }){
                    VStack{
                        HStack{
                            
                            imageView(systemName: "doc.text.image", color: .primary)
                            
                            Text(doc.name)
                                .multilineTextAlignment(.leading)
                                .fontWeight(.bold)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding([.top,.bottom])
                            
                            Spacer()
                        }
                        
//                    HStack{
//                        Text("\(doc.name)")
//                            .multilineTextAlignment(.leading)
//                            .foregroundStyle(Color.secondary)
//                            .padding([.leading,.bottom])
//                        Spacer()
//                    }
                        
                        
                        VStack{
                            // Spacer()
                            
                            
                        }
                        //   Spacer()
                        
                        PDFViewer(url: doc.pdfDocumentUrl)
                        //.frame(width: (size.height*0.4)/1.77,height: size.width*0.4)
                            .frame(width: size.width*0.85,height: (size.width*0.85)/1.77)
                            .cornerRadius(20)
                        
                        //  Spacer()
                        
                        HStack{
                            // Spacer()
                            VStack(alignment: .leading){
                                
                                //  Spacer()
                                HStack{
                                    Text(Utils.formatDate(doc.date))
                                        .fontWeight(.bold)
                                        .font(.title3)
                                        .foregroundStyle(Color.secondary)
                                        //.padding([.leading])
                                    Spacer()
                                }
                                
                                
                                HStack{
                                    Text("Tests")
                                        .fontWeight(.bold)
                                        .font(.subheadline)
                                    
                                    
                                    Text("\(doc.totalTestRecordsCount())")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                }
                                // Spacer()
                                HStack{
                                    Text("Out of ref range")
                                        .fontWeight(.bold)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("\(doc.totalTestOutOfRangeCount())")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                }
                               
                            }
                            Spacer()
                        }.foregroundColor(.primary)
                            .padding([.leading,.top])
                        
                    }
                        
                    }
                        
                        .padding()
                        .background(CustomBlur(style: .prominent))
                        .cornerRadius(20)
                        .padding()
                    
                    .sheet(isPresented: $showPDFViewer) {
                        NavigationView{
                            PDFViewer(url: doc.pdfDocumentUrl)
                                .navigationTitle("Original Document")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                   
                                        Button("Close") {
                                            showPDFViewer.toggle()
                                        }
                                    
                                }
                        }
                        
                    }
                    
                    VStack{
                        HStack{
                            
                            imageView(systemName: "note.text", color: .primary)
                            
                            Text("Summary")
                                .fontWeight(.bold)
                                .font(.title2)
                                .padding([.top,.bottom])
                            
                            Spacer()
                        }
                        
                        Text("Biomarker found \(doc.totalTestRecordsCount()) tests in the document. \(doc.summary)")
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(CustomBlur(style: .prominent))
                    .cornerRadius(20)
                    .padding()
                    
                    
                    VStack{
                        HStack{
                            
                            imageView(systemName: "heart.text.square", color: .primary)
                            
                            Text("Health Insights")
                                .fontWeight(.bold)
                                .font(.title2)
                                .padding([.top,.bottom])
                            
                            Spacer()
                        }
                        
                        Text(doc.healthInsights)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(CustomBlur(style: .prominent))
                    .cornerRadius(20)
                    .padding()
                
               
            //list of testRecords
                
                Picker("", selection: $testRecordPicker) {
                                Text("All Tests").tag(0)
                                Text("Out of Range Tests").tag(1)
                                Text("Plain List").tag(2)
                               
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                

              
                ForEach(doc.sections){ section in
                   
                    if getSectionTestRecords(section: section,val: testRecordPicker).count != 0{
                        Text(section.name.isEmpty ? "Report Section \(doc.findIndexOfSection(section: section)+1)" : section.name)
                            .fontWeight(.bold)
                            .font(.title)
                            .padding(.horizontal)
                            .padding([.top,.top])
                            .padding(.bottom,4)
                    }
                    
                    ForEach(getSectionTestRecords(section: section,val: testRecordPicker)){ testRecord in
                        VStack{
                            if testRecordPicker == 2{
                                TestRecordPlainView(testRecord: testRecord)
                                    .padding(.horizontal)
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
               
            }//.padding()
            .navigationTitle("Medical Record")
            
            //for now
           // PDFUploaderView()
                
        }
    }
    
    func getSectionTestRecords(section: MedicalDocumentSection,val: Int)->[BasicMedicalTestRecordv1]{
      
        var sectionTestRecords = [BasicMedicalTestRecordv1]()
        
      
            for testRecord in section.testRecords{
                if val == 1 {//1 means only pick out of range tests
                    if testRecord.isOutOfRange(){
                        sectionTestRecords.append(testRecord)
                    }
                }else if val == 0 || val == 2{//0 means pick all the tests, 2 means a plain list of test names
                        sectionTestRecords.append(testRecord)
                }
                
            }
        
        return sectionTestRecords
      
    }
    
}


