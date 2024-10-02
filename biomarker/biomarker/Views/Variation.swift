import Foundation
import SwiftUI

// MARK: - VariationView
struct VariationView: View {
    @ObservedObject var sys = system
    
    @State private var selectedRecords: Set<String> = []  // Track selected records
    @State private var showActionSheet = false            // Control action sheet visibility
    @State private var searchText = ""                   // Text to filter records

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
                                    .default(Text("Track All Selected Tests Together")) {
                                        print("rack All Selected Tests Together")
                                    },
                                    .default(Text("Track Each Selected Test Separately")) {
                                        print("Track Each Selected Test Separately")
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
