//
//  SupplementDataModel.swift
//  biomarker
//
//  Created by sachin jeph on 30/01/25.
//

import Foundation


// Enum for Frequency
enum BMSupplementFrequency: String, CaseIterable {
    case oneTime = "One time"
    case daily = "1 time Daily"
    case daily2 = "2 times daily"
    case daily3 = "3 times daily"
    case weekly = "Weekly"
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
        }
    }
}



// Enum for Form
enum BMSupplementForm: String, CaseIterable {
    case liquid = "Liquid"
    case capsule = "Capsule"
    case tablet = "Tablet"
    case injection = "Injection"
}


// Class representing a particular supplement
class BMSupplement: Identifiable {
    
    var revision:Int
    var id: String
    var isFoodItem: Bool
    var name: String
    var strengthNumber: String
    var strengthUnit: String
    var frequency: BMSupplementFrequency
    var form: BMSupplementForm?
    var timeOfConsumption: [Date?]//date and time of the last consumption
    var reminderTime: [Date?]
    var createdAt: Date
    var history: [BMSupplement] // Track changes over time
    var isReminderSet: Bool//looks useless if reminderTime is empty then obviously there is no reminder
    var userNotes: String?
    
    // AI-generated properties
    var aiContainsWhichChemicals: String? = nil
    var aiUsageCommonReasonForUseAndAdvantage: String? = nil
    var aiAdditionalInfo: String? = nil
    var aiCommonStrengthNumber: String? = nil
    var aiCommonStrengthUnits: String? = nil
    var aiAdviceBasedUserHealthContext: String? = nil
    var aiSideEffect: String? = nil
    var aiCategory:String? = nil//supplement category
    var aiCommonName: String? = nil
    var aiCalories: String? = nil
    
    init(id: String, isFoodItem: Bool, name: String, strengthNumber: String, strengthUnit: String,
         frequency: BMSupplementFrequency, form: BMSupplementForm?, timeOfConsumption: [Date?],
         reminderTime: [Date?], createdAt: Date, isReminderSet: Bool, userNotes: String?) {
        self.revision = 0
        self.id = id
        self.isFoodItem = isFoodItem
        self.name = name
        self.strengthNumber = strengthNumber
        self.strengthUnit = strengthUnit
        self.frequency = frequency
        self.form = form
        self.timeOfConsumption = timeOfConsumption
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.history = []
        self.isReminderSet = isReminderSet
        self.userNotes = userNotes
    }
    
    //this should be called whenever it is modified
    func addRevision(){
        //increases revision adds to history and removes repeated fields from the history entires like the ai fields. Goal of history is to track variation in dosage/frequency-> so only keep those in the history
    }
    
}

// Class representing all the supplements taken by the user
class BMSupplementStack: ObservableObject {
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
    
    init(id: String, supplements: [BMSupplement]) {
        self.id = id
        self.supplements = supplements
        self.stackHistory = []
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
        
        return (true,"")
    }
    
    func removeSupplement(_ supplement: BMSupplement) {
        supplements.removeAll { $0.id == supplement.id }
    }
    
    func setSupplementStackRecommendedTime(){
        //we will read aiSupplementStackRecommendedTime which will be a Map of supplement and their timings in a day and modify each supplement's timeOfConsumption
    }
}

