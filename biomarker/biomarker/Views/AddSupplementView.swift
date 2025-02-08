//
//  AddSupplementView.swift
//  biomarker
//
//  Created by sachin jeph on 30/01/25.
//

import Foundation
import SwiftUI
import UserNotifications


// Main View
struct AddSupplementView: View {
    @Binding var showSelf : Bool
    var supplementToEdit: BMSupplement?
    @State  var heading: String = "Add supplement name"
    @State  var buttonTitle: String = "Next"
    @State  var name: String = ""
    @State  var strengthNumber: String = ""
    @State  var strengthUnit: String = "mg" // Default unit
    @State  var frequency: BMSupplementFrequency = .daily
    @State  var form: BMSupplementForm = .capsule//not used for food items
    @State  var timeOfConsumption: [Date?] = []
    @State  var reminderTime: [Date?] = []//not going to use
    @State  var userNotes: String = ""
    @State  var currentStep: Int = 0
    @State  var supplement: BMSupplement?
    @State  var supplementIsFoodItem = false
     var finalStep = 4//5th was the previous final step but now reminder is on the same screen as dosage//final step of the form where the supplement is added
    @State  var userNotesPlaceholderText = "Why did you start taking this supplement? How long have you been taking it?"
    @State  var message : String? = nil
    @State  var allowReminding5MinBeforeDosage = false
    @State var analysisInProgress = false
    @State  var isAnimating = false
    var body: some View {
        NavigationView {
            ZStack {
                // Background dimming effect
                if currentStep == 6{
                    LinearGradient(gradient: Gradient(colors: [Color.brightPurple.opacity(isAnimating ? 0.2 : 0), Color.brightpurple.opacity(isAnimating ? 0 : 0.2)]), startPoint: .topLeading, endPoint: .topTrailing)
                        .edgesIgnoringSafeArea(.all)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                }
                VStack {
                    if currentStep == 0 {
                        TextField(supplementIsFoodItem ? "Food name eg Tofu, Blueberry" : "Supplement name eg Vitamin D3, Minoxidil", text: $name)
                            .padding(10)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                            .padding([.horizontal,.top])
                        
                        Toggle("Treat as a food item", isOn: $supplementIsFoodItem)
                            .fontWeight(.bold)
                            .font(.headline)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .padding([.horizontal,.bottom])
                        
                    } else if currentStep == 1 {
                        HStack {
                            TextField(supplementIsFoodItem ? "Portion size" :"Dosage strength (numeric)", text: $strengthNumber)
                                .padding(10)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.trailing)
                                .keyboardType(.decimalPad)
                            Picker("Unit", selection: $strengthUnit) {
                                ForEach(supplementIsFoodItem ? ["g", "lbs", "oz", "mL", "piece"] : [
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
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.trailing)
                            .onAppear{
                                if !isEditMode(){
                                    strengthUnit = supplementIsFoodItem ? "g" : "mg"
                                }
                            }
                        }
                        .padding()
                        //                    Button("Next") {
                        //                        currentStep += 1
                        //                    }
                    }
                    else if currentStep == 2 {
                        ScrollView(showsIndicators: false){
                            VStack{
                        ZStack{
                            if userNotes.isEmpty {
                                TextEditor(text:$userNotesPlaceholderText)
                                    .font(.headline)
                                // .fontWeight(.bold)
                                //.background(Color.secondary.opacity(0.1))
                                    .foregroundStyle(Color.secondary)
                                    .scrollContentBackground(.hidden)
                                    .disabled(true)
                            }
                            
                            TextEditor(text: $userNotes)
                                .scrollContentBackground(.hidden)
                                .font(.headline)
                                .toolbar {
                                    ToolbarItem(placement: .keyboard) {
                                       // Spacer()
                                        Button("Close keyboard") {
                                            //console.log
                                            UIApplication.shared.endEditing()
                                        }
                                    }
                                }
                            
                        }
                        .frame(height: system.fullHeight/4)
                        // TextField("reason for supplement...", text: $userNotes)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                    }
                }
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
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.trailing)
                        }.padding(.top)
                            .padding(.horizontal)
                        
                        if !supplementIsFoodItem{
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
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.trailing)
                            }.padding()
                        }
                        
                        //                    Button("Next") {
                        //                        currentStep += 1
                        //                    }
                    } else if currentStep == 4 {
                        // Time of Consumption
                        ScrollView(showsIndicators: false){
                            VStack {
                                // Text("Enter Reminder Time")
                                
                                ForEach(0..<getFrequencyCount(), id: \.self) { index in
                                    VStack{
                                        HStack {
                                            Toggle(isOn: Binding(
                                                get: { timeOfConsumption.indices.contains(index) && timeOfConsumption[index] != nil },
                                                set: { isOn in
                                                    if isOn {
                                                        // If toggled on, add a default time (current time or any default value)
                                                        if timeOfConsumption.indices.contains(index) {
                                                            timeOfConsumption[index] = Date()
                                                            // timeOfConsumption.remove(at: index)
                                                        }else{
                                                            //here we will first increase the list to have atleast index+1 count of items and initialise the index item with date
                                                            for newIdx in timeOfConsumption.count...index{
                                                                if newIdx == index{
                                                                    timeOfConsumption.append(Date())
                                                                }else{
                                                                    timeOfConsumption.append(nil)
                                                                }
                                                            }
                                                            
                                                        }
                                                    } else {
                                                        // If toggled off, remove the time for this index
                                                        if timeOfConsumption.indices.contains(index) {
                                                            timeOfConsumption[index] = nil
                                                            // timeOfConsumption.remove(at: index)
                                                        }
                                                    }
                                                }
                                            )) {
                                                Text("Dosage\(getFrequencyCount() > 1 ? " \(index+1)" : "") time")
                                                    .fontWeight(.bold)
                                                    .font(.headline)
                                            }
                                            .toggleStyle(SwitchToggleStyle(tint: .blue)) // Optional: Customize toggle color
                                        }
                                        
                                        if timeOfConsumption.indices.contains(index) && timeOfConsumption[index] != nil {
                                            DatePicker(" ", selection: Binding(
                                                get: { timeOfConsumption[index]! },
                                                set: { timeOfConsumption[index] = $0 }
                                            ), displayedComponents: isFirstNonNilIndex(in: timeOfConsumption, index: index) ? [.hourAndMinute,.date] : [.hourAndMinute])
                                            .fontWeight(.bold)
                                            .font(.headline)
                                            // .padding(.bottom)
                                        } else {
                                            //                                Text("Set time")
                                            //                                    .fontWeight(.bold)
                                            //                                    .font(.headline)
                                            //                                    .foregroundColor(.gray) // Optional: Change color to indicate it's not set
                                        }
                                    } .padding()
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(10)
                                        .padding([.bottom])
                                    
                                }
                                
                                if timeOfConsumption.count > 0 && timeOfConsumption.contains(where: { $0 != nil }) {
                                    
                                    //Only show reminder when at least on the date is set
                                    Toggle("Remind me 5 min before time", isOn: $allowReminding5MinBeforeDosage)
                                        .fontWeight(.bold)
                                        .font(.headline)
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                                        .padding()
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(10)
                                        .padding([.top,.bottom])
                                    
                                }
                                
                                
                                
                            }.padding()
                        }
                        
                        
                        
                        //                    Button("Next") {
                        //                        currentStep += 1
                        //                    }
                    } else if currentStep == 5 {
                        // Reminder Time
                        //"Reminder for dosage\(getFrequencyCount() > 1 ? " \(index+1)" : "")"
                        /*
                         VStack{
                         // Text("Enter Reminder Time")
                         
                         ForEach(0..<getFrequencyCount(), id: \.self) { index in
                         HStack {
                         Toggle(isOn: Binding(
                         get: { reminderTime.indices.contains(index) && reminderTime[index] != nil },
                         set: { isOn in
                         if isOn {
                         // If toggled on, add a default time (current time or any default value)
                         if reminderTime.indices.contains(index) {
                         reminderTime[index] = Date()
                         // timeOfConsumption.remove(at: index)
                         }else{
                         //here we will first increase the list to have atleast index+1 count of items and initialise the index item with date
                         for newIdx in reminderTime.count...index{
                         if newIdx == index{
                         reminderTime.append(Date())
                         }else{
                         reminderTime.append(nil)
                         }
                         }
                         }
                         } else {
                         // If toggled off, remove the time for this index
                         if reminderTime.indices.contains(index) {
                         //reminderTime.remove(at: index)
                         reminderTime[index] = nil
                         }
                         }
                         }
                         )) {
                         Text("Reminder for dosage\(getFrequencyCount() > 1 ? " \(index+1)" : "")")
                         .fontWeight(.bold)
                         .font(.headline)
                         }
                         .toggleStyle(SwitchToggleStyle(tint: .blue)) // Optional: Customize toggle color
                         }
                         
                         if reminderTime.indices.contains(index) && reminderTime[index] != nil {
                         DatePicker(" ", selection: Binding(
                         get: { reminderTime[index]! },
                         set: { reminderTime[index] = $0 }
                         ), displayedComponents: .hourAndMinute)
                         .fontWeight(.bold)
                         .font(.headline)
                         .padding(.bottom)
                         } else {
                         //                                Text("Set time")
                         //                                    .fontWeight(.bold)
                         //                                    .font(.headline)
                         //                                    .foregroundColor(.gray) // Optional: Change color to indicate it's not set
                         }
                         }
                         }
                         .padding()
                         */
                        //                    Button("Next") {
                        //                        currentStep += 1
                        //                    }
                    }else if currentStep == 6{
                        //this is shown when supplement is added locally and is being analysed by biomarker intelligence
                        AnalyzingReportView(name: name)
                            .onAppear{
                                isAnimating = true
                            }
                    }else if currentStep == 7{
                        //supplement has been added to the stack and analysis by the llm is compelte so show the page
                        //TODO- SHOW SUPPLEMENT DETAILED VIEW
                        if (isEditMode() && supplementToEdit != nil) || (!isEditMode() && supplement != nil){
                            NavigationView{
                                SupplementDetailView(showSelf: $showSelf, supplement: isEditMode() ? supplementToEdit! : supplement!)
                            }
                        }
                    }
                    
                    descriptionView(text: getDescription())
                    
                    if currentStep != 7{
                        HStack{
                            //
                            if currentStep > 0 && currentStep < 6{
                                Button(action:{
                                    
                                    if currentStep == 0{
                                        return
                                    }
                                    if currentStep == 6{
                                        currentStep -= 2
                                        //because we want to move straigght from 6 to 4 as the separate reminder set screen 5 is now no longer in use
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
                                
                                if analysisInProgress{
                                    print("Cannot request a supplement analysis as the last one is in progress")
                                    return
                                }
                                
                                if currentStep == finalStep{
                                    createSupplement()
                                }
                                
                                if canMoveToNextStep(){
                                    if currentStep == 1 && supplementIsFoodItem{
                                        currentStep += 1 //additional step so that because we dont want to notes section for food item
                                    }
                                    currentStep += 1
                                    
                                    message = nil
                                }
                                
                                
                                
                                
                            }){
                                HStack{
                                    label(currentStep == finalStep ? (isEditMode() ? "Save changes" : "Add") : currentStep==6 ? "Analysing..." : "Next", textColor: currentStep == finalStep ? .white : .primaryInvert, bgColor: currentStep == finalStep ? .blue : (canMoveToNextStep() ? .primary : .secondary), imgName: currentStep == finalStep ? "checkmark" : currentStep==6 ? "" : "arrow.forward", imgColor: currentStep == finalStep ? .white : .primaryInvert, width: 150, radius: 10,alignment: .center)
                                    Spacer()
                                }.padding()
                            }
                            
                        }
                        
                        if message != nil{
                            Text(message!)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                                .padding()
                            
                        }
                    }
                    Spacer()
                    
                }
                //.ignoresSafeArea()
                .edgesIgnoringSafeArea(.bottom)
                .animation(.default, value: 1)
                .navigationTitle(heading)
                .navigationBarTitleDisplayMode(.large)
                .onChange(of: currentStep){ _ in
                    updateHeading()
                }
                .onChange(of: supplementIsFoodItem){ _ in
                    updateHeading()
                }
                .onAppear{
                    //see if this screen is opened in edit mode if yes, then set the properties accordingly
                    guard let supp = supplementToEdit else {
                        return
                    }
                    
                    print("/AddSupplementView is opened in edit mode")
                    //setting the data model for previous data
                    name = supp.name
                    strengthNumber = supp.strengthNumber
                    strengthUnit = supp.strengthUnit
                    frequency = supp.frequency
                    form = supp.form ?? .capsule
                    userNotes = supp.userNotes ?? ""
                    supplementIsFoodItem = supp.supplementType == .food ? true : false
                    timeOfConsumption = supp.timeOfConsumption
                    reminderTime = supp.reminderTime
                    allowReminding5MinBeforeDosage = supp.is5MinReminderSet
                    updateHeading()
                }
            }

        }
    }

    
    func canMoveToNextStep()->Bool{
        
        if currentStep >= finalStep{
            return false
        }
        
        if currentStep == 0{
            if isEmpty(text: name){
                return false
            }
          //  heading = "Add dosage"
        }else if currentStep == 1{
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
            heading = supplementIsFoodItem ? (isEditMode() ? "Change food" : "Add food") : (isEditMode() ?  "Change supplement" : "Add supplement")
        }
        if currentStep == 1 {
            heading = supplementIsFoodItem ? "Add portion size" : (isEditMode() ? "Change dosage" : "Add dosage")
        }
        if currentStep == 2 {
            heading = "Notes"
        }
        if currentStep == 3 {
            heading = supplementIsFoodItem ? "Frequency" : "Frequency and form"
        }
        if currentStep == 4 {
            heading = "Consumption time"
        }
        if currentStep == 5 {
            heading = "Set Reminder"
        }
        if currentStep == 6 {
            heading = ""
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
    
    func isEditMode()->Bool{
        return supplementToEdit != nil ? true : false
    }
    
    func updateReminderState(supplement: BMSupplement) {
        
        // Step 0: Remove existing notifications for this supplement
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            print("/updateReminderState: Removing out of the following notifs", requests.count)
            let supplementReminders = requests
                .filter { $0.identifier.hasPrefix(supplement.id) }
                .map { $0.identifier }
            
            center.removePendingNotificationRequests(withIdentifiers: supplementReminders)
        }
        
        
        // Step 1: Check if reminders are allowed
        guard supplement.is5MinReminderSet else {
            print("Reminders are turned off for this supplement.")
            return
        }

        // Step 2: Request notification permission
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
                return
            }
            
            guard granted else {
                print("Notification permission not granted.")
                return
            }

           


            // Step 3: Create new periodic reminders based on timeOfConsumption and frequency
            let frequency = supplement.frequency
            let timeOfConsumption = supplement.timeOfConsumption

            for time in timeOfConsumption {
                guard let dosageTime = time else { continue }
                
                // Find the next valid occurrence of dosageTime
                var nextOccurrence = dosageTime
                while nextOccurrence < Date() {
                    switch frequency {
                    case .onceIn2Days:
                        nextOccurrence = Calendar.current.date(byAdding: .day, value: 2, to: nextOccurrence)!
                    case .onceIn2Weeks:
                        nextOccurrence = Calendar.current.date(byAdding: .weekOfYear, value: 2, to: nextOccurrence)!
                    default:
                        break
                    }
                }

                // Subtract 5 minutes for the reminder time
                let reminderTime = Calendar.current.date(byAdding: .minute, value: -5, to: nextOccurrence)!

                // Create the notification content
                let content = UNMutableNotificationContent()
                content.title = "Supplement Reminder"
                content.body = "It's time to take your \(supplement.name)."
                content.sound = .default

                var trigger: UNNotificationTrigger?

                switch frequency {
                case .oneTime:
                    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
                    trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                case .daily, .daily2, .daily3:
                    var components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                    trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                case .onceIn2Days:
                    var occurrence = reminderTime
                    for _ in 1...500 { // Schedule 5 future occurrences
                        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: occurrence)
                        let request = UNNotificationRequest(identifier: "\(supplement.id)-\(occurrence.timeIntervalSince1970)", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
                        center.add(request)
                        occurrence = Calendar.current.date(byAdding: .day, value: 2, to: occurrence)!
                    }

                case .weekly:
                    //iOS supports weekly reminder so this should work
                    let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: reminderTime)
                    trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                case .onceIn2Weeks:
                    var occurrence = reminderTime
                    for _ in 1...500 { // Schedule 50 future occurrences
                        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: occurrence)
                        let request = UNNotificationRequest(identifier: "\(supplement.id)-\(occurrence.timeIntervalSince1970)", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
                        center.add(request)
                        occurrence = Calendar.current.date(byAdding: .weekOfYear, value: 2, to: occurrence)!
                    }

                case .monthly:
                    var occurrence = reminderTime
                    //next 24 months reminder is set
                       for _ in 1...12 { // Schedule reminders for the next 12 months
                           let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: occurrence)
                           let request = UNNotificationRequest(
                               identifier: "\(supplement.id)-\(occurrence.timeIntervalSince1970)",
                               content: content,
                               trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                           )
                           center.add(request)
                           
                           // Move to the next month
                           occurrence = Calendar.current.date(byAdding: .month, value: 1, to: occurrence)!
                       }
                }

                // Schedule the repeating notification if applicable
                if let trigger = trigger {
                    let request = UNNotificationRequest(identifier: supplement.id, content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
    }


    private func createSupplement() {
        let id = UUID().uuidString
        let createdAt = Date()
        
        //We need to do some preprocessing of timeOfConsumption where we need to use the date of the first non-nil value in the list of dates timeOfConsumption. and set that date part to the rest of the elements in timeOfConsumption. Note- we only need to set the date part, for hour and minute part we do not touch them as each item in timeOfConsumption will have their own hour and minute
        preprocessTimeOfConsumption(timeOfConsumption)
        
        var allValsInTimeOfConsumptionAreNil = true
        for time in timeOfConsumption{
            if time != nil{
                allValsInTimeOfConsumptionAreNil = false
                break;
            }
        }
        
        if allValsInTimeOfConsumptionAreNil{
            print("Setting allowReminding5MinBeforeDosage to false as no dosage time was set")
            allowReminding5MinBeforeDosage = false
        }
        
        //check if its the edit flow here- i know this function could use some cleanup but going with this for now otherwise use the create new supplement flow
        //EDIT SUPPLEMENT HERE
        if let supp = supplementToEdit {
            
            supp.saveEditChanges(supplementTypeL: supplementIsFoodItem ? .food : .supplement, nameL: name, strengthNumberL: strengthNumber, strengthUnitL: strengthUnit, frequencyL: frequency, formL: supplementIsFoodItem ? nil : form, timeOfConsumptionL: timeOfConsumption, reminderTimeL: reminderTime, createdAtL: createdAt, is5MinReminderSetL: allowReminding5MinBeforeDosage, userNotesL: userNotes)

            
            //here we will close the edit screen once edits are done
            showSelf = false
            
        updateReminderState(supplement: supp)
           return
        }
        
        print("Trying to add new supplement to the stack****")
        
        //CREATE NEW SUPPLEMENT FLOW BELOW
        supplement = BMSupplement(id: id, supplementType: supplementIsFoodItem ? .food : .supplement, name: name, strengthNumber: strengthNumber,
                                  strengthUnit: strengthUnit, frequency: frequency,
                                  form: supplementIsFoodItem ? nil : form, timeOfConsumption: timeOfConsumption,
                                  reminderTime: reminderTime, createdAt: createdAt,
                                  is5MinReminderSet: allowReminding5MinBeforeDosage, userNotes: userNotes)
        // Here you can handle the created supplement object (e.g., save it to a database)
        print("Supplement created: \(supplement!)")
        if supplement != nil{
            let result = BMSupplementStackGL.addSupplement(supplement!)
            if result.0{
                //send a request to server for analysing the supplement
                updateReminderState(supplement: supplement!)
                analysisInProgress = true
                UserHealthContext.analyzeSupplementWithLLM(supplement!) { success, response in
                    analysisInProgress = false
                    if success{
                        
                        
                    }else{
                        print("Failed to analyse the reponse")
                        //WE WILL PROBABLY NOT SHOW THIS MESSAGE BECAUSE WE IMEEDIATELY MOVE TO THE SCREEN 7- WHICH IS SUPPLEMENT DETAILED VIEW
                        //message = "The \(supplementIsFoodItem ? "food item" : "supplement") has been added to your stack. However Biomarker was unable to analyze the \(supplementIsFoodItem ? "food item" : "supplement"), and you can request an analysis later from the supplement details page."
                        
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        //putting thing in here because we do not want abrupt stops in animation in case completion handler gets called very quicky
                        //side effect is that we will show anlaying with biomarker for a few moments longer, but its fine
                        currentStep = 7
                        isAnimating = false
                    })
                }
                
                
                currentStep = 6
            }else{
                //something went wrong
                message = result.1
            }
        }
    }
    
    func preprocessTimeOfConsumption(_ timeOfConsumption: [Date?]) {
        // Find the first non-nil date
        guard let firstNonNilDate = timeOfConsumption.compactMap({ $0 }).first else {
            return // No non-nil dates found, nothing to do
        }
        
        // Extract the date components from the first non-nil date
        let calendar = Calendar.current
        let firstDateComponents = calendar.dateComponents([.year, .month, .day], from: firstNonNilDate)

        // Update the date part of each non-nil date in the array
        for index in timeOfConsumption.indices {
            if let currentDate = timeOfConsumption[index] {
                // Create a new date with the same hour and minute but the date from firstNonNilDate
                var newDateComponents = calendar.dateComponents(in: TimeZone.current, from: currentDate)
                newDateComponents.year = firstDateComponents.year
                newDateComponents.month = firstDateComponents.month
                newDateComponents.day = firstDateComponents.day
                
                // Set the new date back to the array
                self.timeOfConsumption[index] = calendar.date(from: newDateComponents)
            }
        }
    }
    
    func isEmpty(text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func isNumber(text: String) -> Bool {
        return Float(text) != nil
    }
    
    func getDescription() -> String {
        if currentStep == 0 {
            return supplementIsFoodItem ? "You are currently adding a food item.\nExample: 'Blueberry', 'Tofu' etc" :"Add your supplement name. You can enter either the generic name or the complete brand name of your supplement. \n\nExample: 'Vitamin C' or 'Nature's Way Vitamin C 1000mg'."
        }
        if currentStep == 1 {
            return supplementIsFoodItem ? "How much of this food do you typically eat in one sitting? \n\nExample: '100 g' of tofu or '2' tortillas." : "Enter the dosage of your supplement. Specify the amount (number) and select the unit (e.g., mg, g, ml) from the options provided. \n\nExample: '500' for the amount and select 'mg' for the unit."
        }
        if currentStep == 2 {
            return "Your notes will help Biomarker analyze your supplements better. Please tell us why you started taking it and how long you have been using it. \n\nExample: 'I started taking this for immune support and have been using it for 3 months.'"
        }
        if currentStep == 3 {
            return supplementIsFoodItem ? "Select how often do you have this food. Choose the frequency that best describes your routine (e.g., daily, weekly, etc.)" : "Select how often you take this supplement. Choose the frequency that best describes your routine (e.g., daily, weekly, etc.) and the form of the supplement (e.g., capsule, liquid). \n\nExample: 'Daily' for frequency and 'Capsule' for form."
        }
        if currentStep == 4 {
            return "Specify the last date and time you took this \(supplementIsFoodItem ? "food item" : "supplement"). If you take it multiple times a day, please enter each time accordingly.\n\nBiomarker will accordingly create schedule for this \(supplementIsFoodItem ? "food item" : "supplement")"
        }
        if currentStep == 5 {
            return "Set a reminder if you want Biomarker to notify you about your  \(supplementIsFoodItem ? "food item" : "supplement") consumption time. You can choose the time for the reminder. \n\nExample: 'Set a reminder for 7:30 AM.'"
        }
        return ""
    }


}





struct AnalyzingReportView: View {
    var name: String

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background dimming effect
//            LinearGradient(gradient: Gradient(colors: [Color.brightPurple.opacity(isAnimating ? 0.2 : 0), Color.brightpurple.opacity(isAnimating ? 0 : 0.2)]), startPoint: .topLeading, endPoint: .topTrailing)
//                .edgesIgnoringSafeArea(.all)
//                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)

            VStack(alignment: .leading) {
                Group {
                    Text("\(name) is added to your ")
                    + Text("supplement stack")
                        .italic()
                        .underline()
                }
                .fontWeight(.bold)
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(.vertical)

                biomarerIntelligenceLabel()
                    .padding(.top)

                Text("Biomarker Intelligence is analyzing \(name) against your test results, your current supplement stack, and other health-related data, and generating a detailed supplement report.")
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.brightpurple)
                    .padding(.vertical)

                ActivityIndicator(shouldAnimate: .constant(true))
                Spacer()
            }
            .padding()
        }
        .onAppear {
           // isAnimating.toggle() // Start the animation when the view appears
        }
    }

}

