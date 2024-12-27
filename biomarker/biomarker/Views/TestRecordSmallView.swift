//
//  TestRecordSmallView.swift
//  biomarker
//
//  Created by sachin jeph on 02/10/24.
//

import Foundation
import SwiftUI
import Charts

//struct BasicMedicalTestRecordv1: Identifiable {
//    let id = UUID()
//    let test: String
//    let value: Double
//    let plottable: String
//    let plottableref: Bool
//    let plottablerefupperlimit: Double?
//    let plottablereflowerlimit: Double?
//}

//struct ContentView: View {
//    // Sample Data
//    let records: [BasicMedicalTestRecordv1] = [
//        BasicMedicalTestRecordv1(test: "Haemoglobin", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "no", plottablereflowerlimit:nil, plottablerefupperlimit: nil),
//        BasicMedicalTestRecordv1(test: "Free Testosterone", value: "1.24", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.5", plottablerefupperlimit: "2.0"),
//        BasicMedicalTestRecordv1(test: "Vitamin D", value: "32.2", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "20.0", plottablerefupperlimit: "50.0"),
//        BasicMedicalTestRecordv1(test: "Bilirubin", value: "1.5", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit: "0.3", plottablerefupperlimit: "2.0"),
//        BasicMedicalTestRecordv1(test: "Haemoglobin2", value: "13", unit: "mg/dl", plottable: "yes", plottableref: "yes", plottablereflowerlimit:"5", plottablerefupperlimit: "10"),
//    ]
//    
//    var body: some View {
////        List(records) { record in
////            VStack(alignment: .leading) {
////                TestRecordView(record: record)
////            }
////            .padding()
////        }
////        .navigationTitle("Test Results")
//        ForEach(records){ record in
//            VStack{
//                TestRecordView(record: record)
//            }.padding()
//                .background(CustomBlur(style: .prominent))
//            
//        }
//    }
//}




struct TestRecordView: View {
    @ObservedObject var sys = system
    var record: BasicMedicalTestRecordv1
    var showEditOptions : Bool = true
    var showAIInfoButton = true
    @State var showAIInfoPopup = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
           
          
                HStack{
                    Text(record.userFacingTestName())
                        .font(.title3)
                        .fontWeight(.bold)
                       
                    if showEditOptions{
                        TestRecordEditActionView(testRecord: record)
                    }
                    
                    Spacer()
                    
                    imageView(systemName: record.isOutOfRange() ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",color: record.isOutOfRange() ? .red : .green,size: 30)
                        .padding(.trailing,3)
                    
                    
                    
                }//.padding(.bottom,1)
                .padding(.leading)
                
                
                
                
            HStack{
                if (record.test != record.userFacingTestName()){
                    Text(record.test)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }.padding([.leading])
            .foregroundColor(.secondary)
            
            if(record.ai_info_available() && showAIInfoButton){
                Button(action:{
                    showAIInfoPopup.toggle()
                }){
                   // label("Learn more about \(record.userFacingTestName())", textColor: .primaryInvert, bgColor: .primary, imgName: "doc.text.image", imgColor: .primaryInvert, width: 100, radius: 10)
                    ShowTestAIInfoButtonView(record: record)
                        .padding(.vertical,5)
                        .padding(.leading)
                   
                }
                .sheet(isPresented: $showAIInfoPopup){
                    ScrollView(showsIndicators: false){
                        TestAIInfoView(testRecord: record, showPopupCloseButton: true, showChart: true, showSelf: $showAIInfoPopup)
                    }
                }
            }
            
                HStack{
                    Text(record.value)
                        .font(.headline)
                        .fontWeight(.bold)
                       
                    
                    Text(record.userFacingUnit())
                        .font(.headline)
                    
                }.padding([.bottom,.leading])
                .foregroundColor(.secondary)
            
       
               
           
            
            VStack{
                if let testValue = Double(record.value) {
                    if record.plottablerefupperlimit == nil && record.plottablereflowerlimit == nil {
                        // Bar chart when upper and lower limits are not available
                        Chart {
                            BarMark(
                                x: .value("Test", "Test Value"),
                                y: .value("Value", testValue.truncate(places: 2))
                            )
                            .foregroundStyle(Color.dashboardM3OrangeBar)
                            .annotation(position: .top, alignment: .leading) {
                                // Text("\(testValue.truncate(places: 2))")
                                Text(String(format: "%.2f", testValue))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.dashboardM3OrangeBar)
                                    .cornerRadius(6)
                                    .offset(x: 0, y: -5) // Adjust annotation position
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartXAxis {
                            AxisMarks(position: .bottom)
                        }
                        .frame(height: 150)
                    } else {
                        // Test value and range chart when upper/lower limits are available
                        Chart {
                            // Green circle for test value
                            PointMark(
                                x: .value("Test", "Test Value"),
                                y: .value("Value", testValue)
                            )
                            .symbolSize(60)
                            .foregroundStyle(record.isOutOfRange() ? .red : .green)
                            .annotation(position: .top, alignment: .leading) {
                                Text(String(format: "%.2f", testValue))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(record.isOutOfRange() ? Color.red : Color.green)
                                    .cornerRadius(6)
                                    .offset(x: 10, y: 10) // Adjust to prevent overlap
                            }
                            
                            // Upper reference limit line
                            if let upperLimit = Double(record.plottablerefupperlimit ?? "") {
                                RuleMark(y: .value("Upper Limit", upperLimit.truncate(places: 2)))
                                    .foregroundStyle(.red)
                                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.5, 5]))
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("Upper: \(String(format: "%.2f", upperLimit))")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                            }
                            
                            // Lower reference limit line
                            if let lowerLimit = Double(record.plottablereflowerlimit ?? "") {
                                RuleMark(y: .value("Lower Limit", lowerLimit.truncate(places: 2)))
                                    .foregroundStyle(.blue)
                                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.5, 5]))
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("Lower: \(String(format: "%.2f", lowerLimit))")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartXAxis {
                            AxisMarks(position: .bottom)
                        }
                        .frame(height: 150)
                    }
                        
                } else {
                    Text("Something went wrong with the medical test values")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
            }//.background(CustomBlur(style: .prominent))
              //  .cornerRadius(20)
              //  .padding()
            
            
            if (record.isOutOfRange()){
                HStack{
                    imageView(systemName: "exclamationmark.triangle",color: .red)
                    //.foregroundColor(.red)
                    Text("Out of the reference range")
                        .fontWeight(.bold)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                    
                } .padding(.top)
                
            }
            
            if(record.ai_info_available()){
                Text("Powered by Biomarker Intelligence")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
                    .padding(.leading)
            }
           
            
        }
       // .padding()
    }
}

struct ShowTestAIInfoButtonView: View{
    var record: BasicMedicalTestRecordv1
    var body: some View{
            HStack{
                imageView(systemName: "staroflife.fill",color: .primaryInvert)
                Text("More about \(record.userFacingTestName())")
                    .foregroundStyle(Color.primaryInvert)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
            }.padding(.horizontal)
                .padding(.vertical,5)
                .background(Color.primary)
            .background(CustomBlur(style: .prominent))
                .cornerRadius(10)
        }
    
}

struct TestRecordPlainView: View{
    @ObservedObject var sys = system
    var testRecord : BasicMedicalTestRecordv1
    var showDate : Bool = false
    var body: some View{
        HStack{
            VStack{
                HStack{
                    Text(testRecord.userFacingTestName())
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                } .padding(.leading)
                HStack{
                    if (testRecord.test != testRecord.userFacingTestName()){
                        Text(testRecord.test)
                            .font(.caption)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom,4)
                            .padding(.leading)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                HStack{
                    Text(testRecord.value)
                        .fontWeight(.bold)
                    Text(testRecord.userFacingUnit())
                        .fontWeight(.bold)
                    Spacer()
                }.padding(.leading)
                if testRecord.plottablereflowerlimit != nil && testRecord.plottablerefupperlimit != nil{
                    HStack{
                        //                                                Text("Should be between")
                        //                                                Text(testRecord.plottablerefupperlimit ?? "")
                        //                                                Text("\(Text(testRecord.userFacingUnit())) and")
                        //                                                Text(testRecord.plottablereflowerlimit ?? "")
                        //                                                Text(testRecord.userFacingUnit())
                        if testRecord.ref_range_male_exists() && testRecord.ref_range_female_exists(){
                            VStack(alignment: .leading){
                                Text("Male ref range \(testRecord.ai_ref_range_lower_male!.truncated(toDecimalPlaces: 2) ) - \(testRecord.ai_ref_range_upper_male!.truncated(toDecimalPlaces: 2)) \(testRecord.userFacingUnit())")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                                
                                Text("Female ref range \(testRecord.ai_ref_range_lower_female!.truncated(toDecimalPlaces: 2)) - \(testRecord.ai_ref_range_upper_female!.truncated(toDecimalPlaces: 2)) \(testRecord.userFacingUnit())")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                            }
                            
                        }else{
                            
                            
                            Text("Should be between \(testRecord.plottablereflowerlimit ?? "") and \(testRecord.plottablerefupperlimit ?? "") \(testRecord.userFacingUnit())")
                                .font(.subheadline)
                            //.fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }.padding(.leading)
                        .foregroundStyle(Color.secondary)
                }
                
                if showDate{
                    HStack{
                        Text(Utils.formatDate(testRecord.testDate() ?? Date()))
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .padding(.top,4)
                        Spacer()
                    } .padding(.leading)
                }
                
            }
            TestRecordEditActionView(testRecord: testRecord,iconSize: 20).padding(.trailing,3)
            imageView(systemName: testRecord.isOutOfRange() ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",color: testRecord.isOutOfRange() ? .red : .green,size: 20)
                .padding(.trailing,3)
        }
    }
}
