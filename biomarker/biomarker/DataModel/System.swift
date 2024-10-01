//
//  System.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation
import SwiftUI

class System: ObservableObject{
    @Published var medicalDocuments = [MedicalDocument]()
    
    let fullWidth = UIScreen.main.bounds.width
    let fullHeight = UIScreen.main.bounds.height
    
    
    
    ///sends the medical test document to the server and generates new medical records and stores it in the system.medicalDocuments
    func generateNewMedicalTestRecords(medicalDocument: MedicalDocument,completion: @escaping (Bool,String) -> Void){
       print("EXPENSIVE CALL - GENERATING NEW MEDICAL TEST RECORDS FOR A NEW MEDICAL DOCUMENT")
        //this medicalDocument will probably have the reference to the actual pdf document which we will have to upload to the server
        
        APIService.fetchMedicalRecords(medicalDocument: medicalDocument) { records, error in
            if let error = error {
                let msg = "Error fetching records: \(error)"
                print("Error fetching records: \(error)")
                completion(false,msg)
            } else if let records = records {
                var msg = ""
                var testCounter = 0;
                for (key, testRecords) in records {
                    print("adding table: \(key) to medical document")
                    let medicalSection = MedicalDocumentSection()
                    for record in testRecords {
                        print("Test: \(record.test), Value: \(record.value), Unit: \(record.unit), Plottable: \(record.plottable)")
                        //store the test record in the medical section
                        if record.plottable != "yes"{
                            //for now we are only concerned about tests which are plottable
                            continue
                        }
                        testCounter += testRecords.count
                        medicalSection.addNewMedicalTestRecords(testRecords: record)
                    }
                    
                    //store the section in the medical document
                   
                    medicalDocument.addNewMedicalSection(section: medicalSection)
                    print("/generateNewMedicalTestRecords: New medical section added with \(medicalSection.testRecords.count) test records")
                   
                }
                
            DispatchQueue.main.async{
                //Adding the medical document to the user's list of medical documents
                self.medicalDocuments.append(medicalDocument)
                msg += "Processing done for \(testCounter) tests"
                print("/generateNewMedicalTestRecords: New medical document added to the system with \(medicalDocument.sections.count) sections")
                completion(true,msg)
            }
            }
        }

    }
}
