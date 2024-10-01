//
//  TestRecordSmallView.swift
//  biomarker
//
//  Created by sachin jeph on 02/10/24.
//

import Foundation
import SwiftUI
import Charts

struct BasicMedicalTestRecordv2: Identifiable {
    let id = UUID()
    let test: String
    let value: Double
    let plottable: String
    let plottableref: Bool
    let plottablerefupperlimit: Double?
    let plottablereflowerlimit: Double?
}

struct ContentView: View {
    // Sample Data
    let records: [BasicMedicalTestRecordv2] = [
        BasicMedicalTestRecordv2(test: "Haemoglobin", value: 13, plottable: "yes", plottableref: false, plottablerefupperlimit: nil, plottablereflowerlimit:nil),
        BasicMedicalTestRecordv2(test: "Free Testosterone", value: 1.24, plottable: "yes", plottableref: true, plottablerefupperlimit: 2.0, plottablereflowerlimit: 0.5),
        BasicMedicalTestRecordv2(test: "Vitamin D", value: 32.2, plottable: "yes", plottableref: true, plottablerefupperlimit: 50.0, plottablereflowerlimit: 20.0),
        BasicMedicalTestRecordv2(test: "Bilirubin", value: 1.5, plottable: "yes", plottableref: true, plottablerefupperlimit: 2.0, plottablereflowerlimit: 0.3)
    ]
    
    var body: some View {
        List(records) { record in
            VStack(alignment: .leading) {
                TestRecordView2(record: record)
            }
            .padding()
        }
        .navigationTitle("Test Results")
    }
}

import SwiftUI
import Charts

struct TestRecordView: View {
    var record: BasicMedicalTestRecordv2
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.test)
                .font(.headline)
            
            // Test value and range chart
            Chart {
                // Green circle for test value
                PointMark(
                    x: .value("Test", "Test Value"),
                    y: .value("Value", record.value)
                )
                .symbolSize(60)
                .foregroundStyle(.green)
                // Annotation for the test value
                .annotation(position: .top, alignment: .leading) {
                    Text("\(record.value)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.green)
                        .cornerRadius(6)
                        .offset(x: 10, y: 10) // Adjust to prevent overlap
                }
                
                if record.plottablereflowerlimit != nil && record.plottablerefupperlimit != nil{
                    // Upper reference limit line
                    RuleMark(y: .value("Upper Limit", record.plottablerefupperlimit ?? 0))
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Upper: \(record.plottablerefupperlimit ?? 0)")
                                .font(.caption)
                                .foregroundColor(.red)
                            // .padding(4)
                            // .background(Color.red)
                            // .cornerRadius(6)
                        }
                    
                    // Lower reference limit line
                    RuleMark(y: .value("Lower Limit", record.plottablereflowerlimit ?? 0))
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Lower: \(record.plottablereflowerlimit ?? 0)")
                                .font(.caption)
                                .foregroundColor(.blue)
                            //.padding(4)
                            //.background(Color.blue)
                            //.cornerRadius(6)
                        }
                }
                }
            
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis(.hidden) // Hide horizontal scale lines
            .chartXAxis(.hidden) // Hide horizontal scale lines
            .frame(height: 150)
            .padding()
            .background(CustomBlur(style: .prominent))
            .cornerRadius(10)
        }
        .padding()
    }
}

struct TestRecordView2: View {
    var record: BasicMedicalTestRecordv2
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.test)
                .font(.headline)
            
            if record.plottablerefupperlimit == nil && record.plottablereflowerlimit == nil {
                // Bar chart when upper and lower limits are not available
                Chart {
                    BarMark(
                        x: .value("Test", "Test Value"),
                        y: .value("Value", record.value)
                    )
                    .foregroundStyle(Color.dashboardM3OrangeBar)
                    .annotation(position: .top, alignment: .leading) {
                        Text("\(record.value)")
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
               // .chartYAxis(.hidden) // Hide horizontal scale lines
                .frame(height: 150)
            } else {
                // Test value and range chart when upper/lower limits are available
                Chart {
                    // Green circle for test value
                    PointMark(
                        x: .value("Test", "Test Value"),
                        y: .value("Value", record.value)
                    )
                    .symbolSize(60)
                    .foregroundStyle(.green)
                    .annotation(position: .top, alignment: .leading) {
                        Text("\(record.value)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.green)
                            .cornerRadius(6)
                            .offset(x: 10, y: 10) // Adjust to prevent overlap
                    }
                    
                    // Upper reference limit line
                    if let upperLimit = record.plottablerefupperlimit {
                        RuleMark(y: .value("Upper Limit", upperLimit))
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(lineWidth: 5, dash: [5]))
                            .annotation(position: .top, alignment: .leading) {
                                Text("Upper: \(upperLimit)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                    }
                    
                    // Lower reference limit line
                    if let lowerLimit = record.plottablereflowerlimit {
                        RuleMark(y: .value("Lower Limit", lowerLimit))
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                            .annotation(position: .top, alignment: .leading) {
                                Text("Lower: \(lowerLimit)")
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
                //.chartYAxis(.hidden) // Hide horizontal scale lines
                .frame(height: 150)
            }
        }
        .padding()
    }
}
