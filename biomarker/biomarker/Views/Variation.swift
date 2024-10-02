import Foundation
import SwiftUI
import Charts

// MARK: - VariationView
struct VariationView: View {
    @ObservedObject var sys = system
    
    @State private var selectedRecords: Set<String> = []  // Track selected records
    @State private var showActionSheet = false            // Control action sheet visibility
    @State private var searchText = ""                   // Text to filter records
    @State private var showVariationCharts = false
    @State private var trackThemAllTogether = false

    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search tests...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                ScrollView {
                    GroupedTestRecordsView(
                        testRecords: sys.getAllTestRecords(),
                        selectedRecords: $selectedRecords,
                        searchText: searchText // Pass the search text
                    )
                }
                
                // "Track" button at the bottom
                VStack{
                    Text("Track how test results vary across medical records. Select one or more tests to Track and analyze.")
                        .font(.subheadline)
                        .padding([.horizontal])
                        .padding(.top, 3)
                        .foregroundStyle(Color.secondary)
                    
                    if !selectedRecords.isEmpty {
                        Button(action: {
                            // Show action sheet when 2 or more records are selected
                            if selectedRecords.count > 1 {
                                showActionSheet = true
                            } else {
                                print("1 row selected only")
                            }
                        }) {
                            Text("Track \(selectedRecords.count) \(selectedRecords.count==1 ? "Test" : "Tests")")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding()
                        }
                        .actionSheet(isPresented: $showActionSheet) {
                            ActionSheet(
                                title: Text("Track Variation"),
                                message: Text("How would you like to track the variations?"),
                                buttons: [
                                    .default(Text("Track Each Selected Test Separately")) {
                                        trackThemAllTogether = false
                                        showVariationCharts = true
                                        print("Track Each Selected Test Separately")
                                    },
                                    .default(Text("Track All Selected Tests Together")) {
                                        trackThemAllTogether = true
                                        showVariationCharts = true
                                        print("rack All Selected Tests Together")
                                    },
                                    .cancel()
                                ]
                            )
                        }
                    } else {
                        // Disabled Track button
                        Text("Track")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                    }
                }
                
                //track variation charts
                NavigationLink(destination: GroupedTestRecordView(selectedGroupedRecords: getSelectedGroups(), trackThemAllTogether: self.trackThemAllTogether)) {
                    Text("show")
                }
            }
            .navigationTitle("Track Variation")
            .toolbar {
                if selectedRecords.count >= 1{
                    Button("Deselect All") {
                        selectedRecords.removeAll()
                    }
                    
                }

                            }
        }
    }
    
    
    func getSelectedGroups() -> [String: [BasicMedicalTestRecordv1]] {
        // Group all test records by test name
        let allGroupedRecords = Dictionary(grouping: sys.getAllTestRecords(), by: { $0.test })
        
        // Filter the grouped records to only include the selected groups
        let selectedGroupedRecords = allGroupedRecords.filter { selectedRecords.contains($0.key) }
        
        //we should sort them by document.date before here
        //TODO
        return selectedGroupedRecords
    }

    
}

// MARK: - GroupedTestRecordsView
struct GroupedTestRecordsView: View {
    var testRecords: [BasicMedicalTestRecordv1]
    
    @Binding var selectedRecords: Set<String>  // Binding to track selected records
    var searchText: String                     // Search text to filter records
    
    // Group the test records by test name
    var groupedRecords: [String: [BasicMedicalTestRecordv1]] {
        Dictionary(grouping: testRecords, by: { $0.test })
    }

    // Filtered records based on search text
    var filteredRecords: [String: [BasicMedicalTestRecordv1]] {
        if searchText.isEmpty {
            return groupedRecords
        } else {
            return groupedRecords.filter { $0.key.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        ForEach(filteredRecords.keys.sorted(), id: \.self) { testName in
            if let group = filteredRecords[testName] {
                Button(action:{
                    // Toggle selection of the row
                    if selectedRecords.contains(testName) {
                        selectedRecords.remove(testName)
                    } else {
                        selectedRecords.insert(testName)
                    }
                }){
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
                }
               
                .padding(.vertical,8)
                .padding(.horizontal,8)
                .background(selectedRecords.contains(testName) ? Color.blue.opacity(0.2) : Color.clear)
                
                .cornerRadius(10)
                
                .padding(.horizontal)
                
            
                
                Divider().padding(.horizontal)
            }
        }
    }
}




struct GroupedTestRecordView: View {
    var selectedGroupedRecords: [String: [BasicMedicalTestRecordv1]]
    var trackThemAllTogether: Bool

    var body: some View {
        ScrollView(showsIndicators: false){
            VStack {
                if trackThemAllTogether {
                    // Create a single graph for all selected records
                    combinedChart(for: selectedGroupedRecords)
                } else {
                    // Create separate graphs for each group
                    ForEach(selectedGroupedRecords.keys.sorted(), id: \.self) { testName in
                        if let records = selectedGroupedRecords[testName] {
                            ForEach(records, id: \.id) { record in
                                TestRecordView(record: record)
                                    .padding(.bottom)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Test Records")
        .padding()
    }

    // Combined chart for all records
    private func combinedChart(for records: [String: [BasicMedicalTestRecordv1]]) -> some View {
        VStack {
            Text("Combined Test Results")
                .font(.headline)
            
            // Create an empty chart
            Chart {
                // Loop through each test record
                ForEach(records.flatMap { $0.value }, id: \.id) { record in
                    if let testValue = Double(record.value) {
                        // Plot point marks for each record
                        PointMark(
                            x: .value("Test", record.test),
                            y: .value("Value", testValue)
                        )
                        .symbolSize(60)
                        .foregroundStyle(record.isOutOfRange() ? .red : .green)
                        
                        // Upper reference limit line
                        if let upperLimit = Double(record.plottablerefupperlimit ?? "") {
                            RuleMark(y: .value("Upper Limit", upperLimit.truncate(places: 2)))
                                .foregroundStyle(.red)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                        
                        // Lower reference limit line
                        if let lowerLimit = Double(record.plottablereflowerlimit ?? "") {
                            RuleMark(y: .value("Lower Limit", lowerLimit.truncate(places: 2)))
                                .foregroundStyle(.blue)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .frame(height: 300)
        }
    }
}
