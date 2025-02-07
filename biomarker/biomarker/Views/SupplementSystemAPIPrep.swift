//
//  SupplementSystemAPIPrep.swift
//  biomarker
//
//  Created by sachin jeph on 01/02/25.
//

import Foundation

/*
 Here we will prepare the various apis we use in the supplement system
 Currently - we have 2 Supplement system APIs
 1. Individual Supplement APIs
 2. Full Supplement Stack analysis
 */

class UserHealthContext {
    
    //MORE METHODS SPECIFICALLY FOR SUPPLEMENTSYSTEM
    //MAYBE THIS TAKES IN A ENUM LIKE SUPPLEMENTCONTEXT, OR SUPPLEMENTSTACK CONTEXT ETC AND SIMPLE RETURNS THAT
    func getUserHealthContext()->String{//THIS SHOULD MOVE TO USERHEALTHCONTEXT CLASS
            /*
             It will be based on
             1. user's out of ref test data- name, val, unit
             2. user's supplement stack- name, dosage, frequency
             3. user's additional global health note
             
             we wont user's supplement's user notes for now
             
             */
            return ""
    }
    
    static func analyzeSupplementStackWithLLM(_ supplementStack: BMSupplementStack, completion: @escaping (Bool, [String: Any]?) -> Void){
        
        //WE SHOULD ONLY PEROFORM IS IF THE SUPPLEMENTS COUNT > 0
        if supplementStack.supplements.count == 0{
            print("/analyzeSupplementStackWithLLM: no supplements present so cannot do stack analysis")
            completion(false,nil)
            return
        }
        
        /*
         Here we will provide LLM with
         1. supplement list
         
         Expectation- 1. Give a note on the supplement compatibilty or any advice on the supplement stack or changes user should make,2. recomended time to take these supplement or which order to the supplement in for max impact, 3. Rate the supplement based on the user's data out of 10.
         */
        let context = prepareSupplementStackAnalaysisContext()
        
        //MAKE A REQUEST TO THE SERVER WITH THIS PROMPT
        APIService.generateSupplementStackReportWithLLM(supplementStackInformation: context) { success, response in
            if !success{
                print("Failed to analyse the reponse")
                supplementStack.aiAnalysisStage = .failed
                DispatchQueue.main.async {
                    BMSupplementStackGL.refresh()
                }
                BiomarkerFileSystem.saveToStorage(fileTypeToSave: .supplementSystem)
                completion(false,nil)
            }else{
                print("/analyzeSupplementStackWithLLM: Successfully analysed the supplement stack compatibility")
                //modify the supplement with llm details
                //- we can publish all this in the stip
                let compatibility = response?["compatibility"] as? String ?? nil
                let recommended_timing = response?["recommended_timing"] as? String ?? nil
                let ai_rating = response?["ai_rating"] as? String ?? nil
                let ai_advice = response?["ai_advice"] as? String ?? nil
                let ai_common_name = response?["ai_common_name"] as? String ?? nil
                let ai_category = response?["ai_category"] as? String ?? nil
                let ai_is_valid = response?["ai_is_valid"] as? String ?? nil
                supplementStack.aiAnalysisStage = .completed
                
                //saving to Model and storage
                supplementStack.setProperty(property: .compatibility, value: compatibility)
                supplementStack.setProperty(property: .recommended_timing, value: recommended_timing)
                supplementStack.setProperty(property: .ai_rating, value: ai_rating)
                supplementStack.setProperty(property: .ai_advice, value: ai_advice)
                supplementStack.setProperty(property: .ai_common_name, value: ai_common_name)
                supplementStack.setProperty(property: .ai_category, value: ai_category)
                supplementStack.setProperty(property: .ai_is_valid, value: ai_is_valid)
                /*
                let aiReport = response?["ai_report"] as? String ?? nil
                let aiCommonName = response?["ai_common_name"] as? String ?? nil
                let aiCategory = response?["ai_category"] as? String ?? nil
                let aiCalories = response?["ai_calories"] as? String ?? nil
                let aiSideEffect = response?["ai_side_effects"] as? String ?? nil
                let aiAdviceBasedUserHealthContext = response?["ai_advice"] as? String ?? nil
                let aiCommonStrengthNumberAndUnits = response?["ai_common_dosage_strength"] as? String ?? nil
                let aiUsageCommonReasonForUseAndAdvantage = response?["ai_common_reason_for_use_and_advantages"] as? String ?? nil
                let aiAnalysisStage = .completed
                let aiSupplementValid = response?["ai_is_valid"] as? String ?? nil
                 */
                //Assign values to the supplement
                DispatchQueue.main.async {
                    BMSupplementStackGL.refresh()
                }
                BiomarkerFileSystem.saveToStorage(fileTypeToSave: .supplementSystem)
                completion(true,response)
            }
        }
        
        
        
    }
    
    static func analyzeSupplementWithLLM(_ supplement: BMSupplement, completion: @escaping (Bool, [String: Any]?) -> Void){
        
        /*
         This prompt will be added by the server as
         1. it reduces the payload on the client side
         2. easier to iterate
         3. we do validation of the required output on the server side
         
        var problemStatement = """
                 You are a top level doctor and are tasked with analyzing a newly added supplement or food item that a user intends to incorporate into their diet. Additionally, you will be provided with relevant information about the user's health. Based on this information, please prepare a report in JSON format that adheres to the following structure:
                 
                 {
                     "ai_report": "<Provide a detailed report on the supplement, commenting on its compatibility with the user's health, its potential impact based on the provided information, and its general effectiveness in the population.>",
                     "ai_common_reason_for_use_and_advantages": "<Fill this field with common reasons for using the supplement and its advantages.>",
                     "ai_common_dosage_strength": "<Specify the common dosage strength and units for this supplement.>",
                     "ai_advice": "<Provide any advice relevant to this supplement for the user.>",
                     "ai_side_effects": "<List any associated side effects of the supplement.>",
                     "ai_common_name": "<Provide the common name for this supplement.>",
                     "ai_category": "<Specify any category you want to assign to this supplement.>",
                     "ai_calories": "<Indicate the calories for the dosage of the supplement the user is taking.>"
                 }

                 Make sure you strictly just return the json and nothing else.
        """
        */
        
        let context = prepareSupplementAnalaysisContext(supplement)
        
      //  let promptToLLM = problemStatement + "\n\n" + context
        
        //MAKE A REQUEST TO THE SERVER WITH THIS PROMPT
        APIService.generateSupplementReportWithLLM(supplementInformation: context) { success, response in
            if !success{
                print("Failed to analyse the reponse")
                supplement.aiAnalysisStage = .failed
                DispatchQueue.main.async {
                    BMSupplementStackGL.refresh()
                }
                BiomarkerFileSystem.saveToStorage(fileTypeToSave: .supplementSystem)
                completion(false,nil)
            }else{
                print("/analyzeSupplementWithLLM: Successfully analysed the supplement compatibility")
                //modify the supplement with llm details
                supplement.aiRating = response?["ai_rating"] as? String ?? nil
                supplement.aiReport = response?["ai_report"] as? String ?? nil
                supplement.aiCommonName = response?["ai_common_name"] as? String ?? nil
                supplement.aiCategory = response?["ai_category"] as? String ?? nil
                supplement.aiCalories = response?["ai_calories"] as? String ?? nil
                supplement.aiSideEffect = response?["ai_side_effects"] as? String ?? nil
                supplement.aiAdviceBasedUserHealthContext = response?["ai_advice"] as? String ?? nil
                supplement.aiCommonStrengthNumberAndUnits = response?["ai_common_dosage_strength"] as? String ?? nil
                supplement.aiUsageCommonReasonForUseAndAdvantage = response?["ai_common_reason_for_use_and_advantages"] as? String ?? nil
                supplement.aiAnalysisStage = .completed
                supplement.aiSupplementValid = response?["ai_is_valid"] as? String ?? nil
                //Assign values to the supplement
                DispatchQueue.main.async {
                    BMSupplementStackGL.refresh()
                }
                BiomarkerFileSystem.saveToStorage(fileTypeToSave: .supplementSystem)
                completion(true,response)
            }
        }
        
        
    }
    
   static func prepareSupplementStackAnalaysisContext()->String{
        
        
        var context = ""
       //STEP1: SUPPLEMENT INFORMATION
       //context += getSuppplementDetailsContext(supplement: supplement)
        
        //STEP2: USER GENERAL HEALTH NOTES FROM USER
        context += userGeneralHealthNotesContext()
        
        //STEP3: Past test record information
       //THIS NEEDS ENHANCEMENT- WE MUST NOT SEND DUPLICATE TEST ENTRIES
        context += getTestRecordsContext()
        
        //STEP4: EXISTING SUPPLEMENT USER IS TAKING
       //we dont want the newly added supplement to be part of the supplement stack context
       context += getUserSupplementStackContext(supplementsToIgnore: [])
        
        return context
    }
    
   static func prepareSupplementAnalaysisContext(_ supplement: BMSupplement)->String{
        /*
         This is context will contain the following details
         1. Supplement Details
         - name
         - strength num and units
         - frequency of usage
         - form
         - list of time of consumption(only provide the time part and not the date part)
         - supplement userNotes
         
         3. User general health notes
         2. Past test record information (this i will add, leave it to me)
         3. Current supplement stack (this i will add leave it to me)
         
         Expectation from the LLM
         
         You are a top level doctor and are tasked with analyzing a newly added supplement or food item that a user intends to incorporate into their diet. Additionally, you will be provided with relevant information about the user's health. Based on this information, please prepare a report in JSON format that adheres to the following structure:
         
         {
             "ai_report": "<Provide a detailed report on the supplement, commenting on its compatibility with the user's health, its potential impact based on the provided information, and its general effectiveness in the population.>",
             "ai_common_reason_for_use_and_advantages": "<Fill this field with common reasons for using the supplement and its advantages.>",
             "ai_common_dosage_strength": "<Specify the common dosage strength and units for this supplement.>",
             "ai_advice": "<Provide any advice relevant to this supplement for the user.>",
             "ai_side_effects": "<List any associated side effects of the supplement.>",
             "ai_common_name": "<Provide the common name for this supplement.>",
             "ai_category": "<Specify any category you want to assign to this supplement.>",
             "ai_calories": "<Indicate the calories for the dosage of the supplement the user is taking.>"
         }

         Make sure you strictly just return the json and nothing else.
         
         */
       
        
        
        var context = ""
       //STEP1: SUPPLEMENT INFORMATION
       context += getSuppplementDetailsContext(supplement: supplement)
        
        //STEP2: USER GENERAL HEALTH NOTES FROM USER
        context += userGeneralHealthNotesContext()
        
        //STEP3: Past test record information
       //THIS NEEDS ENHANCEMENT- WE MUST NOT SEND DUPLICATE TEST ENTRIES
        context += getTestRecordsContext()
        
        //STEP4: EXISTING SUPPLEMENT USER IS TAKING
       //we dont want the newly added supplement to be part of the supplement stack context
       context += getUserSupplementStackContext(supplementsToIgnore: [supplement])
        
        return context
    }
    
    static func getUserSupplementStackContext(supplementsToIgnore: [BMSupplement])->String{
        /*
         You will be provided with a list of existing supplements that the user is currently taking. Your task is to analyze these supplements to assess whether the new supplement the user intends to add to their diet may interfere with or interact with the existing ones. Consider any potential reactions or effects that could arise from this new addition. Please keep these factors in mind while generating your report.
         
         Information of the supplement will be
         supplement name: dosage and strength
         */
        
        // Create the final list excluding the supplements to ignore
        let supplementToConsider = BMSupplementStackGL.supplements.filter { supplement in
            !supplementsToIgnore.contains(where: { $0.id == supplement.id })
        }

        
        var context = ""
        
        if supplementToConsider.count > 0 {
        context = """
        \n****
        USER EXISTING SUPPLEMENTS
        You will be provided with a list of existing supplements that the user is currently taking. Your task is to analyze these supplements to assess whether the new supplement the user intends to add to their diet may interfere with or interact with the existing ones. Consider any potential reactions or effects that could arise from this new addition. Please keep these factors in mind while generating your report.
        """
            for supplement in supplementToConsider{
                var row = "\n-Name: \(supplement.name)"
                row += "\n-Dosage strength: \(supplement.strengthNumber) \(supplement.strengthUnit)"
                context += row
            }
           
        }
        
        return context
    }
    
    static func getSuppplementDetailsContext(supplement: BMSupplement)->String{
        
        var dosageTimes = ""
        
        // Assuming timeOfConsumption is an array of optional Date objects
        for timeOfConsumption in supplement.timeOfConsumption {
            if let time = timeOfConsumption { // Safely unwrap the optional
                
                // Append the formatted time to dosageTimes
                if !dosageTimes.isEmpty {
                    dosageTimes += ", " // Add a comma if dosageTimes is not empty
                }
                dosageTimes += timeFormatter.string(from: time) // Append the formatted time
            }
        }
        
        
        let context = """
    \n****
    \(supplement.supplementType == .food ? "FOOD" : "SUPPLEMENT") DETAILS
    Here are the \(supplement.supplementType == .food ? "food" : "supplement") details of the supplement user is planning to add to his supplement stack.
        -Name: \(supplement.name)
        -Dosage strength: \(supplement.strengthNumber) \(supplement.strengthUnit)
        -Frequency of use: \(supplement.frequency.rawValue)
        \(supplement.form != nil ? "-form: \(supplement.form!.rawValue)" : "")
        -Time of dosage(s): \(dosageTimes)
        \(supplement.userNotes != nil && supplement.userNotes!.isJustWhitespace()==false ? "-User notes on supplement: \(supplement.userNotes!)":"")
    """
        
        return context
    }
    
    
    //This function will return a string which denotes the user test record information.
    //This will be useful for ai to better analyse user's health
    //We will provide the list of test for which user's test values are in range and for which it is out of ref range
    //THIS NEEDS ENHANCEMENT- WE MUST NOT SEND DUPLICATE TEST ENTRIES
    static func getTestRecordsContext()->String{
        /*
         The context will be of type
         Here are some medical test records for the users, I will first provide a list of test information.
         Where each row follows the below format-
         Row format = Test name : <test value> : <units> : <true if test value is out of ref range and false it is in ref range>
         
         */
        
        if system.totalTestRecordsCount() == 0 {
            print("No user test record context available as no. of test records are 0")
            return ""
        }
        
        var context = """
        \n****
        USER MEDICAL TEST RECORDS
        Here are some medical test records for the users, I will first provide a list of test information. Where each row follows the below format-
        Row format = Test name : <test value> : <units> : <true if test value is out of ref range and false it is in ref range> : <Date when the test was conduced>
        """
        
        for test in system.getAllTestRecords(){
            let testDate = test.testDate() != nil ? dateFormatter_D_MMMM_YYYY.string(from: test.testDate()!) : "NA"
            let row = "\n" + test.userFacingTestName() + " : " + test.value + " : " + test.userFacingUnit() + " : " + test.isOutOfRange().description + " : " + testDate
            context.append(row)
        }
        
        context += "\nKeep in mind today's date is \(dateFormatter_D_MMMM_YYYY.string(from: Date()))"
        
        return context
    }
    
    static func userGeneralHealthNotesContext()->String{
        var context = ""
        if !system.userHealthNotes().isJustWhitespace(){
            //add a prefix text saying this is general health information about the user. keep in mind when creating your report for supplement
            context += """
            \n****
            USER GENERAL HEALTH NOTES FROM USER
            Here is some health related information provided by the user, keep this in mind when you are creating the report.
            \n\(system.userHealthNotes())
        """
        }
        
        return context
    }
    
}
