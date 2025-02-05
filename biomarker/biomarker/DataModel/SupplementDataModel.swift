//
//  SupplementDataModel.swift
//  biomarker
//
//  Created by sachin jeph on 30/01/25.
//

import Foundation

//these represent the main feature set supported by the app, like these are the main features of the app
enum BMScopes: String, CaseIterable{
    case medicaltest = "Medical record"
    case supplement = "Supplement & food"
}

enum BMSupplementType: String, CaseIterable, Codable {
    case supplement = "Supplement"
    case food = "Food"
}

enum BMSupplementAIAnalysisStage: String, Codable {
    case never
    case failed
    case completed
    case outdated
    case history//when supplement object is part of history
}

// Enum for Frequency
enum BMSupplementFrequency: String, CaseIterable, Codable {
    case oneTime = "One time"
    case daily = "1 time Daily"
    case daily2 = "2 times daily"
    case daily3 = "3 times daily"
    case onceIn2Days = "Once every 2 days"
    case weekly = "Weekly"
    case onceIn2Weeks = "Once every 2 weeks"
    case monthly = "Monthly"

    // Computed property to return the interval in days
    var intervalInDays: Int {
        switch self {
        case .oneTime:
            return Int.max // Indicates a one-time supplement
        case .daily:
            return 1
        case .daily2:
            return 1 // Can be interpreted as 1 day, but taken twice
        case .daily3:
            return 1 // Can be interpreted as 1 day, but taken three times
        case .weekly:
            return 7
        case .monthly:
            return 30
        case .onceIn2Days:
            return 2
        case .onceIn2Weeks:
            return 14
        }
    }
}

// Enum for Form
enum BMSupplementForm: String, CaseIterable, Codable {
    case liquid = "Liquid"
    case capsule = "Capsule"
    case tablet = "Tablet"
    case injection = "Injection"
}



// Class representing a particular supplement
class BMSupplement: Identifiable, Codable {
    var revision: Int//dont think we are using it
    var id: String
    var name: String
    var strengthNumber: String
    var strengthUnit: String
    var frequency: BMSupplementFrequency
    var form: BMSupplementForm?
    var timeOfConsumption: [Date?]//date and time of the last consumption
    var reminderTime: [Date?]
    var createdAt: Date//denotes the date when this particular revision was created
    var history: [BMSupplement]// Track changes over time
    var is5MinReminderSet: Bool
    var userNotes: String?
    var supplementType: BMSupplementType
    
    // AI-generated properties
    var aiContainsWhichChemicals: String?
    var aiUsageCommonReasonForUseAndAdvantage: String?//present in supplement analysis report
    var aiAdditionalInfo: String?
    var aiCommonStrengthNumberAndUnits: String?//present in supplement analysis report
    var aiAdviceBasedUserHealthContext: String?//present in supplement analysis report
    var aiSideEffect: String?//present in supplement analysis report
    var aiCategory: String?//present in supplement analysis report
    var aiCommonName: String?//present in supplement analysis report
    var aiCalories: String?//present in supplement analysis report
    var aiRating: String?//present in supplement analysis report
    var aiReport: String?//present in supplement analysis report
    var aiSupplementValid: String?//present in supplement analysis report
    var aiAnalysisStage: BMSupplementAIAnalysisStage

    init(id: String, supplementType: BMSupplementType, name: String, strengthNumber: String, strengthUnit: String,
         frequency: BMSupplementFrequency, form: BMSupplementForm?, timeOfConsumption: [Date?],
         reminderTime: [Date?], createdAt: Date, is5MinReminderSet: Bool, userNotes: String?) {
        self.revision = 0
        self.id = id
        self.name = name
        self.strengthNumber = strengthNumber
        self.strengthUnit = strengthUnit
        self.frequency = frequency
        self.form = form
        self.timeOfConsumption = timeOfConsumption
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.history = []
        self.is5MinReminderSet = is5MinReminderSet
        self.userNotes = userNotes
        self.supplementType = supplementType
        self.aiAnalysisStage = .never
    }

    func isSupplementValid() -> Bool {
        return aiSupplementValid != "no"
    }
    
    ///returns a boolean value indicating whether this result matches the search key string
    func satisfiesSearch(searchStr: String)->Bool{
        //we need to get parent section's summary, name access here
        
        var searchCorpus = ""
        
        searchCorpus += "," + name + "," + (aiContainsWhichChemicals ?? "") + "," + (aiUsageCommonReasonForUseAndAdvantage ?? "") + "," + (aiAdditionalInfo ?? "") + "," + (aiCommonStrengthNumberAndUnits ?? "") + "," + (aiAdviceBasedUserHealthContext ?? "") + "," + (aiSideEffect ?? "") + "," + (aiCategory ?? "") + "," + (aiCommonName ?? "") + "," + (aiReport ?? "") + "," + (frequency.rawValue ) + "," + (form?.rawValue ?? "") + "," + (userNotes ?? "")
        
        //we are not searching the history for now
        
        return SearchFlow.search(searchCorpus: searchCorpus, searchKey: searchStr)
        
    }
    

    
    func saveEditChanges(supplementTypeL: BMSupplementType, nameL: String, strengthNumberL: String, strengthUnitL: String,
                     frequencyL: BMSupplementFrequency, formL: BMSupplementForm?, timeOfConsumptionL: [Date?],
                     reminderTimeL: [Date?], createdAtL: Date, is5MinReminderSetL: Bool, userNotesL: String?) {
        // Increase revision and track changes in history
        

        
        //update aistage if any of the following properties has changed- name, strengthNumber, strengthUnit, frequency, form, userNotes, supplementType, timeOfConsumption
        //as only when these properties are changed we need to do ai analysis again
        if(self.name != nameL || self.strengthUnit != strengthUnitL || self.strengthNumber != strengthNumberL || self.frequency != frequencyL || self.form != formL || self.userNotes != userNotesL || self.supplementType != supplementTypeL || self.timeOfConsumption != timeOfConsumptionL){
            
            print("/saveEditChanges: Saving the history object first")
            let historyObjId = UUID().uuidString
            //create a clone of the current state of the object and save it to the history
            let historyObj = BMSupplement(id: historyObjId, supplementType: self.supplementType, name: self.name, strengthNumber: self.strengthNumber, strengthUnit: self.strengthUnit, frequency: self.frequency, form: self.form, timeOfConsumption: self.timeOfConsumption, reminderTime: self.reminderTime, createdAt: self.createdAt, is5MinReminderSet: self.is5MinReminderSet, userNotes: self.userNotes)
            //now setting the optional ai props to the history obj
            //Chances are there are redundant and will not be used ever but we are just covering our basis
            historyObj.aiContainsWhichChemicals = self.aiContainsWhichChemicals
            historyObj.aiUsageCommonReasonForUseAndAdvantage = self.aiUsageCommonReasonForUseAndAdvantage
            historyObj.aiAdditionalInfo = self.aiAdditionalInfo
            historyObj.aiCommonStrengthNumberAndUnits = self.aiCommonStrengthNumberAndUnits
            historyObj.aiAdviceBasedUserHealthContext = self.aiAdviceBasedUserHealthContext
            historyObj.aiSideEffect = self.aiSideEffect
            historyObj.aiCategory = self.aiCategory
            historyObj.aiCommonName = self.aiCommonName
            historyObj.aiCalories = self.aiCalories
            historyObj.aiRating = self.aiRating
            historyObj.aiReport = self.aiReport
            historyObj.aiSupplementValid = self.aiSupplementValid
            historyObj.aiAnalysisStage = .history
            self.history.append(historyObj)
            
            print("/edit mode supplement's aiAnalysis stage changed to .outdated")
            self.aiAnalysisStage = .outdated
        }
        
        //update the current object and save the edit
        print("/saveEditChanges: Saving the edited value")
        
        
        self.name = nameL
        self.strengthNumber = strengthNumberL
        self.strengthUnit = strengthUnitL
        self.frequency = frequencyL
        self.form = formL
        self.userNotes = userNotesL
        self.supplementType = supplementTypeL
        self.timeOfConsumption = timeOfConsumptionL
        self.reminderTime = reminderTimeL
        self.is5MinReminderSet = is5MinReminderSetL
        self.createdAt = createdAtL//updating the date
        
        //Save updated model to the storage
        BiomarkerFileSystem.saveToStorage(fileTypeToSave: .supplementSystem)
        BMSupplementStackGL.refresh()
        
        
    }

    // MARK: - Codable Conformance
    private enum CodingKeys: String, CodingKey {
        case revision, id, name, strengthNumber, strengthUnit, frequency, form, timeOfConsumption, reminderTime, createdAt, history, is5MinReminderSet, userNotes, supplementType, aiContainsWhichChemicals, aiUsageCommonReasonForUseAndAdvantage, aiAdditionalInfo, aiCommonStrengthNumberAndUnits, aiAdviceBasedUserHealthContext, aiSideEffect, aiCategory, aiCommonName, aiCalories, aiRating, aiReport, aiSupplementValid, aiAnalysisStage
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        revision = try container.decode(Int.self, forKey: .revision)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        strengthNumber = try container.decode(String.self, forKey: .strengthNumber)
        strengthUnit = try container.decode(String.self, forKey: .strengthUnit)
        frequency = try container.decode(BMSupplementFrequency.self, forKey: .frequency)
        form = try container.decodeIfPresent(BMSupplementForm.self, forKey: .form)
        timeOfConsumption = try container.decode([[Date]?].self, forKey: .timeOfConsumption).map { $0?.first }
        reminderTime = try container.decode([[Date]?].self, forKey: .reminderTime).map { $0?.first }
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        history = try container.decode([BMSupplement].self, forKey: .history)
        is5MinReminderSet = try container.decode(Bool.self, forKey: .is5MinReminderSet)
        userNotes = try container.decodeIfPresent(String.self, forKey: .userNotes)
        supplementType = try container.decode(BMSupplementType.self, forKey: .supplementType)
        aiContainsWhichChemicals = try container.decodeIfPresent(String.self, forKey: .aiContainsWhichChemicals)
        aiUsageCommonReasonForUseAndAdvantage = try container.decodeIfPresent(String.self, forKey: .aiUsageCommonReasonForUseAndAdvantage)
        aiAdditionalInfo = try container.decodeIfPresent(String.self, forKey: .aiAdditionalInfo)
        aiCommonStrengthNumberAndUnits = try container.decodeIfPresent(String.self, forKey: .aiCommonStrengthNumberAndUnits)
        aiAdviceBasedUserHealthContext = try container.decodeIfPresent(String.self, forKey: .aiAdviceBasedUserHealthContext)
        aiSideEffect = try container.decodeIfPresent(String.self, forKey: .aiSideEffect)
        aiCategory = try container.decodeIfPresent(String.self, forKey: .aiCategory)
        aiCommonName = try container.decodeIfPresent(String.self, forKey: .aiCommonName)
        aiCalories = try container.decodeIfPresent(String.self, forKey: .aiCalories)
        aiRating = try container.decodeIfPresent(String.self, forKey: .aiRating)
        aiReport = try container.decodeIfPresent(String.self, forKey: .aiReport)
        aiSupplementValid = try container.decodeIfPresent(String.self, forKey: .aiSupplementValid)
        aiAnalysisStage = try container.decode(BMSupplementAIAnalysisStage.self, forKey: .aiAnalysisStage)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(revision, forKey: .revision)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(strengthNumber, forKey: .strengthNumber)
        try container.encode(strengthUnit, forKey: .strengthUnit)
        try container.encode(frequency, forKey: .frequency)
        try container.encodeIfPresent(form, forKey: .form)
        try container.encode(timeOfConsumption.map { [$0] }, forKey: .timeOfConsumption)
        try container.encode(reminderTime.map { [$0] }, forKey: .reminderTime)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(history, forKey: .history)
        try container.encode(is5MinReminderSet, forKey: .is5MinReminderSet)
        try container.encodeIfPresent(userNotes, forKey: .userNotes)
        try container.encode(supplementType, forKey: .supplementType)
        try container.encodeIfPresent(aiContainsWhichChemicals, forKey: .aiContainsWhichChemicals)
        try container.encodeIfPresent(aiUsageCommonReasonForUseAndAdvantage, forKey: .aiUsageCommonReasonForUseAndAdvantage)
        try container.encodeIfPresent(aiAdditionalInfo, forKey: .aiAdditionalInfo)
        try container.encodeIfPresent(aiCommonStrengthNumberAndUnits, forKey: .aiCommonStrengthNumberAndUnits)
        try container.encodeIfPresent(aiAdviceBasedUserHealthContext, forKey: .aiAdviceBasedUserHealthContext)
        try container.encodeIfPresent(aiSideEffect, forKey: .aiSideEffect)
        try container.encodeIfPresent(aiCategory, forKey: .aiCategory)
        try container.encodeIfPresent(aiCommonName, forKey: .aiCommonName)
        try container.encodeIfPresent(aiCalories, forKey: .aiCalories)
        try container.encodeIfPresent(aiRating, forKey: .aiRating)
        try container.encodeIfPresent(aiReport, forKey: .aiReport)
        try container.encodeIfPresent(aiSupplementValid, forKey: .aiSupplementValid)
        try container.encode(aiAnalysisStage, forKey: .aiAnalysisStage)
    }
}


// Class representing all the supplements taken by the user
class BMSupplementStack: ObservableObject, Codable {
    @Published var _refresh = true
    
    func refresh(){
        self._refresh.toggle()
    }
    
    var id: String
    @Published var supplements: [BMSupplement]
    @Published var stackHistory: [BMSupplementStack] // Track changes in the supplement stack
    @Published var aiSupplementStackRecommendedTime: String? = nil
    @Published var stackCompatibilityNote: String? = nil
    @Published var adviceFeedbackOnStack: String? = nil
    @Published var stip: String = ""
    
    init(id: String, supplements: [BMSupplement]) {
        self.id = id
        self.supplements = supplements
        self.stackHistory = []
    }
    
    //using this m_propertyname naming scheme from Broadway/BFX and this whole stip thing is picked from broadway
    private var m_userGeneralHealthNotesKey = "usergeneralhealthnotes"
    //this also saves the newly set value in the local filesystem
    var userGeneralHealthNotes: String {
        get {
            return StipulationHandler.readStipulation(stip: stip, key: m_userGeneralHealthNotesKey) ?? ""
        }
        set {
            self.stip = StipulationHandler.addToStipulation(stip: stip, key: m_userGeneralHealthNotesKey, value: newValue)
            BiomarkerFileSystem.saveToStorage(fileTypeToSave: .supplementSystem, useDebouncer: true)
        }
    }
    
    //returns a set representing categories of supplement present in the system
    func getCategories(maxLength: Int = Int.max) -> Set<String> {
//        var summary = "Biomarker found \(totalTestRecordsCount()) tests in the document.\n"
        var categoriesSet: Set<String> = Set()
        
        // Collect unique categories
            for supp in supplements {
                let listOfCategories = Utils.splitIntoListBy(supp.aiCategory ?? "", delimiters: [",", ";"])
                categoriesSet.formUnion(listOfCategories) // Add unique organs to the set
            }
        
        //we also want the frequencies to show up in the quick search options
        var allFrequencies : [String] = []
        for freq in BMSupplementFrequency.allCases{
            allFrequencies.append(freq.rawValue)
        }
        categoriesSet.formUnion(allFrequencies)
        
        
//        if !categoriesSet.isEmpty {
//            //summary += "The report focuses on tests for: "
//            summary += categoriesSet.sorted().joined(separator: ", ") // Combine organ names, sorted, and separated by commas
//        }
//        
//        if summary.count > maxLength{
//            return summary.prefix(maxLength) + "..."
//        }
        //return summary
        return categoriesSet
    }
    
    func addSupplement(_ supplement: BMSupplement)->(Bool,String){
        //here we will do checks like the same id object is not already there in the system
        var found = false
        for suppm in supplements{
            if suppm.id == supplement.id || suppm.name == supplement.name{
                found = true
            }
        }
        
        if found{
            print("Supplement \(supplement.name) already present in the system")
            return (false,"An item by the name \(supplement.name) is already present in your supplement stack")
        }
        
        supplements.append(supplement)
        print("Supplement \(supplement.name) added to the system. Total supplement stack size: \(supplements.count)")
        BiomarkerFileSystem.saveToStorage(fileTypeToSave: .supplementSystem)
        return (true,"")
    }
    
    func removeSupplement(_ supplement: BMSupplement) {
        print("/removeSupplement: Removing supplement with name: \(supplement.name)")
        supplements.removeAll { $0.id == supplement.id }
        BiomarkerFileSystem.saveToStorage(fileTypeToSave: .supplementSystem)
    }
    
    func setSupplementStackRecommendedTime() {
        // Implement logic to modify each supplement's timeOfConsumption
        //we will read aiSupplementStackRecommendedTime which will be a Map of supplement and their timings in a day and modify each supplement's timeOfConsumption
    }
    
    // Custom CodingKeys to exclude `_refresh`
    enum CodingKeys: String, CodingKey {
        case id, supplements, stackHistory, aiSupplementStackRecommendedTime, stackCompatibilityNote, adviceFeedbackOnStack, stip
    }
    
    // Custom encoding to handle @Published properties
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(supplements, forKey: .supplements)
        try container.encode(stackHistory, forKey: .stackHistory)
        try container.encode(aiSupplementStackRecommendedTime, forKey: .aiSupplementStackRecommendedTime)
        try container.encode(stackCompatibilityNote, forKey: .stackCompatibilityNote)
        try container.encode(adviceFeedbackOnStack, forKey: .adviceFeedbackOnStack)
        try container.encode(stip, forKey: .stip)
        
    }
    
    // Custom decoding to handle @Published properties
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        supplements = try container.decode([BMSupplement].self, forKey: .supplements)
        stackHistory = try container.decode([BMSupplementStack].self, forKey: .stackHistory)
        aiSupplementStackRecommendedTime = try container.decodeIfPresent(String.self, forKey: .aiSupplementStackRecommendedTime)
        stackCompatibilityNote = try container.decodeIfPresent(String.self, forKey: .stackCompatibilityNote)
        adviceFeedbackOnStack = try container.decodeIfPresent(String.self, forKey: .adviceFeedbackOnStack)
        stip = try container.decodeIfPresent(String.self, forKey: .stip) ?? ""
        
        
    }
}
