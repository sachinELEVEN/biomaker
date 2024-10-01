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
