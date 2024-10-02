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
    @State private var mergeSelectedGroups = false

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
                VStack {
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
                                // Navigate directly to the chart view when one record is selected
                                navigateToChartView()
                            }
                        }) {
                            Text("Track \(selectedRecords.count) \(selectedRecords.count == 1 ? "Test" : "Tests")")
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
                                        // Navigate to chart view for separate tracking
                                        mergeSelectedGroups = false
                                        navigateToChartView()
                                        print("Track Each Selected Test Separately")
                                    },
                                    .default(Text("Track All Selected Tests Together")) {
                                        // Navigate to chart view for combined tracking
                                        mergeSelectedGroups = true
                                        navigateToChartView()
                                        print("Track All Selected Tests Together")
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

                // Navigation link for chart view
                NavigationLink(destination: GroupedTestRecordChartView(selectedGroupedRecords: getSelectedGroups()),isActive: $showVariationCharts) {
                    EmptyView() // This will not show any button; it only serves to navigate
                }
                .hidden() // Hide the navigation link since we navigate directly via button actions
            }
            .navigationTitle("Track Variation")
            .toolbar {
                if selectedRecords.count >= 1 {
                    Button("Deselect All") {
                        selectedRecords.removeAll()
                    }
                }
            }
        }

        

    }
    
    
    // Function to handle navigation to the chart view
    private func navigateToChartView() {
        showVariationCharts = true // Set this flag if you want to manage navigation
    }
    
    func getSelectedGroups() -> [String: [BasicMedicalTestRecordv1]] {
        // Group all test records by test name
        let allGroupedRecords = Dictionary(grouping: sys.getAllTestRecords(), by: { $0.test })
        
        // Filter the grouped records to only include the selected groups
        var selectedGroupedRecords = allGroupedRecords.filter { selectedRecords.contains($0.key) }
        
       
        // Check if we need to merge the selected groups
        if mergeSelectedGroups {
            // Combine all the records from the selected groups into one array
            let combinedRecords = selectedGroupedRecords.values.flatMap { $0 }
                
            // Create a new entry in selectedGroupedRecords for the combined records
            selectedGroupedRecords = ["combined": combinedRecords]
        }
        
        
        
        // Sort the grouped records by the test date for each group
        for (testName, records) in selectedGroupedRecords {
            // Sort records by their test date in ascending order
            let sortedRecords = records.sorted {
                guard let date1 = $0.testDate(), let date2 = $1.testDate() else {
                    return false // Handle the case where date might be nil
                }
                return date1 < date2 // Sort records by date in ascending order
            }
            
            // Update the grouped records with sorted records
            selectedGroupedRecords[testName] = sortedRecords
        }

        
      
        
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
            return groupedRecords.filter { group in
                // Check if the group name (key) matches the search text
                group.key.lowercased().contains(searchText.lowercased()) ||
                // Check if any record in the group matches the search text using satisfiedsearch
                group.value.contains { $0.satisfiesSearch(searchStr: searchText.lowercased()) }
            }
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






import SwiftUI
import Charts

struct GroupedTestRecordChartView: View {
    var selectedGroupedRecords: [String: [BasicMedicalTestRecordv1]]
   // var mergeSelectedGroups: Bool

    var body: some View {
        ScrollView(showsIndicators: false){
            VStack {
                // if mergeSelectedGroups {
                // Create a single graph for all selected records
                //i dont think we need this, if multiple test groups are to be plotted we will just put them in a single list and sort them according to date
                //  combinedChart(for: selectedGroupedRecords)
                //   } else {
                // Create separate graphs for each group
                
               
                ForEach(selectedGroupedRecords.keys.sorted(), id: \.self) { testName in
                    
                    if let records = selectedGroupedRecords[testName] {
                        
                        if let firstRecord = records.first {
                            //   Text(firstRecord.test) // Display the test name as the title of the chart
                            //      .font(.headline)
                            HStack{
                                Text(firstRecord.test)
                                    .font(.title2)
                                    .fontWeight(.bold)
        
                                Spacer()
                     
                            }//.padding(.bottom,1)
                            .padding([.top,.horizontal])
                            
                            HStack{
                                Text("Variation across \(records.count) tests")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
        
                                Spacer()
                     
                            }//.padding(.bottom,1)
                            .padding([.horizontal])
                        }
                    }
                    //
                    if let records = selectedGroupedRecords[testName] {
                        // Create a combined chart for the current group
                        singleGroupChart(for: records)
                           // .padding(.bottom)
                            .padding()
                            //.background(Color.secondary.opacity(0.2))
                            .background(CustomBlur(style: .prominent))
                            .cornerRadius(20)
                            .padding([.horizontal,.vertical])
                    }
                    
                    //display information about what tests were used using simple list p150
                    if let records = selectedGroupedRecords[testName] {
                        //Text("Tests used in the above chart").fontWeight(.bold).font(.headline)
                        ForEach(records){ testRecord in
                            NavigationLink(destination:MedicalDocumentViewerHandler(size: CGSize(width: system.fullWidth,height: system.fullHeight), doc: testRecord.getParentDocument()!)){
                                VStack(alignment: .leading){
                                    TestRecordPlainView(testRecord: testRecord,showDate: true)
                                       
                                    Text("View medical document")
                                        .foregroundStyle(Color.pink)
                                        .padding([.horizontal])
                                        .padding(.vertical,2)
                                    Divider().padding(.horizontal).padding(.vertical,3)
                                } .padding(.horizontal,5)
                            }
                        }
                    }
                    
                }
                // }
            }
            .navigationTitle("Variation with time")
            .padding()
        }
    }
        

    // Combined chart for all records
    private func combinedChart(for records: [String: [BasicMedicalTestRecordv1]]) -> some View {
        VStack {
            Text("Combined Test Results")
                .font(.headline)

            Chart {
                // Loop through each test record
                ForEach(records.flatMap { $0.value }, id: \.id) { record in
                    if let testValue = Double(record.value), let testDate = record.testDate() {
                        // Plot point marks for each record using test date as x-value
                        PointMark(
                            x: .value("Date", testDate),  // Use test date as x-value
                            y: .value("Value", testValue)
                        )
                        .symbolSize(60)
                        .foregroundStyle(record.isOutOfRange() ? .red : .green)

                        // Connect dots with a line
                        LineMark(
                            x: .value("Date", testDate),
                            y: .value("Value", testValue)
                        )
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

    // Create a single chart for a group of records
    private func singleGroupChart(for records: [BasicMedicalTestRecordv1]) -> some View {
        VStack {
            if let firstRecord = records.first {
             //   Text(firstRecord.test) // Display the test name as the title of the chart
              //      .font(.headline)
//                HStack{
//                    Text(firstRecord.test)
//                        .font(.title3)
//                        .fontWeight(.bold)
//                       
//                    
//                    
//                    Spacer()
//                    
//                  //  imageView(systemName: record.isOutOfRange() ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",color: record.isOutOfRange() ? .red : .green,size: 30)
//                    //    .padding(.trailing,3)
//                    
//                    
//                    
//                }//.padding(.bottom,1)
               // .padding()

                Chart {
                    // Loop through each record in the group
                    ForEach(records, id: \.id) { record in
                        if let testValue = Double(record.value), let testDate = record.testDate() {
                            // Plot point marks for each record using test date as x-value
                            PointMark(
                                x: .value("Date", testDate),  // Use test date as x-value
                                y: .value("Value", testValue)
                            )
                            .symbolSize(60)
                            .foregroundStyle(record.isOutOfRange() ? .red : .green)
                            
                            // Connect dots with a line
                            LineMark(
                                x: .value("Date", testDate),
                                y: .value("Value", testValue)
                            )
                            .foregroundStyle(record.isOutOfRange() ? .red : .green)
                            
                           
                            // Upper reference limit line
                            if let upperLimit = Double(record.plottablerefupperlimit ?? "") {
                                RuleMark(y: .value("Upper Limit", upperLimit.truncate(places: 2)))
                                    .foregroundStyle(.red)
                                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.5, 5]))
                            }
                            
                            // Lower reference limit line
                            if let lowerLimit = Double(record.plottablereflowerlimit ?? "") {
                                RuleMark(y: .value("Lower Limit", lowerLimit.truncate(places: 2)))
                                    .foregroundStyle(.blue)
                                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.5, 5]))
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
}
