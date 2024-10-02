//
//  Variation.swift
//  biomarker
//
//  Created by sachin jeph on 02/10/24.
//

import Foundation
import SwiftUI

// MARK: - Settings View
struct VariationView: View {
    @ObservedObject var sys = system
    var body: some View {
        NavigationView {
            ScrollView{

                GroupedTestRecordsView(testRecords: sys.getAllTestRecords())
                
                
            } .navigationTitle("Track Variation")
        }
    }
}

struct GroupedTestRecordsView: View {
    var testRecords: [BasicMedicalTestRecordv1]

    // Group the test records by test name
    var groupedRecords: [String: [BasicMedicalTestRecordv1]] {
        Dictionary(grouping: testRecords, by: { $0.test })
    }

    var body: some View {
       // List {
            // Loop through each group of test records
            ForEach(groupedRecords.keys.sorted(), id: \.self) { testName in
                if let group = groupedRecords[testName] {
                    HStack {
                        // Display the group name (test name)
                        Text(testName)
                            .font(.headline)

                        Spacer()

                        // Display the number of items in the group
                        Text("Found \(group.count) \(group.count == 1 ? "time" : "times")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    Divider().padding(.horizontal)
                }
            }
       // }
        .navigationTitle("Track Variation")
    }
}
