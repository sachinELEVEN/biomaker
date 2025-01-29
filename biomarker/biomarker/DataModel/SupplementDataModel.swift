//
//  SupplementDataModel.swift
//  biomarker
//
//  Created by sachin jeph on 30/01/25.
//

import Foundation


// Enum for Frequency
enum BMSupplementFrequency: String {
    case daily = "Daily"
    case weekly = "Weekly"
    case daily2 = "2 times daily"
    case daily3 = "3 times daily"
    case monthly = "Monthly"
    case oneTime = "One time"
}


// Enum for Form
enum BMSupplementForm: String {
    case liquid = "Liquid"
    case capsule = "Capsule"
    case tablet = "Tablet"
    case injection = "Injection"
}


// Class representing a particular supplement
class BMSupplement {
    var revision:Int
    var id: String
    var name: String
    var strengthNumber: String
    var strengthUnit: String
    var frequency: BMSupplementFrequency
    var form: BMSupplementForm
    var timeOfConsumption: [Date]
    var reminderTime: [Date]
    var createdAt: Date
    var history: [BMSupplement] // Track changes over time
    var isReminderSet: Bool//looks useless if reminderTime is empty then obviously there is no reminder
    var userNotes: String?
    
    // AI-generated properties
    var aiContainsWhichChemicals: String? = nil
    var aiUsageCommonReason: String? = nil
    var aiAdditionalInfo: String? = nil
    var aiCommonStrengthNumber: String? = nil
    var aiCommonStrengthUnits: String? = nil
    var aiAdviceBasedUserHealthContext: String? = nil
    var aiSideEffect: String? = nil
    var aiCategory:String? = nil//supplement category
    
    init(id: String, name: String, strengthNumber: String, strengthUnit: String,
         frequency: BMSupplementFrequency, form: BMSupplementForm, timeOfConsumption: [Date],
         reminderTime: [Date], createdAt: Date, isReminderSet: Bool, userNotes: String?) {
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
        self.isReminderSet = isReminderSet
        self.userNotes = userNotes
    }
    
    //this should be called whenever it is modified
    func addRevision(){
        //increases revision adds to history and removes repeated fields from the history entires like the ai fields. Goal of history is to track variation in dosage/frequency-> so only keep those in the history
    }
    
}

// Class representing all the supplements taken by the user
class BMSupplementStack {
    var id: String
    var supplements: [BMSupplement]
    var stackHistory: [BMSupplementStack] // Track changes in the supplement stack
    var aiSupplementStackRecommendedTime: String? = nil
    var stackCompatibilityNote: String? = nil
    var adviceFeedbackOnStack: String? = nil
    
    init(id: String, supplements: [BMSupplement]) {
        self.id = id
        self.supplements = supplements
        self.stackHistory = []
    }
    
    func addSupplement(_ supplement: BMSupplement) {
        supplements.append(supplement)
    }
    
    func removeSupplement(_ supplement: BMSupplement) {
        supplements.removeAll { $0.id == supplement.id }
    }
    
    func setSupplementStackRecommendedTime(){
        //we will read aiSupplementStackRecommendedTime which will be a Map of supplement and their timings in a day and modify each supplement's timeOfConsumption
    }
}

