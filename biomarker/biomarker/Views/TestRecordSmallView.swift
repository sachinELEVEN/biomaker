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
    var record: BasicMedicalTestRecordv1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
           
          
                HStack{
                    Text(record.test)
                        .font(.headline)
                       
                    
                    
                    Spacer()
                    
                    imageView(systemName: record.isOutOfRange() ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",color: record.isOutOfRange() ? .red : .green,size: 40)
                        .padding(.trailing,3)
                    
                    
                    
                }.padding(.bottom,3)
                
                
                
                
                HStack{
                    Text(record.value)
                        .font(.headline)
                        .fontWeight(.bold)
                       
                    
                    Text(record.unit)
                        .font(.headline)
                    
                }.padding(.bottom)
       
               
           
            
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
                                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
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
                                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
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
            
        }
       // .padding()
    }
}

