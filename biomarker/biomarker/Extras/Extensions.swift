//
//  Extensions.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation
import SwiftUI

extension Color{
    static let primaryInvert = Color("appdefaultbgcolor")
    static let brightPurple = Color("brightpurple")
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension Float {
    /// Returns a string representation of the float truncated to `n` decimal digits.
    func truncated(toDecimalPlaces n: Int) -> String {
        guard n >= 0 else { return "\(self)" } // Return the number as-is if `n` is invalid.
        let multiplier = pow(10.0, Float(n))
        let truncatedValue = Float(Int(self * multiplier)) / multiplier
        return String(format: "%.\(n)f", truncatedValue)
    }
}

extension NSRegularExpression {
    func split(_ input: String) -> [String] {
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        let matches = matches(in: input, options: [], range: range)
        var lastSplitIndex = input.startIndex
        var components: [String] = []
        
        for match in matches {
            if let matchRange = Range(match.range, in: input) {
                let substring = String(input[lastSplitIndex..<matchRange.lowerBound])
                components.append(substring)
                lastSplitIndex = matchRange.upperBound
            }
        }
        components.append(String(input[lastSplitIndex..<input.endIndex]))
        return components
    }
}

// Date Formatter for displaying dates
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium // Set the date style (e.g., short, medium, long)
    formatter.timeStyle = .short   // Set the time style (e.g., short, medium, long)
    return formatter
}()


//To create a method that takes an index and returns a Boolean indicating whether the supplied index is the first non-nil index in an array of optionals, you can implement it as follows:
func isFirstNonNilIndex<T>(in array: [T?], index: Int) -> Bool {
    // Check if the index is within bounds
    guard index >= 0 && index < array.count else {
        return false
    }
    
    // Check if the element at the given index is non-nil
    if array[index] != nil {
        // Check if there are any non-nil elements before this index
        for i in 0..<index {
            if array[i] != nil {
                return false // Found a non-nil element before the given index
            }
        }
        return true // This index is the first non-nil index
    }
    
    return false // The element at the given index is nil
}

