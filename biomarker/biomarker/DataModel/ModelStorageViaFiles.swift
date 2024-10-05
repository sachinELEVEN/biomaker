//
//  ModelStorageViaFiles.swift
//  biomarker
//
//  Created by sachin jeph on 05/10/24.
//

import Foundation

class BiomarkerFileSystem{
    
    public static func saveSystemMedicalDocuments(){
        print("/BiomarkerFileSystem: saveSystemMedicalDocuments")
        saveMedicalDocuments(system.medicalDocuments)
    }
    
  private static  func saveMedicalDocuments(_ documents: [MedicalDocument]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Makes the JSON easier to read
        do {
            let data = try encoder.encode(documents)
            if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = directory.appendingPathComponent("medical_documents.json")
                try data.write(to: fileURL)
                print("Data saved to \(fileURL)")
            }
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
   private static func loadMedicalDocuments() -> [MedicalDocument] {
        let decoder = JSONDecoder()
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = directory.appendingPathComponent("medical_documents.json")
            do {
                let data = try Data(contentsOf: fileURL)
                let documents = try decoder.decode([MedicalDocument].self, from: data)
                print("Data loaded successfully from \(fileURL)")
                return documents
            } catch {
                print("Error loading data: \(error)")
                //this can happen due to many reason, one of the main reason is simply the file wont exist on the first launch or till the user makes/save any changes, so in that case we will popuplate using mockdata so user can see what the app can do
                print("Using mock data to populate views")
                RootTabView.setMockMedicalDocument()
            }
        }
        return []
    }

    public static func loadModelDataFromFile(){
        print("/BiomarkerFileSystem: loadModelDataFromFile")
        let loadedDocuments = loadMedicalDocuments()
        system.medicalDocuments = loadedDocuments
    }

}
