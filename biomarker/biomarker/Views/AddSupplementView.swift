//
//  AddSupplementView.swift
//  biomarker
//
//  Created by sachin jeph on 30/01/25.
//

import Foundation
import SwiftUI


// Main View
struct AddSupplementView: View {
    @State private var heading: String = "Add supplement name"
    @State private var buttonTitle: String = "Next"
    @State private var name: String = ""
    @State private var strengthNumber: String = ""
    @State private var strengthUnit: String = "mg" // Default unit
    @State private var frequency: BMSupplementFrequency = .daily
    @State private var form: BMSupplementForm = .capsule
    @State private var timeOfConsumption: [Date] = []
    @State private var reminderTime: [Date] = []
    @State private var userNotes: String = ""
    @State private var currentStep: Int = 0
    @State private var supplement: BMSupplement?
    private var finalStep = 5//final step of the form where the supplement is added
    @State private var userNotesPlaceholderText = "Why did you start taking this supplement? How long have you been taking it?"

    var body: some View {
        NavigationView {
            VStack {
                if currentStep == 0 {
                    TextField("Supplement Name eg Vitamin D3, Minoxidil", text: $name)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding()
                    
                    
                } else if currentStep == 1 {
                    HStack {
                        TextField("Dosage strength (numeric)", text: $strengthNumber)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.trailing)
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $strengthUnit) {
                            ForEach([
                                "mg",
                                "g",
                                "mcg",
                                "mL",
                                "IU",
                                     "L",
                                     "tsp",
                                     "tbsp",
                                     "gtt",
                                     "kg",
                                     "IU",
                                     "MEq",
                                     "%",
                                     "mg/m²",
                                     "mMol"], id: \.self) { unit in
                                Text(unit).tag(unit)
                                            .fontWeight(.bold)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(5)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.trailing)
                    }
                    .padding()
//                    Button("Next") {
//                        currentStep += 1
//                    }
                } 
                else if currentStep == 2 {
                    ZStack{
                        if userNotes.isEmpty {
                                   TextEditor(text:$userNotesPlaceholderText)
                                .font(.headline)
                               // .fontWeight(.bold)
                                .foregroundStyle(Color.secondary)
                            
                                .scrollContentBackground(.hidden)
                                .disabled(true)
                           }
                        
                        TextEditor(text: $userNotes)
                            .scrollContentBackground(.hidden)
                            .font(.headline)
                            
                    }
                    .frame(height: system.fullHeight/4)
                   // TextField("reason for supplement...", text: $userNotes)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .padding(.horizontal)
//                    Button("Finish") {
//                        createSupplement()
//                    }
                }
                else if currentStep == 3 {
                    HStack{
                        Text("Frequency")
                            .fontWeight(.bold)
                            .font(.headline)
                            //.fontWeight(.bold)
                            Spacer()
                        Picker("Frequency", selection: $frequency) {
                            ForEach(BMSupplementFrequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }.pickerStyle(MenuPickerStyle())
                            .padding(5)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.trailing)
                    }.padding(.top)
                        .padding(.horizontal)
                    
                    HStack{
                        Text("Form")
                            .fontWeight(.bold)
                            .font(.headline)
                            
                            //.fontWeight(.bold)
                        Spacer()
                        
                        Picker("Form", selection: $form) {
                            ForEach(BMSupplementForm.allCases, id: \.self) { form in
                                Text(form.rawValue).tag(form)
                            }
                        }.pickerStyle(MenuPickerStyle())
                            .padding(5)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.trailing)
                    }.padding()

//                    Button("Next") {
//                        currentStep += 1
//                    }
                } else if currentStep == 4 {
                    // Time of Consumption
                    VStack {
                       // Text("Enter Time of Consumption")
                        ForEach(0..<getFrequencyCount(), id: \.self) { index in
                            DatePicker("Dosage\(getFrequencyCount() > 1 ? " \(index+1)" : "") time", selection: Binding(
                                get: { timeOfConsumption.indices.contains(index) ? timeOfConsumption[index] : Date() },
                                set: { if timeOfConsumption.indices.contains(index) {
                                    timeOfConsumption[index] = $0
                                } else {
                                    timeOfConsumption.append($0)
                                }}
                            ), displayedComponents: .hourAndMinute)
                            .fontWeight(.bold)
                            .font(.headline)
                        }
                    }
                    .padding()
//                    Button("Next") {
//                        currentStep += 1
//                    }
                } else if currentStep == 5 {
                    // Reminder Time
                    VStack {
                       // Text("Enter Reminder Time")
                        ForEach(0..<getFrequencyCount(), id: \.self) { index in
                            DatePicker("Reminder for dosage\(getFrequencyCount() > 1 ? " \(index+1)" : "")", selection: Binding(
                                get: { reminderTime.indices.contains(index) ? reminderTime[index] : Date() },
                                set: { if reminderTime.indices.contains(index) {
                                    reminderTime[index] = $0
                                } else {
                                    reminderTime.append($0)
                                }}
                            ), displayedComponents: .hourAndMinute)
                            .fontWeight(.bold)
                            .font(.headline)
                        }
                    }
                    .padding()
//                    Button("Next") {
//                        currentStep += 1
//                    }
                }
                
                HStack{
                    //
                    if currentStep > 0{
                        Button(action:{
                            
                            if currentStep == 0{
                                return
                            }
                            
                            currentStep -= 1
                            
                            
                        }){
                            HStack{
                                //label(heading.contains("notes") ? "Add" : "Next", textColor: .primaryInvert, bgColor: canMoveToNextStep() ? .primary : .primary.opacity(0.3), imgName: "arrow.forward", imgColor: .primaryInvert, width: 150, radius: 10,alignment: .center)
                                imageView(systemName: "arrow.backward.circle.fill",color: .accentColor,size: 40)
                                Spacer()
                            }.padding()
                        }
                    }
                    
                    //
                    Button(action:{
                        
                        if currentStep == finalStep{
                            createSupplement()
                        }
                        
                        if canMoveToNextStep(){
                            currentStep += 1
                        }
                        
                        
                        
                        
                    }){
                        HStack{
                            label(currentStep == finalStep ? "Add" : "Next", textColor: currentStep == finalStep ? .white : .primaryInvert, bgColor: currentStep == finalStep ? .blue : (canMoveToNextStep() ? .primary : .primary.opacity(0.3)), imgName: currentStep == finalStep ? "checkmark" : "arrow.forward", imgColor: currentStep == finalStep ? .white : .primaryInvert, width: 150, radius: 10,alignment: .center)
                            Spacer()
                        }.padding()
                    }
                    
                }
                Spacer()
                
            }
            .navigationTitle(heading)
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: currentStep){ _ in
                updateHeading()
            }

        }
    }

    
    func canMoveToNextStep()->Bool{
        
        if currentStep >= finalStep{
            return false
        }
        if heading.contains("name"){
            if isEmpty(text: name){
                return false
            }
          //  heading = "Add dosage"
        }else if heading.contains("dosage"){
            if !isNumber(text: strengthNumber){
                return false
            }
           // heading = "Frequency and form"
        }
//        else if heading.contains("Frequency"){
//         //   heading = "Consumption time"
//        }
//        else if heading.contains("Consumption"){
//           // heading = "Set reminder"
//        }
//        else if heading.contains("reminder"){
//           // heading = "Any notes"
//        }
        
//        else if heading.contains("notes"){
//            buttonTitle = "Add"
//        }
        
        return true
    }
    
    func updateHeading(){
        if currentStep == 0 {
            heading = "Add supplement"
        }
        if currentStep == 1 {
            heading = "Add dosage"
        }
        if currentStep == 2 {
            heading = "Notes"
        }
        if currentStep == 3 {
            heading = "Frequency and form"
        }
        if currentStep == 4 {
            heading = "Consumption time"
        }
        if currentStep == 5 {
            heading = "Set Reminder"
        }
        
    }
    private func getFrequencyCount() -> Int {
        switch frequency {
        case .daily2:
            return 2
        case .daily3:
            return 3
        default:
            return 1
        }
    }

    private func createSupplement() {
        let id = UUID().uuidString
        let createdAt = Date()
        supplement = BMSupplement(id: id, name: name, strengthNumber: strengthNumber,
                                  strengthUnit: strengthUnit, frequency: frequency,
                                  form: form, timeOfConsumption: timeOfConsumption,
                                  reminderTime: reminderTime, createdAt: createdAt,
                                  isReminderSet: !reminderTime.isEmpty, userNotes: userNotes)
        // Here you can handle the created supplement object (e.g., save it to a database)
        print("Supplement created: \(supplement!)")
    }
    
    func isEmpty(text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func isNumber(text: String) -> Bool {
        return Float(text) != nil
    }

}

// Preview
struct AddSupplementView_Previews: PreviewProvider {
    static var previews: some View {
        AddSupplementView()
    }
}
