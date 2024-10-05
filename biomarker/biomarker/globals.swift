//
//  globals.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation

let system = System()

let mockPdfUrl = URL(string: "file:///sample/Documents/sample.pdf")


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
