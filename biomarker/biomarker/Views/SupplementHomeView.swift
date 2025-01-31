//
//  SupplementHomevIEW.swift
//  biomarker
//
//  Created by sachin jeph on 31/01/25.
//

import Foundation
import SwiftUI

struct SupplementHomeView:View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    @State var showAddSupplementScreen = false
    @State private var supplementType: BMSupplementType = .supplement
    var body: some View {
        NavigationView{
            GeometryReader{ geo in
                VStack(alignment: .leading){
                   
                    ScrollView(showsIndicators: false){
                        VStack(alignment: .leading){
                            
                            Text("Your stack has \(BMSupplementStackGL.supplements.count) supplements")
                                .font(.headline)
                                .foregroundStyle(Color.secondary)
                            
                            //                            HStack{
                            //                                Text("supplement stack")//stack data and high level overview- basically ai fields
                            //                                    .italic()
                            //                                    .underline()
                            //
                            //                                imageView(systemName: "plus.circle.fill", color: .primary, size: 30)
                            //                            }
                            //                            .fontWeight(.bold)
                            //                            .font(.title)
                            //                            .multilineTextAlignment(.leading)
                            //                            .padding(.vertical)
                            //
                            
                            
                            HStack{
                                Spacer()
                            Button(action:{
                                showAddSupplementScreen.toggle()
                            }){
                                label("Add a supplement", textColor: .primaryInvert, bgColor: .primary, imgName: "bolt.fill", imgColor: .primaryInvert, width: geo.size.width*0.8, radius: 10,verticalPadding: 5)
                            }
                                Spacer()
                            }.padding(.top)
                            .sheet(isPresented: $showAddSupplementScreen){
                                AddSupplementView()
                            }
                            
                            Text("Supplement Stack Analysis")
                            //.italic()
                            //.underline()
                                .fontWeight(.bold)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                         
                            
                            Text("Supplements")
                            //.italic()
                            //.underline()
                                .fontWeight(.bold)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                            
                            // Picker for selecting the number of days
                            Picker("Select Supplement Type", selection: $supplementType) {
                               // Text("Both").tag("Both")
                                Text(BMSupplementType.supplement.rawValue).tag(BMSupplementType.supplement)
                                Text(BMSupplementType.food.rawValue).tag(BMSupplementType.food)

                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom)
                            
                           if bmSupplementStackGL.supplements.filter({ supp in
                                supp.supplementType == supplementType
                           }).count == 0 {
                               HStack{Spacer
                                   Text("Nothing to show")
                                       .fontWeight(.bold)
                                       .font(.headline)
                                       .foregroundStyle(Color.secondary)
                                       .padding(.vertical)
                               }
                           }
                            ForEach(bmSupplementStackGL.supplements.filter({ supp in
                                supp.supplementType == supplementType
                            })){ supp in
                                SupplementRow(supplement: supp)
                            }
                            
                            
                            
                            
                            SupplementScheduleView()
                            
                            //biomarker recommended
                            Text("Recommended schedule")
                            //.italic()
                            //.underline()
                                .fontWeight(.bold)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                        }
                    }
                }.padding(.horizontal)
            }.navigationTitle("Supplement Stack")
                .animation(.default)
        }
    }
}


struct SupplementRow: View {
    var supplement: BMSupplement

    var body: some View {
        HStack {
            // Example icon, replace with appropriate icons
            Image(systemName: "bolt.fill") // Use an appropriate SF Symbol or custom icon
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.primary)

            VStack(alignment: .leading) {
                Text(supplement.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack {
                    Text("\(supplement.strengthNumber) \(supplement.strengthUnit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(supplement.form?.rawValue ?? "") // Display form
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(supplement.frequency.rawValue) // Display frequency
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
             

                // Display time of consumption
                if !supplement.timeOfConsumption.isEmpty {
//                    Text("Dosage Times: \(formatTimeOfConsumption(supplement.timeOfConsumption))")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
                    SupplementTimeView(supplement: supplement)
                        .padding(.bottom,3)
                }

                // Display next consumption date
                if SupplementScheduleView.calculateNextConsumptionDates(supplement: supplement, from: Date(), inNext: 360).count > 0 {
                    Text("Upcoming dose is on")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    + Text(" \(SupplementScheduleView.calculateNextConsumptionDates(supplement: supplement, from: Date(), inNext: 360)[0], formatter: dateFormatter_D_MMMM_YYYY)")
                        .font(.subheadline)
                        .foregroundColor(.pink)
                        //.italic()
                        .bold()
                }

//                if let userNotes = supplement.userNotes, !userNotes.isEmpty {
//                    Text("Notes: \(userNotes)")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
            }
            .padding(.leading, 8)
        }
        .padding()
        Divider().padding(.horizontal)
       // .background(Color(UIColor.systemBackground))
        //.cornerRadius(8)
        //.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    // Function to format time of consumption
    private func formatTimeOfConsumption(_ times: [Date?]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Format for time
        
        return times.compactMap { $0 }.map { formatter.string(from: $0) }.joined(separator: ", ")
    }


}

struct SupplementScheduleView: View {
    //var bmSupplementStackGL: BMSupplementStack // Assuming this is your data model
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    
    @State private var selectedDays: Int = 7 // Default to 7 days
    @State private var selectedFrequency: String = "All"// No filter by default
    @State private var supplementType: BMSupplementType = .supplement

    var body: some View {
        VStack {
            HStack {
                Text("Schedule for the next ")
                    .fontWeight(.bold)
                    .font(.headline)
                   // .multilineTextAlignment(.leading)
                    //.padding(.vertical)

                + Text(periodDesc())
                    .fontWeight(.bold)
                    .font(.headline)
                    .italic() // Make it italic
                    .foregroundColor(.pink) // Set the color to pink

               +  Text(" for your ")
                    .fontWeight(.bold)
                    .font(.headline)
                   // .multilineTextAlignment(.leading)
                    //.padding(.vertical)

               + Text(supplementType.rawValue)
                    .fontWeight(.bold)
                    .font(.headline)
                    .italic() // Make it italic
                    .foregroundColor(.pink) // Set the color to pink

               + Text(" items")
                    .fontWeight(.bold)
                    .font(.headline)
                
               
                + Text(selectedFrequency.lowercased() != "all" ? " which you consume " : "")
                        .fontWeight(.bold)
                        .font(.headline)
                    
                + Text(selectedFrequency.lowercased() != "all" ? selectedFrequency.lowercased() : "")
                        .fontWeight(.bold)
                        .font(.headline)
                        .italic() // Make it italic
                        .foregroundColor(.pink)
              

                Spacer()
            }.multilineTextAlignment(.leading)
                .padding(.vertical)

            
            // Picker for selecting the number of days
            Picker("Select Schedule Duration", selection: $selectedDays) {
                Text("3 Days").tag(3)
                Text("7 Days").tag(7)
                Text("2 Weeks").tag(14)
                Text("1 Month").tag(30)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top)

            // Picker for selecting the number of days
            Picker("Select Supplement Type", selection: $supplementType) {
               // Text("Both").tag("Both")
                Text(BMSupplementType.supplement.rawValue).tag(BMSupplementType.supplement)
                Text(BMSupplementType.food.rawValue).tag(BMSupplementType.food)

            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)
            
            HStack{
                Text("Consumption Frequency")
                    .fontWeight(.bold)
                    .font(.subheadline)
                    //.fontWeight(.bold)
                    Spacer()
                Picker("Frequency", selection: $selectedFrequency) {
                               Text("All").tag("All") // Tag for "All"
                               Text("One time").tag("One time")
                               Text("1 time Daily").tag("1 time Daily")
                               Text("2 times daily").tag("2 times daily")
                               Text("3 times daily").tag("3 times daily")
                               Text("Once every 2 days").tag("Once every 2 days")
                               Text("Weekly").tag("Weekly")
                               Text("Once every 2 weeks").tag("Once every 2 weeks")
                               Text("Monthly").tag("Monthly")
                           }.pickerStyle(MenuPickerStyle())
                    .padding(5)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.trailing)
            }//.padding(.top)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                

            let schedule = createSupplementSchedule()
            
           // List {
            if schedule.keys.count == 0{
                Text("No supplements to show")
                    .fontWeight(.bold)
                    .font(.headline)
                    .foregroundStyle(Color.secondary)
                    .padding(.vertical)
            }
            ForEach(schedule.keys.compactMap({ dateFormatter_D_MMMM_YYYY.date(from: $0) }).sorted(), id: \.self) { date in
                let dateString = dateFormatter_D_MMMM_YYYY.string(from: date) // Convert back to string for display
                VStack(alignment: .leading){
                    HStack{
                        Text(dateString == dateFormatter_D_MMMM_YYYY.string(from: Date()) ? "Today" : dateString)
                            .fontWeight(.bold)
                            .font(.title3)
                            .padding(.top)
                    }
                    
                   // Section(header: Text(dateString)) {
                    HStack(alignment: .top) { // Use HStack to place the rectangle and VStack side by side
                        Rectangle()
                            .fill(Color.primary) // Set the color of the rectangle
                            .frame(width: 10) // Set the width of the rectangle
                            .cornerRadius(10)
                            .edgesIgnoringSafeArea(.vertical) // Make it span the full height

                        VStack(alignment: .leading) {
                            ForEach(schedule[dateString] ?? [], id: \.id) { supplement in
                                HStack {
                                    VStack(alignment: .leading) {
                                            Text(supplement.name)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .padding(.bottom, 5)
                                        
                                        // Display all the times
                                        SupplementTimeView(supplement: supplement)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.leading) // Add padding to the VStack
                    }

                    
                  //  }
                }
            }

          //  .navigationTitle("Upcoming Schedule")
           
        }
    }
    
    func periodDesc()->String{
        if selectedDays == 3{
            return "3 days"
        }
        if selectedDays == 7{
            return "week"
        }
        if selectedDays == 14{
            return "2 weeks"
        }
        if selectedDays == 30{
            return "1 month"
        }
        return ""
    }
    // Function to create a schedule of supplements
    private func createSupplementSchedule() -> [String: [BMSupplement]] {
        var schedule: [String: [BMSupplement]] = [:]
        let calendar = Calendar.current
        let now = Date()

        for supplement in bmSupplementStackGL.supplements.filter({ (selectedFrequency == "All" || $0.frequency.rawValue == selectedFrequency)  && $0.supplementType == supplementType}){
            // Filter by frequency if selected
            
//            if let selectedFrequency = selectedFrequency, supplement.frequency != selectedFrequency {
//                continue
//            }

            let nextDates = SupplementScheduleView.calculateNextConsumptionDates(supplement: supplement, from: Date(), inNext: selectedDays)
            
                // Add the supplement to the schedule for the next dates
                for nextDate in nextDates{
                        if schedule[scheduleKey(nextDate)] != nil {
                            schedule[scheduleKey(nextDate)]?.append(supplement)
                        } else {
                            schedule[scheduleKey(nextDate)] = [supplement]
                        }
                    }
                    //Update the next date of this supplement
                  //  nextDate = calendar.date(byAdding: .day, value: selectedDays, to: nextDate!)!
                }
            
        

        return schedule
    }
    
    func scheduleKey(_ date : Date)->String{
        return dateFormatter_D_MMMM_YYYY.string(from: date)
    }

    // Function to calculate the next consumption date based on frequency
    //returns a list of dates of conumption for this supplement starting from date 'from' in the next 'inNext' number of days
    public static func calculateNextConsumptionDates(supplement: BMSupplement, from: Date, inNext: Int) -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        let createdAt = supplement.createdAt

        // Calculate the next date based on frequency
        if supplement.timeOfConsumption.count == 0{
            return []
        }
        let dateOfSupplement = supplement.timeOfConsumption[0]
        
        guard var nextDate = dateOfSupplement else{
            //we dont have information about its time of consumption so will not display it in the schedule
            //let insanelyFutureDate = Calendar.current.date(from: DateComponents(year: 2099, month: 12, day: 31))
            //return insanelyFutureDate!
            return []
        }
        var result = [Date]()
        
        while nextDate <= calendar.date(byAdding: .day, value: inNext - supplement.frequency.intervalInDays, to: from)!{
            switch supplement.frequency {
            case .oneTime:
                nextDate = createdAt // Assuming it's a one-time supplement
            default:
                nextDate = calendar.date(byAdding: .day, value: supplement.frequency.intervalInDays, to: nextDate)!
                if nextDate >= now {
                    result.append(nextDate)
                }
            }
            
        }

        return result
    }
}


struct SupplementTimeView: View {
    var supplement: BMSupplement
    var now = Date()
    var body: some View {
        ScrollView(.horizontal,showsIndicators: false){
            HStack {
                ForEach(supplement.timeOfConsumption.sorted(by: { d1, d2 in
                    d1 ?? now < d2 ?? now
                }), id: \.self) { supp in
                    if let suppTime = supp {
                        Text(timeFormatter.string(from: suppTime))
                            .padding(8)
                            .font(.caption)
                            .background(Color(.systemGray6))
                            .foregroundColor(.secondary)
                            .cornerRadius(10)
                            .padding(.trailing,3)
                    } else {
                        // Text("No time set") // Optional: Handle nil case
                    }
                }
            }
        }
    }
}
