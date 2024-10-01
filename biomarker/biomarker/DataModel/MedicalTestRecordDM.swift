//
//  HealthRecordDM.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation

//A medical document has a the original medical document reference and a list of medical records
class MedicalDocument: ObservableObject{
    
    var pdfDocumentUrl : URL//represent the documenturl of the pdf which is saved to the local file system. this is the string saved in local user defaults for later access to the document
    
    init(pdfDocumentUrl: URL){
        self.pdfDocumentUrl = pdfDocumentUrl
    }
    
    ///1 document can have multiple section, each table can have multiple tests(represented by BasicMedicalTestRecordv1)
    @Published var sections = [MedicalDocumentSection]()
    let id = UUID.init().uuidString//represents the id of the document stored in user defaults
    //some generative ai data properties
    var name = ""//todo
    var summary = ""//todo
    var keyPoints = ""//todo
    

    
    func addNewMedicalSection(section: MedicalDocumentSection){
        self.sections.append(section)
    }
}

//A medical document has a the original medical document reference and a list of medical records
class MedicalDocumentSection: ObservableObject{
    ///1 document can have multiple sections, each section can have multiple tests(represented by BasicMedicalTestRecordv1)
    @Published var testRecords = [BasicMedicalTestRecordv1]()
    let id = UUID.init().uuidString
    //some generative ai data properties
    let name = ""//todo
    let summary = ""//todo
    let keyPoints = ""//todo
    
    func addNewMedicalTestRecords(testRecords: BasicMedicalTestRecordv1){
        self.testRecords.append(testRecords)
    }
    
}

class BasicMedicalTestRecordv1: Codable {
    let test: String
    let value: String
    let unit: String
    let plottable: String
    let ref: String?
    let plottableref: String?
    let plottablereflowerlimit: String?
    let plottablerefupperlimit: String?
    let id = UUID.init().uuidString

    enum CodingKeys: String, CodingKey {
        case test
        case value
        case unit
        case plottable
        case ref
        case plottableref
        case plottablereflowerlimit
        case plottablerefupperlimit
    }
}

