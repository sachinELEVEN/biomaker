//
//  HealthRecordDM.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation

//A medical document has a the original medical document reference and a list of medical records
class MedicalDocument: ObservableObject,Identifiable,Codable{
    
    enum CodingKeys: String, CodingKey {
            case pdfDocumentUrl
            case date
            case sections
            case id
            case name
            case summary
            case healthInsights
            case notes
        }
    
    public static var manualSectionName = "Manually Added Tests"
    var pdfDocumentUrl : URL//represent the documenturl of the pdf which is saved to the local file system. this is the string saved in local user defaults for later access to the document
    var date:Date
    
    init(pdfDocumentUrl: URL, date: Date = Date()) {
           self.pdfDocumentUrl = pdfDocumentUrl
           self.date = date
           self.id = UUID().uuidString
       }
    
    // Manually implement encoding
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(pdfDocumentUrl, forKey: .pdfDocumentUrl)
            try container.encode(date, forKey: .date)
            try container.encode(sections, forKey: .sections)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(summary, forKey: .summary)
            try container.encode(healthInsights, forKey: .healthInsights)
            try container.encode(notes, forKey: .notes)
        }

        // Manually implement decoding
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            pdfDocumentUrl = try container.decode(URL.self, forKey: .pdfDocumentUrl)
            date = try container.decode(Date.self, forKey: .date)
            sections = try container.decode([MedicalDocumentSection].self, forKey: .sections)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            summary = try container.decode(String.self, forKey: .summary)
            healthInsights = try container.decode(String.self, forKey: .healthInsights)
            notes = try container.decode(String.self, forKey: .notes)
        }
    
    ///1 document can have multiple section, each table can have multiple tests(represented by BasicMedicalTestRecordv1)
    @Published var sections = [MedicalDocumentSection]()
    var id = UUID.init().uuidString//represents the id of the document stored in user defaults
    //some generative ai data properties
    var name = ""//todo
    var summary = ""//todo
    var healthInsights = "Visit a doctor to better understand your reports. You can also track changes in your test results over time by pressing the 'Variation' button at the bottom"//todo
    var notes = ""//user notes
    

    ///creates a new manually added section if it does not already exist
    func addNewTestRecordToManuallyAddedSection(testRecord: BasicMedicalTestRecordv1){
        for section in sections {
            if section.name == MedicalDocument.manualSectionName{
                section.addNewMedicalTestRecords(testRecords: testRecord)
                return
            }
        }
        
        //no Manual section presente
        let manualSection = MedicalDocumentSection()
        manualSection.name = MedicalDocument.manualSectionName
        manualSection.addNewMedicalTestRecords(testRecords: testRecord)
        self.addNewMedicalSection(section: manualSection)
    }
    
    func addNewMedicalSection(section: MedicalDocumentSection){
        self.sections.append(section)
    }
    
    func totalTestRecordsCount()->Int{
        var count = 0
        for section in sections{
            count += section.testRecords.count
        }
        return count
    }
    
    func totalTestOutOfRangeCount()->Int{
        var count = 0
        for section in sections{
            for test in section.testRecords{
                count += test.isOutOfRange() ? 1 : 0
            }
        }
        return count
    }
    
    func countOfTestsWIthAIInfo()->Int{
        var count = 0
        for section in sections{
            for test in section.testRecords{
                count += test.ai_info_available() ? 1 : 0
            }
        }
        return count
    }
    
    //this is such a stupid method, but its 3:50 in the morning, and i am not spending time on arguing with myselfg
    func findIndexOfSection(section: MedicalDocumentSection)->Int{
        var index = 0;
        for _section in sections {
            if _section.id == section.id{
                break
            }
            index += 1
        }
        
        return index
    }
    
    func setup_medical_document(){
        
        //setting up of test record
        for section in sections{
            for test in section.testRecords{
                test.setup_test_record()
            }
        }
    }
    
    //
    func getDocSummary(maxLength: Int = Int.max) -> String {
        var summary = "Biomarker found \(totalTestRecordsCount()) tests in the document.\n"
        var organSet: Set<String> = Set()
        
        // Collect unique organs
        for section in sections {
            for test in section.testRecords {
                let listOfOrgans = splitIntoListBy(test.ai_related_organs ?? "", delimiters: [",", ";"])
                organSet.formUnion(listOfOrgans) // Add unique organs to the set
            }
        }
        
        if !organSet.isEmpty {
            summary += "The report focuses on tests for: "
            summary += organSet.sorted().joined(separator: ", ") // Combine organ names, sorted, and separated by commas
        }
        
        if summary.count > maxLength{
            return summary.prefix(maxLength) + "..."
        }
        return summary
    }
    
    func getDocOrgans(maxLength: Int = Int.max) -> [String] {
//        var summary = "Biomarker found \(totalTestRecordsCount()) tests in the document.\n"
        var organSet: Set<String> = Set()
        
        // Collect unique organs
        for section in sections {
            for test in section.testRecords {
                let listOfOrgans = splitIntoListBy(test.ai_related_organs ?? "", delimiters: [",", ";"])
                organSet.formUnion(listOfOrgans) // Add unique organs to the set
            }
        }
        
        if !organSet.isEmpty {
            //summary += "The report focuses on tests for: "
            summary += organSet.sorted().joined(separator: ", ") // Combine organ names, sorted, and separated by commas
        }
        
//        if summary.count > maxLength{
//            return summary.prefix(maxLength) + "..."
//        }
        //return summary
        return organSet.sorted()
    }

    // Helper function to split strings by multiple delimiters
    func splitIntoListBy(_ input: String, delimiters: [String]) -> [String] {
        let pattern = delimiters.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let matches = regex?.split(input) ?? []
        return matches.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }


    
    //
    
}

//A medical document has a the original medical document reference and a list of medical records
class MedicalDocumentSection: ObservableObject, Identifiable, Codable{
    ///1 document can have multiple sections, each section can have multiple tests(represented by BasicMedicalTestRecordv1)
    @Published var testRecords = [BasicMedicalTestRecordv1]()
    var id = ""
    //some generative ai data properties
    var name = ""//todo
    var summary = ""//todo
    var keyPoints = ""//todo
    
    enum CodingKeys: String, CodingKey {
            case testRecords
            case id
            case name
            case summary
            case keyPoints
        }
    
    init() {
            self.id = UUID().uuidString
        }
    
    // Manually implement encoding
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(testRecords, forKey: .testRecords)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(summary, forKey: .summary)
            try container.encode(keyPoints, forKey: .keyPoints)
        }

        // Manually implement decoding
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            testRecords = try container.decode([BasicMedicalTestRecordv1].self, forKey: .testRecords)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            summary = try container.decode(String.self, forKey: .summary)
            keyPoints = try container.decode(String.self, forKey: .keyPoints)
        }
    
    func addNewMedicalTestRecords(testRecords: BasicMedicalTestRecordv1){
        self.testRecords.append(testRecords)
    }
    
}

class BasicMedicalTestRecordv1: Codable, Identifiable {
    var test: String////this is the full name that was actually present in the report aka which has been detected by our pdf analysis system
    var value: String
    var unit: String
    var plottable: String
    var ref: String?
    var plottableref: String?
    var plottablereflowerlimit: String?
    var plottablerefupperlimit: String?
    var id = UUID.init().uuidString
    //llm generated data below
    var ai_original_name: String?//same as test in the response from the server
    var ai_common_name: String?//i would say this is more user friendly name, so try to use this for user facing string
    var ai_ref_range_lower_male: Float?
    var ai_ref_range_upper_male: Float?
    var ai_ref_range_lower_female: Float?
    var ai_ref_range_upper_female: Float?
    var ai_unit: String?
    var ai_use: String?
    var ai_reason_for_high_value: String?
    var ai_reason_for_lower_value: String?
    var ai_related_organs: String?
    var ai_properties_set: String?//yes when its set
    

    enum CodingKeys: String, CodingKey {
        case test
        case value
        case unit
        case plottable
        case ref
        case plottableref
        case plottablereflowerlimit
        case plottablerefupperlimit
        case ai_original_name
        case ai_common_name
        case ai_ref_range_lower_male
        case ai_ref_range_upper_male
        case ai_ref_range_lower_female
        case ai_ref_range_upper_female
        case ai_unit
        case ai_use
        case ai_reason_for_high_value
        case ai_reason_for_lower_value
        case ai_related_organs
        case ai_properties_set
    }
    
    init(test: String, value: String, unit: String, plottable: String, ref: String? = nil, plottableref: String? = nil, plottablereflowerlimit: String? = nil, plottablerefupperlimit: String? = nil, ai_original_name: String? = nil, ai_common_name: String? = nil, ai_ref_range_lower_male: Float? = nil, ai_ref_range_upper_male: Float? = nil, ai_ref_range_lower_female: Float? = nil, ai_ref_range_upper_female: Float? = nil, ai_unit: String? = nil, ai_use: String? = nil, ai_reason_for_high_value: String? = nil, ai_reason_for_lower_value: String? = nil, ai_related_organs: String? = nil, ai_properties_set: String = "no" ) {
           self.test = test
           self.value = value
           self.unit = unit
           self.plottable = plottable
           self.ref = ref
           self.plottableref = plottableref
           self.plottablereflowerlimit = plottablereflowerlimit
           self.plottablerefupperlimit = plottablerefupperlimit
           //self.id = UUID().uuidString // Automatically generate UUID
           //Using LLM generated fields
        self.ai_original_name = ai_original_name
        self.ai_common_name = ai_common_name
        self.ai_ref_range_lower_male = ai_ref_range_lower_male
        self.ai_ref_range_upper_male = ai_ref_range_upper_male
        self.ai_ref_range_lower_female = ai_ref_range_lower_female
        self.ai_ref_range_upper_female = ai_ref_range_upper_female
        self.ai_unit = ai_unit
        self.ai_use = ai_use
        self.ai_reason_for_high_value = ai_reason_for_high_value
        self.ai_reason_for_lower_value = ai_reason_for_lower_value
        self.ai_related_organs = ai_related_organs
        //this needs to be set if the ai data is generated for this test. Note- this will be mostly true for documents analysed by the server but for locally added tests this will be false, so we use this property to determine if we need to show an option to do ai analysis for that test or not
        self.ai_properties_set = ai_properties_set
        
        //additional stuff
        setup_test_record()
       }
    
    func setup_test_record(){
        if self.plottablereflowerlimit == nil{
            //taking average of men and women rating, change this once we start capturing if the user is men or women
            //we will be taking men's value for now, as this is just indicative, taking average will mess up the result as tests like testosterone has huge diff in its ref ranges between both the male and female
            if let ref_low_male = self.ai_ref_range_lower_male{
                self.plottablereflowerlimit = "\(ref_low_male)"
            }
            
            if let ref_upper_male = self.ai_ref_range_upper_male {
                self.plottablerefupperlimit = "\(ref_upper_male)"
            }
            
          
        }
    }
    
    func ai_info_available()->Bool{
        return ai_properties_set != nil && ai_properties_set! == "yes"
    }
    
    func userFacingTestName()->String{
        return ai_common_name ?? test
    }
    
    func userFacingUnit()->String{
        return ai_unit ?? unit
    }
    
    func getDouble(_ val: String)->Double{
        return Double(val) ?? -1
    }
    
    //we will only consider those who have a ref range specified
    func isOutOfRange()->Bool{
        if plottableref != nil && plottablereflowerlimit != nil && plottablerefupperlimit != nil{
            if getDouble(value) > getDouble(plottablerefupperlimit!) || getDouble(value) < getDouble(plottablereflowerlimit!)
            {
                return true
            }
        }
        
        return false
    }
    
    //returns the date of the medical document created
    //it returns an optional because its used by swiftui charts which requires optional value
    func testDate()->Date?{
        for doc in system.medicalDocuments{
            for section in doc.sections{
                for testRecord in section.testRecords{
                    if testRecord.id == self.id{
                       // print(doc.date)
                        return doc.date
                    }
                }
            }
        }
        
        //returning today's date// this should never happen because the test should be in one of the docment
        return Date()
    }
    
    func ref_range_male_exists()->Bool{
        return ai_ref_range_lower_male != nil && ai_ref_range_upper_male != nil
    }
    
    func ref_range_female_exists()->Bool{
        return ai_ref_range_lower_female != nil && ai_ref_range_upper_female != nil
    }
    
    func getParentDocument()->MedicalDocument?{
        print("Test record \(id) looking for parent document")
        for doc in system.medicalDocuments{
            for section in doc.sections{
                for testRecord in section.testRecords{
                    if testRecord.id == self.id{
                       // print(doc.date)
                        return doc
                    }
                }
            }
        }
        
        return nil
    }
    
    func getParentSection()->MedicalDocumentSection?{
        for doc in system.medicalDocuments{
            for section in doc.sections{
                for testRecord in section.testRecords{
                    if testRecord.id == self.id{
                       // print(doc.date)
                        return section
                    }
                }
            }
        }
        
        return nil
    }
    
    
    ///returns a boolean value indicating whether this result matches the search key string
    func satisfiesSearch(searchStr: String)->Bool{
        //we need to get parent section's summary, name access here
        if let parentSection = getParentSection(){
            //now we need to make a corpus text and find the string there
            if parentSection.name.lowercased().contains(searchStr) || parentSection.summary.lowercased().contains(searchStr) || parentSection.keyPoints.lowercased().contains(searchStr) ||
                (ai_original_name?.lowercased() ?? "").contains(searchStr) ||
                (ai_common_name?.lowercased() ?? "").contains(searchStr) ||
                (ai_use?.lowercased() ?? "").contains(searchStr) ||
                (ai_related_organs?.lowercased() ?? "").contains(searchStr) ||
                (ai_reason_for_high_value?.lowercased() ?? "").contains(searchStr) ||
                (ai_reason_for_lower_value?.lowercased() ?? "").contains(searchStr){
                return true
            }
        }
        
        return false
    }
    
    //returns a boolean value indicating whether deletion from system was a success or not
    func deleteFromSystem()->Bool{
        guard let section = getParentSection() else{
            print("/deleteFromSystem- Failed to remove test as it does not have a parent section. This means this test is just a standalone test and not part of the system")
            return false
        }
        
        var didDelete = false
        section.testRecords.removeAll { record in
            if (record.id == self.id){
                didDelete = true
                return true
            }
            return false
        }
        
        if didDelete{
            print("deleteFromSystem- test record removed from system")
            system.refresh()
        }
        return didDelete
        
                
    }
    
}

