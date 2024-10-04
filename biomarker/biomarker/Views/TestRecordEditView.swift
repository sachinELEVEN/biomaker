//
//  TestRecordEditvIEW.swift
//  biomarker
//
//  Created by sachin jeph on 04/10/24.
//

import Foundation
import SwiftUI

import SwiftUI

struct CreateTestRecordView: View {
    @Binding var showSelf : Bool
    var document : MedicalDocument
    @State private var test = ""
    @State private var value: Double? = nil  // Double binding for value
    @State private var unit = ""
    @State private var plottablereflowerlimit: Double? = nil  // Double binding for lower ref limit
    @State private var plottablerefupperlimit: Double? = nil  // Double binding for upper ref limit
    
    @State private var newRecord: BasicMedicalTestRecordv1?
    
    @State var errorMessage = ""
    
    var body: some View {
        NavigationView{
            VStack {
                ZStack(alignment:.bottom){
                    if newRecord == nil{
                        Form {
                            Section(header: Text("Test Details")) {
                                TextField("Test Name (Required)", text: $test)
                                TextField("Value (numeric) (Required)", value: $value, format: .number)
                                    .keyboardType(.decimalPad)
                                TextField("Unit (Required)", text: $unit)
                            }
                            
                            Section(header: Text("Optional Reference Range"),footer: Text("Add upper and lower reference valuess for this test. It will help you better track the variation of the test result")) {
                                TextField("Lower Reference Limit (numeric)", value: $plottablereflowerlimit, format: .number)
                                    .keyboardType(.decimalPad)
                                TextField("Upper Reference Limit (numeric)", value: $plottablerefupperlimit, format: .number)
                                    .keyboardType(.decimalPad)
                            }
                        }
                        
                    }else{
                        //show the Record in its full glory
                        ScrollView(showsIndicators: false){
                            VStack(alignment:.leading){
                                TestRecordView(record: newRecord!)
                                    .padding()
                                    .background(CustomBlur(style: .prominent))
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                                
                                
                                Text("\(newRecord!.test) has been added to your medical document.")
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(Color.green)
                                    .padding()
                                    .padding(.horizontal)
                                
                            }
                        
                        }
                        
                    }
                    
                    VStack(alignment:.center){
//                        if let record = newRecord {
//                            Text("New record \(record.test) added to your medical document.")
//                                .fontWeight(.bold)
//                                .font(.subheadline)
//                                .padding()
//                        }
                        
                        if !errorMessage.isEmpty && newRecord == nil{
                            Text(errorMessage)
                                .multilineTextAlignment(.leading)
                                .fontWeight(.bold)
                                .foregroundColor(Color.red)
                                .padding(.leading)
                        }
                        Button(action: {
                            if newRecord != nil{
                                showSelf.toggle()
                                return
                            }
                            createTestRecord()
                            system.refresh()

                           
                        }) {
                            Text(newRecord != nil ? "Close": "Create Test Record")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isAllowedToPersistChanges() ? Color.blue : Color.secondary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding()
                                .disabled(!isAllowedToPersistChanges())
                        }
                        
                       
                    }.padding(.bottom)
                    
                }
            }
            .navigationTitle(newRecord != nil ? "\(newRecord!.test) Added": "Create Test Record Manually")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    func isAllowedToPersistChanges()->Bool{
        return value != nil && !test.isEmpty && !unit.isEmpty
    }
    
    func createTestRecord() {
        
        if test.isEmpty{
            errorMessage = "Please enter a test name"
            return
        }
        
        // Check if numeric value is provided for the value
        guard let testValue = value else {
            print("Value is not a valid number.")
            errorMessage = "Test Value should be a number"
            return
        }
        
        if unit.isEmpty{
            errorMessage = "Test unit cannot be left empty"
            return
        }
        
        // Handle optional reference limits
        let hasLowerLimit = plottablereflowerlimit != nil
        let hasUpperLimit = plottablerefupperlimit != nil
        
        // Determine plottableref and ref properties
        let plottableref = (hasLowerLimit || hasUpperLimit) ? "yes" : "no"
        var ref: String? = nil
        if hasLowerLimit || hasUpperLimit {
            let lower = plottablereflowerlimit?.description ?? ""
            let upper = plottablerefupperlimit?.description ?? ""
            ref = "\(lower)-\(upper)"
        }
        
        // Create the new test record
        let record = BasicMedicalTestRecordv1(
            test: test,
            value: testValue.description,  // Convert to string
            unit: unit,
            plottable: "yes",  // Since value is a number, plottable is yes
            ref: ref,
            plottableref: plottableref,
            plottablereflowerlimit: hasLowerLimit ? plottablereflowerlimit?.description : nil,
            plottablerefupperlimit: hasUpperLimit ? plottablerefupperlimit?.description : nil
        )
        
        //Creating and saving the medical test record
        
        // Save the new record
        newRecord = record
        //adding to manually added section
        document.addNewTestRecordToManuallyAddedSection(testRecord: newRecord!)
        
    }
}

