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
                            
                            ForEach(bmSupplementStackGL.supplements){ supp in
                                SupplementRow(supplement: supp)
                                
                            }
                            
                            
                            Text("Schedule")
                            //.italic()
                            //.underline()
                                .fontWeight(.bold)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                            
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

                    Spacer()

                    Text(supplement.frequency.rawValue) // Display frequency
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(supplement.form?.rawValue ?? "") // Display form
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Display time of consumption
                if !supplement.timeOfConsumption.isEmpty {
                    Text("Dosage Times: \(formatTimeOfConsumption(supplement.timeOfConsumption))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Display next consumption date
                if let nextDate = calculateNextConsumptionDate(supplement: supplement) {
                    Text("Upcoming dose is on: \(nextDate, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
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


    // Function to calculate the next consumption date
    private func calculateNextConsumptionDate(supplement: BMSupplement) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let createdAt = supplement.createdAt

        // Calculate the next date based on frequency
        var nextDate: Date?

        switch supplement.frequency {
        case .daily:
            nextDate = calendar.date(byAdding: .day, value: 1, to: now)
        case .weekly:
            nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: now)
        case .daily2:
            nextDate = calendar.date(byAdding: .day, value: 1, to: now)
        case .daily3:
            nextDate = calendar.date(byAdding: .day, value: 1, to: now)
        case .monthly:
            nextDate = calendar.date(byAdding: .month, value: 1, to: now)
        case .oneTime:
            nextDate = createdAt // Assuming it's a one-time supplement
        }

        return nextDate
    }
}

struct SupplementScheduleView: View {
    //var bmSupplementStackGL: BMSupplementStack // Assuming this is your data model
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    
    @State private var selectedDays: Int = 7 // Default to 7 days
    @State private var selectedFrequency: String = "All"// No filter by default

    var body: some View {
        VStack {
            // Picker for selecting the number of days
            Picker("Select Schedule Duration", selection: $selectedDays) {
                Text("3 Days").tag(3)
                Text("7 Days").tag(7)
                Text("2 Weeks").tag(14)
                Text("1 Month").tag(30)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Picker for filtering by frequency
//            Picker("Filter by Frequency", selection: $selectedFrequency) {
//               // Text("All").tag(nil as BMSupplementFrequency?) // Tag for nil
//                ForEach(BMSupplementFrequency.allCases, id: \.self) { frequency in
//                    Text(frequency.rawValue).tag(frequency.rawValue) // Tag for each frequency
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding()
            
            HStack{
                Text("Frequency")
                    .fontWeight(.bold)
                    .font(.headline)
                    //.fontWeight(.bold)
                    Spacer()
                Picker("Frequency", selection: $selectedFrequency) {
                               Text("All").tag("All") // Tag for "All"
                               Text("One time").tag("One time")
                               Text("1 time Daily").tag("1 time Daily")
                               Text("2 times daily").tag("2 times daily")
                               Text("3 times daily").tag("3 times daily")
                               Text("Weekly").tag("Weekly")
                               Text("Monthly").tag("Monthly")
                           }.pickerStyle(MenuPickerStyle())
                    .padding(5)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.trailing)
            }//.padding(.top)
                .padding(.horizontal)

            let schedule = createSupplementSchedule()
            
           // List {
                ForEach(schedule.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(schedule[key] ?? [], id: \.id) { supplement in
                            Text(supplement.name)
                        }
                    }
               // }
            }
          //  .navigationTitle("Upcoming Schedule")
           
        }
    }

    // Function to create a schedule of supplements
    private func createSupplementSchedule() -> [String: [BMSupplement]] {
        var schedule: [String: [BMSupplement]] = [:]
        let calendar = Calendar.current
        let now = Date()

        for supplement in bmSupplementStackGL.supplements.filter({ selectedFrequency == "All" || $0.frequency.rawValue == selectedFrequency }){
            // Filter by frequency if selected
            
//            if let selectedFrequency = selectedFrequency, supplement.frequency != selectedFrequency {
//                continue
//            }

            var nextDate = calculateNextConsumptionDate(supplement: supplement)

            // Add the supplement to the schedule for the next dates
            while nextDate <= calendar.date(byAdding: .day, value: selectedDays, to: now)! {
                if schedule[scheduleKey(nextDate)] != nil {
                    schedule[scheduleKey(nextDate)]?.append(supplement)
                } else {
                    schedule[scheduleKey(nextDate)] = [supplement]
                }
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
            }
        }

        return schedule
    }
    
    func scheduleKey(_ date : Date)->String{
        return dateFormatter.string(from: date)
    }

    // Function to calculate the next consumption date based on frequency
    private func calculateNextConsumptionDate(supplement: BMSupplement) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let createdAt = supplement.createdAt

        // Calculate the next date based on frequency
        var nextDate: Date?

        switch supplement.frequency {
        case .daily:
            nextDate = calendar.date(byAdding: .day, value: 1, to: now)
        case .weekly:
            nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: now)
        case .daily2:
            nextDate = calendar.date(byAdding: .day, value: 1, to: now)
        case .daily3:
            nextDate = calendar.date(byAdding: .day, value: 1, to: now)
        case .monthly:
            nextDate = calendar.date(byAdding: .month, value: 1, to: now)
        case .oneTime:
            nextDate = createdAt // Assuming it's a one-time supplement
        }

        return nextDate ?? now
    }
}



