//
//  SupplementDetailedView.swift
//  biomarker
//
//  Created by sachin jeph on 02/02/25.
//

import Foundation
import SwiftUI


struct SupplementDetailView: View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    @Binding var showSelf : Bool
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

}
