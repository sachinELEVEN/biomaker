//
//  ModelStorageViaFiles.swift
//  biomarker
//
//  Created by sachin jeph on 05/10/24.
//

import Foundation

enum BiomarkerFileSystemFileTypes{
    case supplementSystem
}

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
        //Load medical test record data
        let loadedDocuments = loadMedicalDocuments()
        system.medicalDocuments = loadedDocuments
        //Load supplement data
        if let supplementStackFromStorage = loadSupplementSystemDataFromLocal(){
            print("Loaded and created BMSupplementStackGL from storage")
            BMSupplementStackGL = supplementStackFromStorage
        }
        
        
        //Mock data for supplements
        var supp = BMSupplement(id: "32", supplementType: .supplement, name: "Vitamin D3", strengthNumber: "1000", strengthUnit: "IU", frequency: .daily3, form: .capsule, timeOfConsumption: [Date(),Date(),Date()], reminderTime: [], createdAt: Date(), is5MinReminderSet: false, userNotes: "These are my notes")
        
        var supp2 = BMSupplement(id: "33", supplementType: .supplement, name: "Minoxidil", strengthNumber: "5", strengthUnit: "%", frequency: .monthly, form: .capsule, timeOfConsumption: [Date()], reminderTime: [], createdAt: Date(), is5MinReminderSet: false, userNotes: "Was facing hair loss before")
        
        var supp3 = BMSupplement(id: "34", supplementType: .supplement, name: "Cheese", strengthNumber: "1000", strengthUnit: "mcg", frequency: .daily3, form: nil, timeOfConsumption: [Date(),Date(),Date()], reminderTime: [], createdAt: Date(), is5MinReminderSet: false, userNotes: "These are my thyroid notes")
        
//        BMSupplementStackGL.addSupplement(supp)
//        BMSupplementStackGL.addSupplement(supp2)
//        BMSupplementStackGL.addSupplement(supp3)
        
    }
    
    
    //MARK:- SAVING SUPPLEMENT SYSTEM DATA BELOW
    
    //YOU SHOULD USE THIS METHOD TO EXPOSE FILE SAVING
    //I am not using this for medical documents saving because logic for that is already written and i dont want to touch that
    ///by default changes are saved immediately but if you are calling from a certain method where its being called repeatedly like on every keystroke like when editing some properties like name of a supplement then please use debouncer so that we dont save a file multiple times in the system
    public static func saveToStorage(fileTypeToSave: BiomarkerFileSystemFileTypes,useDebouncer: Bool = false){
        print("/BiomarkerFileSystem: saveToStorage with debouncer \(useDebouncer) for \(fileTypeToSave)")
        
        // Cancel the previous work item if it exists
        workItem?.cancel()
        
        if !useDebouncer {
            if fileTypeToSave == .supplementSystem{
                saveSupplementSystemDataToLocal()
            }
            print("/saveToStorage Changes persisted to disk without debouncer for \(fileTypeToSave)")
            return
        }
        
        // Create a new work item with the save logic
        let newWorkItem = DispatchWorkItem {
            if fileTypeToSave == .supplementSystem{
                saveSupplementSystemDataToLocal()
            }
            
            print("/saveToStorage Changes persisted to disk with debouncer for \(fileTypeToSave)")
        }
        
        // Store the new work item
        workItem = newWorkItem
                
        // Schedule the new work item to execute after the debounce time
        DispatchQueue.main.asyncAfter(deadline: .now() + saveDebounceTime, execute: newWorkItem)
        
    }
    
    
        
       private static let supplementFileName = "supplement_system.json"
        
        /// Get the file URL for storing the supplement system data.
        private static var supplementFileURL: URL {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return documentDirectory.appendingPathComponent(supplementFileName)
        }

        /// Save the supplement system data locally as a JSON file.
       private static func saveSupplementSystemDataToLocal() {
            do {
                let data = try JSONEncoder().encode(BMSupplementStackGL)
                try data.write(to: BiomarkerFileSystem.supplementFileURL, options: .atomic)
                //you see emoji's so you know this code was written by AI
                print("✅ Supplement system data saved successfully!")
            } catch {
                print("❌ Failed to save supplement system data: \(error)")
            }
        }

        /// Load the supplement system data from local storage.
       private static func loadSupplementSystemDataFromLocal() -> BMSupplementStack? {
            do {
                let data = try Data(contentsOf: supplementFileURL)
                let loadedStack = try JSONDecoder().decode(BMSupplementStack.self, from: data)
                print("✅ Supplement system data loaded successfully!")
                return loadedStack
            } catch {
                print("❌ Failed to load supplement system data: \(error)")
                print("THERE COULD BE MANY REASONS FOR FAILURE TO LOAD DATA, BUT HERE WE WILL SUPPLEMENT SYSTEM LOAD MOCKDATA HERE- BECAUSE ON THE FIRST LAUNCH THE FILE WONT BE IN THE SYSTEM SO WE SHOW THE MOCK DATA")
                return nil
            }
        }

}
