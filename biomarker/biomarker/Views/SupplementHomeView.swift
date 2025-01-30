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
