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

    var body: some View {
        NavigationView {
            VStack {
                if currentStep == 0 {
                    TextField("Supplement Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Next") {
                        currentStep += 1
                    }
                } else if currentStep == 1 {
                    HStack {
                        TextField("Dosage Number", text: $strengthNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    Button("Next") {
                        currentStep += 1
                    }
                } else if currentStep == 2 {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(BMSupplementFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    Picker("Form", selection: $form) {
                        ForEach(BMSupplementForm.allCases, id: \.self) { form in
                            Text(form.rawValue).tag(form)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    Button("Next") {
                        currentStep += 1
                    }
                } else if currentStep == 3 {
                    // Time of Consumption
                    VStack {
                        Text("Enter Time of Consumption")
                        ForEach(0..<getFrequencyCount(), id: \.self) { index in
                            DatePicker("Time \(index + 1)", selection: Binding(
                                get: { timeOfConsumption.indices.contains(index) ? timeOfConsumption[index] : Date() },
                                set: { if timeOfConsumption.indices.contains(index) {
                                    timeOfConsumption[index] = $0
                                } else {
                                    timeOfConsumption.append($0)
                                }}
                            ), displayedComponents: .hourAndMinute)
                        }
                    }
                    .padding()
                    Button("Next") {
                        currentStep += 1
                    }
                } else if currentStep == 4 {
                    // Reminder Time
                    VStack {
                        Text("Enter Reminder Time")
                        ForEach(0..<getFrequencyCount(), id: \.self) { index in
                            DatePicker("Reminder Time \(index + 1)", selection: Binding(
                                get: { reminderTime.indices.contains(index) ? reminderTime[index] : Date() },
                                set: { if reminderTime.indices.contains(index) {
                                    reminderTime[index] = $0
                                } else {
                                    reminderTime.append($0)
                                }}
                            ), displayedComponents: .hourAndMinute)
                        }
                    }
                    .padding()
                    Button("Next") {
                        currentStep += 1
                    }
                } else if currentStep == 5 {
                    TextField("User Notes", text: $userNotes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Finish") {
                        createSupplement()
                    }
                }
            }
            .navigationTitle("Add Supplement")
            .navigationBarTitleDisplayMode(.inline)
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
}

// Preview
struct AddSupplementView_Previews: PreviewProvider {
    static var previews: some View {
        AddSupplementView()
    }
}
