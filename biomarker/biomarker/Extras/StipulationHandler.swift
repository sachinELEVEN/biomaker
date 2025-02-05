//
//  StipulationHandler.swift
//  biomarker
//
//  Created by sachin jeph on 05/02/25.
//

import Foundation

class StipulationHandler {
    
    // Add or update a key-value pair in the stipulation string
    static func addToStipulation(stip: String, key: String, value: String) -> String {
        var stip = stip
        
        // Split the stipulation string by semicolons to get key-value pairs
        var keyValuePairs = stip.split(separator: ";").map { String($0) }
        
        // Check if the key already exists
        for (index, pair) in keyValuePairs.enumerated() {
            let keyValue = pair.split(separator: "=")
            if keyValue.count == 2, keyValue[0] == key {
                // If the key exists, update the value
                keyValuePairs[index] = "\(key)=\(value)"
                return keyValuePairs.joined(separator: ";") + ";" // Return updated stipulation
            }
        }
        
        // If the key does not exist, add the new key-value pair
        stip += "\(key)=\(value);"
        return stip
    }

    // Return nil if the key is not present in the stipulation
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
