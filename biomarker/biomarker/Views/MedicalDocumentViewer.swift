//
//  MedicalDocumentViewer.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation
import SwiftUI

//This view is used to represent a MedicalDocumentView
struct MedicalDocumentViewer: View{
    var size: CGSize
    @State var showPDFViewer = false
    @State var testRecordPicker = 0//0- for all, 1 for out of range
    var doc : MedicalDocument
    var body: some View{
        ScrollView(showsIndicators: false){
            VStack(alignment: .leading){
                Text(Utils.formatDate(doc.date))
                    .fontWeight(.bold)
                    .font(.title3)
                    .padding([.leading])
                
                
                
                Button(action: {
                    showPDFViewer.toggle()
                }){
                    VStack{
                        HStack{
                            
                            imageView(systemName: "doc.text.image", color: .primary)
                            
                            Text("Medical Report")
                                .fontWeight(.bold)
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding([.top,.bottom])
                            
                            Spacer()
                        }
                        
                        
                        VStack{
                            // Spacer()
                            
                            
                        }
                        //   Spacer()
                        
                        PDFViewer(url: doc.pdfDocumentUrl)
                        //.frame(width: (size.height*0.4)/1.77,height: size.width*0.4)
                            .frame(width: size.width*0.8,height: (size.width*0.8)/1.77)
                            .cornerRadius(20)
                        
                        //  Spacer()
                        
                        HStack{
                            // Spacer()
                            VStack(alignment: .leading){
                                
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
                                //  Spacer()
                                
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
                        PDFViewer(url: doc.pdfDocumentUrl)
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
                

              
                ForEach(doc.sections){ section in
                   
                    if getSectionTestRecords(section: section,val: testRecordPicker).count != 0{
                        Text("Report Section \(doc.findIndexOfSection(section: section)+1)")
                            .fontWeight(.bold)
                            .font(.title)
                            .padding()
                    }
                    
                    ForEach(getSectionTestRecords(section: section,val: testRecordPicker)){ testRecord in
                        VStack{
                            if testRecordPicker == 2{
                                HStack{
                                    VStack{
                                        HStack{
                                            Text(testRecord.test)
                                                .fontWeight(.bold)
                                            Spacer()
                                        } .padding(.leading)
                                        HStack{
                                            Text(testRecord.value)
                                            Text(testRecord.unit)
                                            Spacer()
                                        }.padding(.leading)
                                        if testRecord.plottablereflowerlimit != nil && testRecord.plottablerefupperlimit != nil{
                                            HStack{
//                                                Text("Should be between")
//                                                Text(testRecord.plottablerefupperlimit ?? "")
//                                                Text("\(Text(testRecord.unit)) and")
//                                                Text(testRecord.plottablereflowerlimit ?? "")
//                                                Text(testRecord.unit)
                                                Text("Should be between \(testRecord.plottablerefupperlimit ?? "") \(testRecord.unit) and \(testRecord.plottablereflowerlimit ?? "") \(testRecord.unit)")

                                                Spacer()
                                            }.padding(.leading)
                                                .foregroundStyle(Color.secondary)
                                        }
                                        
                                    }
                                    imageView(systemName: testRecord.isOutOfRange() ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",color: testRecord.isOutOfRange() ? .red : .green,size: 20)
                                        .padding(.trailing,3)
                                }
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
            
            //for now
            PDFUploaderView()
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


