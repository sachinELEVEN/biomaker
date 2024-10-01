//
//  globals.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation

let system = System()

let mockPdfUrl = URL(string: "file:///Users/sachinjeph/Library/Developer/CoreSimulator/Devices/9CFB1C0E-A042-48B9-977B-6E7E01826257/data/Containers/Data/Application/BB84A0B9-6319-4054-9602-428A04714A8B/Documents/78C36E25-47EA-4694-954F-DACD84FF368D")


class Utils{
    static func formatDate(_ date: Date) -> String {
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy" // e.g. "2 August, 2023"
        
        // Format the date into the desired string
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
}

class TextLocalisation{
   static func getLocalisedString(_ text: String) -> String{
        return text
    }
}
