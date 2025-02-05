//
//  StipulationHandler.swift
//  biomarker
//
//  Created by sachin jeph on 05/02/25.
//

import Foundation

class StipulationHandler{
    //key value pair in a string
   static func addToStipulation(stip: String, key: String, value:String)->String{
        var stip = stip
        stip += "\(key)=\(value);"
        return stip
    }

    //return nil if the key is not present in the stipulation
   static func readStipulation(stip: String, key: String) -> String? {
        // Split the stipulation string by semicolons to get key-value pairs
        let keyValuePairs = stip.split(separator: ";")
        
        // Iterate through each key-value pair
        for pair in keyValuePairs {
            // Split each pair by the equals sign to separate key and value
            let keyValue = pair.split(separator: "=")
            
            // Check if the key matches the input key
            if keyValue.count == 2, keyValue[0] == key {
                // Return the corresponding value as a String
                return String(keyValue[1])
            }
        }
        
        // Return nil if the key is not found
        print("/readStipulation: Error- stip does not contain \(key)")
        return nil
    }
}
