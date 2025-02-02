//
//  ModelStorageViaFiles.swift
//  biomarker
//
//  Created by sachin jeph on 05/10/24.
//

import Foundation

class BiomarkerFileSystem{
    
    // Define a debouncing delay
    private static var saveDebounceTime: TimeInterval = 1
       // Reference for canceling previous scheduled work
    private static var workItem: DispatchWorkItem?
    
    ///by default changes are saved immediately but if you are calling from a certain method where its being called repeatedly like on every keystroke then please use debouncer so that we dont save a file multiple times in the system
    public static func saveSystemMedicalDocuments(useDebouncer: Bool = false){
        print("/BiomarkerFileSystem: saveSystemMedicalDocuments with debouncer \(useDebouncer)")
        
        // Cancel the previous work item if it exists
        workItem?.cancel()
        
        if !useDebouncer {
            saveMedicalDocuments(system.medicalDocuments)
            print("Changes persisted to disk without debouncer")
            return
        }
        
        // Create a new work item with the save logic
        let newWorkItem = DispatchWorkItem {
            saveMedicalDocuments(system.medicalDocuments)
            print("Changes persisted to disk with debouncer")
        }
        
        // Store the new work item
        workItem = newWorkItem
                
        // Schedule the new work item to execute after the debounce time
        DispatchQueue.main.asyncAfter(deadline: .now() + saveDebounceTime, execute: newWorkItem)
        
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
                for doc in documents{
                    doc.setup_medical_document()
                }
                return documents
            } catch {
                print("Error loading data: \(error)")
                //this can happen due to many reason, one of the main reason is simply the file wont exist on the first launch or till the user makes/save any changes, so in that case we will popuplate using mockdata so user can see what the app can do
                print("Using mock data to populate views")
                return RootTabView.getSampleDataForProd()
            }
        }
        return []
    }

    public static func loadModelDataFromFile(){
        print("/BiomarkerFileSystem: loadModelDataFromFile")
        let loadedDocuments = loadMedicalDocuments()
        system.medicalDocuments = loadedDocuments
        
        //Mock data for supplements
        var supp = BMSupplement(id: "32", supplementType: .supplement, name: "Vitamin D3", strengthNumber: "1000", strengthUnit: "IU", frequency: .daily3, form: .capsule, timeOfConsumption: [Date(),Date(),Date()], reminderTime: [], createdAt: Date(), is5MinReminderSet: false, userNotes: "These are my notes")
        
        var supp2 = BMSupplement(id: "33", supplementType: .supplement, name: "Minoxidil", strengthNumber: "5", strengthUnit: "%", frequency: .monthly, form: .capsule, timeOfConsumption: [Date()], reminderTime: [], createdAt: Date(), is5MinReminderSet: false, userNotes: "Was facing hair loss before")
        
        var supp3 = BMSupplement(id: "34", supplementType: .supplement, name: "Cheese", strengthNumber: "1000", strengthUnit: "mcg", frequency: .daily3, form: nil, timeOfConsumption: [Date(),Date(),Date()], reminderTime: [], createdAt: Date(), is5MinReminderSet: false, userNotes: "These are my thyroid notes")
        
        BMSupplementStackGL.addSupplement(supp)
        BMSupplementStackGL.addSupplement(supp2)
        BMSupplementStackGL.addSupplement(supp3)
        
    }
    
    
    //MARK:- SAVING SUPPLEMENT SYSTEM DATA BELOW
    // Function to save supplement data to local JSON file
    func saveSupplementSystemDataToLocal(supplementStack: BMSupplementStack) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory.")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("supplement_system.json")
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Optional: for pretty printing
            let jsonData = try encoder.encode(supplementStack)
            try jsonData.write(to: fileURL)
            print("Supplement data saved to \(fileURL.path)")
        } catch {
            print("Error saving supplement data: \(error)")
        }
    }

    // Function to load supplement data from local JSON file
    func loadSupplementSystemDataFromLocal() -> BMSupplementStack? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory.")
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("supplement_system.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let supplementStack = try decoder.decode(BMSupplementStack.self, from: data)
            print("Supplement data loaded from \(fileURL.path)")
            return supplementStack
        } catch {
            print("Error loading supplement data: \(error)")
            return nil
        }
    }

}
