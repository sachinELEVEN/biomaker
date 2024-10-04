//
//  HealthRecordDM.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation

//A medical document has a the original medical document reference and a list of medical records
class MedicalDocument: ObservableObject,Identifiable{
    
    public static var manualSectionName = "Manually Added Tests"
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
    var test: String
    var value: String
    var unit: String
    var plottable: String
    var ref: String?
    var plottableref: String?
    var plottablereflowerlimit: String?
    var plottablerefupperlimit: String?
    var id = UUID.init().uuidString

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
    
    func getParentDocument()->MedicalDocument?{
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
            if parentSection.name.lowercased().contains(searchStr) || parentSection.summary.lowercased().contains(searchStr) || parentSection.keyPoints.lowercased().contains(searchStr) {
                return true
            }
        }
        
        return false
    }
    
    
}

