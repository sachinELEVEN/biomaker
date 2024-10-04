import SwiftUI

struct CreateTestRecordView: View {
    @Binding var showSelf: Bool
    var document: MedicalDocument
    var existingRecord: BasicMedicalTestRecordv1? = nil  // Accept an existing record for editing

    @State private var test = ""
    @State private var value: Double? = nil
    @State private var unit = ""
    @State private var plottablereflowerlimit: Double? = nil
    @State private var plottablerefupperlimit: Double? = nil

    @State private var newRecord: BasicMedicalTestRecordv1? = nil
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .bottom) {
                    if newRecord == nil {
                        Form {
                            Section(header: Text("Test Details")) {
                                TextField("Test Name (Required)", text: $test)
                                TextField("Value (numeric) (Required)", value: $value, format: .number)
                                    .keyboardType(.decimalPad)
                                TextField("Unit (Required)", text: $unit)
                            }

                            Section(header: Text("Optional Reference Range"),
                                    footer: Text("Add upper and lower reference values for this test.")) {
                                TextField("Lower Reference Limit (numeric)", value: $plottablereflowerlimit, format: .number)
                                    .keyboardType(.decimalPad)
                                TextField("Upper Reference Limit (numeric)", value: $plottablerefupperlimit, format: .number)
                                    .keyboardType(.decimalPad)
                            }
                        }
                        .onAppear {
                            loadExistingRecord()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading) {
                                TestRecordView(record: newRecord!)
                                    .padding()
                                    .background(CustomBlur(style: .prominent))
                                    .cornerRadius(20)
                                    .padding(.horizontal)

                                Text("\(newRecord!.test) test record has been \(existingRecord == nil ? "added" : "updated").")
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(Color.green)
                                    .padding()
                                    .padding(.horizontal)
                            }
                        }
                    }

                    VStack(alignment: .center) {
                        if !errorMessage.isEmpty && newRecord == nil {
                            Text(errorMessage)
                                .multilineTextAlignment(.leading)
                                .fontWeight(.bold)
                                .foregroundColor(Color.red)
                                .padding(.leading)
                        }

                        Button(action: {
                            if newRecord != nil {
                                showSelf.toggle()
                                return
                            }
                            createOrUpdateTestRecord()
                            system.refresh()
                        }) {
                            Text(newRecord != nil ? "Close" : existingRecord == nil ? "Create Test Record" : "Update Test Record")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isAllowedToPersistChanges() ? Color.blue : Color.secondary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding()
                                .disabled(!isAllowedToPersistChanges())
                        }
                    }
                    .padding(.bottom)
                }.animation(.default)
            }
            .navigationTitle(newRecord != nil ? "\(newRecord!.test) \(existingRecord == nil ? "Added" : "Updated")" : existingRecord == nil ? "Create Test Record" : "Edit Test Record")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func loadExistingRecord() {
        if let record = existingRecord {
            // Populate fields with existing record data
            test = record.test
            value = Double(record.value)  // Convert string to Double
            unit = record.unit
            plottablereflowerlimit = Double(record.plottablereflowerlimit ?? "")
            plottablerefupperlimit = Double(record.plottablerefupperlimit ?? "")
        }
    }

    func isAllowedToPersistChanges() -> Bool {
        return value != nil && !test.isEmpty && !unit.isEmpty
    }

    func createOrUpdateTestRecord() {
        if test.isEmpty {
            errorMessage = "Please enter a test name"
            return
        }

        guard let testValue = value else {
            print("Value is not a valid number.")
            errorMessage = "Test Value should be a number"
            return
        }

        if unit.isEmpty {
            errorMessage = "Test unit cannot be left empty"
            return
        }

        // Handle optional reference limits
        let hasLowerLimit = plottablereflowerlimit != nil
        let hasUpperLimit = plottablerefupperlimit != nil

        let plottableref = (hasLowerLimit || hasUpperLimit) ? "yes" : "no"
        var ref: String? = nil
        if hasLowerLimit || hasUpperLimit {
            let lower = plottablereflowerlimit?.description ?? ""
            let upper = plottablerefupperlimit?.description ?? ""
            ref = "\(lower)-\(upper)"
        }

        let record = BasicMedicalTestRecordv1(
            test: test,
            value: testValue.description,  // Convert to string
            unit: unit,
            plottable: "yes",  // Since value is a number, plottable is yes
            ref: ref,
            plottableref: plottableref,
            plottablereflowerlimit: hasLowerLimit ? plottablereflowerlimit?.description : nil,
            plottablerefupperlimit: hasUpperLimit ? plottablerefupperlimit?.description : nil
        )

        newRecord = record

        // Update or add the record in the medical document
        if let existing = existingRecord {
            // Update the existing record in the document
            existing.test = newRecord!.test
            existing.value = newRecord!.value
            existing.unit = newRecord!.unit
            existing.plottable = newRecord!.plottable
            existing.ref = newRecord!.ref
            existing.plottableref = newRecord!.plottable
            existing.plottablereflowerlimit = newRecord!.plottablereflowerlimit
            existing.plottablerefupperlimit = newRecord!.plottablerefupperlimit
            print("Modified existing test record")
        } else {
            // Add a new record to the manually added section
            document.addNewTestRecordToManuallyAddedSection(testRecord: newRecord!)
        }
    }
}


struct TestRecordEditActionView: View{
    @ObservedObject var sys = system
    var testRecord: BasicMedicalTestRecordv1
    var iconSize : CGFloat = 25
    @State var showActionSheet = false
    @State var showUpdateTestManuallyScreen = false
    var body : some View{
        Button(action:{
            showActionSheet = true
        }){
            imageView(systemName: "info.circle",color: .secondary.opacity(0.4),size: iconSize)
                .padding(.trailing,5)
        }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Actions"),
                    message: Text(""),
                    buttons: [
                        .default(Text("Edit Test Values")) {
                            // Navigate to chart view for separate tracking
                            //mergeSelectedGroups = false
                           // navigateToChartView()
                            //print("Each Test Separately")
                            showUpdateTestManuallyScreen.toggle()
                        },
                        .default(Text("Delete Test From Report")) {
                            // Navigate to chart view for combined tracking
                           // mergeSelectedGroups = true
                           // navigateToChartView()
                            //print("Analyze All Tests as a Single Group")
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showUpdateTestManuallyScreen){
                CreateTestRecordView(showSelf: $showUpdateTestManuallyScreen, document: testRecord.getParentDocument()!, existingRecord: testRecord)
            }
    }
}
