//
//  HealthRecordDM.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation

//A medical document has a the original medical document reference and a list of medical records
class MedicalDocument: ObservableObject,Identifiable{
    
    var pdfDocumentUrl : URL//represent the documenturl of the pdf which is saved to the local file system. this is the string saved in local user defaults for later access to the document
    var date:Date
    
    init(pdfDocumentUrl: URL, date:Date = Date()){
        self.pdfDocumentUrl = pdfDocumentUrl
        self.date = date
    }
    
    ///1 document can have multiple section, each table can have multiple tests(represented by BasicMedicalTestRecordv1)
    @Published var sections = [MedicalDocumentSection]()
    let id = UUID.init().uuidString//represents the id of the document stored in user defaults
    //some generative ai data properties
    var name = ""//todo
    var summary = "This document has tests related to liver and heart"//todo
    var healthInsights = "You need to visit a doctor and focus on liver health, try reducing fats in your diet"//todo
    

    
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
    
}

//A medical document has a the original medical document reference and a list of medical records
class MedicalDocumentSection: ObservableObject, Identifiable{
    ///1 document can have multiple sections, each section can have multiple tests(represented by BasicMedicalTestRecordv1)
    @Published var testRecords = [BasicMedicalTestRecordv1]()
    let id = UUID.init().uuidString
    //some generative ai data properties
    var name = "Liver function tests"//todo
    var summary = ""//todo
    var keyPoints = ""//todo
    
    func addNewMedicalTestRecords(testRecords: BasicMedicalTestRecordv1){
        self.testRecords.append(testRecords)
    }
    
}

class BasicMedicalTestRecordv1: Codable, Identifiable {
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
    
    init(test: String, value: String, unit: String, plottable: String, ref: String? = nil, plottableref: String? = nil, plottablereflowerlimit: String? = nil, plottablerefupperlimit: String? = nil) {
           self.test = test
           self.value = value
           self.unit = unit
           self.plottable = plottable
           self.ref = ref
           self.plottableref = plottableref
           self.plottablereflowerlimit = plottablereflowerlimit
           self.plottablerefupperlimit = plottablerefupperlimit
           //self.id = UUID().uuidString // Automatically generate UUID
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
}

