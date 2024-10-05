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
    @State var documentName = ""
    @State var documentNotes = ""
    @State var showActionSheet = false
    @State var docDate = Date()
    @State private var isSharePresented = false
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
                                self.showAddTestManuallyScreen.toggle()
                            }) {
                                Image(systemName: "plus")  // SF Symbol for plus icon
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                // Your action here
                                self.showActionSheet.toggle()
                            }) {
                                Image(systemName: "info.circle")  // SF Symbol for info icon
                            }
                            .actionSheet(isPresented: $showActionSheet) {
                                ActionSheet(
                                    title: Text("Actions"),
                                    message: Text(""),
                                    buttons: [
                                        .default(Text("Share Original Document (PDF)")) {
                                            // Navigate to chart view for separate tracking
                                            //mergeSelectedGroups = false
                                           // navigateToChartView()
                                            //print("Each Test Separately")
        //                                        showUpdateTestManuallyScreen.toggle()
                                            isSharePresented.toggle()
                                           // SharePDFView(pdfURL: doc.pdfDocumentUrl,width: system.fullWidth*0.2)
                                        },
                                        .destructive(Text("Delete Medical Report")) {
        //                                        deleteTestRecord()
                                            //system.medicalDocuments
                                            system.deleteDocument(document: doc)
                                        },
                                        .cancel()
                                    ]
                                )
                            }
                            .sheet(isPresented: $isSharePresented) {
                                ShareSheet(activityItems: [doc.pdfDocumentUrl])
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
             //   ScrollView{
//                    HStack{
//                        VStack(alignment: .leading){
//                            Text("Share original document")
//                                .fontWeight(.bold)
//                                .font(.headline)
//                            
//                        }.padding(.horizontal)
//                        Spacer()
//                    }
                    
                    //form to edit document name and document note
                ZStack(alignment: .bottom){
                    Form {
                        Section(header: Text("Medical Report Name")) {
                            TextField("Medical Report Name", text: $documentName)
                        }
                        
                        Section(header: Text("Date"),footer: Text("Adding date to your medical record helps you better analyze the variation of test results across time")) {
                            DatePicker("Select Date", selection: $docDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                        }
                        
                        Section(header: Text("Add Notes"),
                                footer: Text("You can add detailed notes about this medical document to help you reflect on any factors that may have influenced your test results at the time")) {
                            TextEditor(text: $documentNotes)
                                .frame(height: system.fullHeight/4) // Adjust height as needed for longer text input
                               // .padding(.vertical)
                            //                            .overlay(
                            //                                RoundedRectangle(cornerRadius: 8)
                            //                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            //                            ) // Optional: adds border around the text editor
                        }
                    }
                    
                    
                    //delete, share original document, share biomarker data
                    .navigationTitle("Medical Record")
                    
                    
                }.onAppear{
                    self.documentName = doc.name
                    self.documentNotes = doc.notes
                    self.docDate = doc.date
                }
                .onChange(of: documentName) { newValue in
                    doc.name = newValue
                }
                .onChange(of: documentNotes) { newValue in
                    doc.notes = newValue
                }
                .onChange(of: docDate) { newValue in
                    doc.date = docDate
                }
              //  }
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
                            
                        /*
                         
                         HStack{
                            
                             
                             Button(action: {
                                 print("Delete medical document- todo")
                             }) {
                                 label("Delete Report", textColor: .primaryInvert, bgColor: .red, imgName: "trash.fill", imgColor: .primaryInvert, width: system.fullWidth*0.5, radius: 10)
                             }
                             
                         }
                         */
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


