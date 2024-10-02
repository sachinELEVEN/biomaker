import Foundation
import SwiftUI

// MARK: - Settings View
struct VariationView: View {
    @ObservedObject var sys = system
    
    @State private var selectedRecords: Set<String> = []  // Track selected records
    @State private var showActionSheet = false            // Control action sheet visibility
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    GroupedTestRecordsView(testRecords: sys.getAllTestRecords(), selectedRecords: $selectedRecords)
                }
                
                // "Compare" button at the bottom
                VStack{
                    Text("Track how test results vary across medical records. Select one or more tests to compare and analyze.")
                    // .fontWeight(.bold)
                        .font(.subheadline)
                        .padding([.horizontal])
                        .padding(.top,3)
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
                            Text("Compare")
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
                                    .default(Text("Track All Rows Together")) {
                                        print("Track all selected rows together")
                                    },
                                    .default(Text("Track Each Row Separately")) {
                                        print("Track each row separately")
                                    },
                                    .cancel()
                                ]
                            )
                        }
                    }
                    
                    else{
                        
                        
                        //Dummy compare button
                        Text("Compare")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                        
                        
                    }
                }
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10, style: .continuous)
//                        .stroke(selectedRecords.isEmpty ? Color.secondary : Color.blue, lineWidth: 1)
//                        
//                )
                
            }
            .navigationTitle("Track Variation")
        }
    }
}

// MARK: - GroupedTestRecordsView
struct GroupedTestRecordsView: View {
    var testRecords: [BasicMedicalTestRecordv1]
    
    @Binding var selectedRecords: Set<String>  // Binding to track selected records
    
    // Group the test records by test name
    var groupedRecords: [String: [BasicMedicalTestRecordv1]] {
        Dictionary(grouping: testRecords, by: { $0.test })
    }

    var body: some View {
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
                .background(selectedRecords.contains(testName) ? Color.blue.opacity(0.2) : Color.clear)
                .onTapGesture {
                    // Toggle selection of the row
                    if selectedRecords.contains(testName) {
                        selectedRecords.remove(testName)
                    } else {
                        selectedRecords.insert(testName)
                    }
                }
                
                Divider().padding(.horizontal)
            }
        }
        .navigationTitle("Track Variation")
    }
}
