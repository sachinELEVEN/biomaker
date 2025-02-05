//
//  Settings.swift
//  biomarker
//
//  Created by sachin jeph on 05/02/25.
//

import Foundation
import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        NavigationView {
           // Text("Settings Page")
            List{
                Section {
                    UserHealthGeneralNotesView()
                       
                } header: {
                    Text("General Health Notes")
                } footer: {
                    Text("Add any relevant health or medical information, such as your height, weight, age, or conditions like hypothyroidism and diabetes. This will help organize your health data and history in one place, making it easier for you to understand your report.")
                }

            } .navigationTitle("Settings")
        }
    }
}



struct UserHealthGeneralNotesView: View {
    @State private var healthContext: String = "" // State variable to hold the user's health context
    @State private var notes: String = "" // State variable to hold the user's notes
    @State  var userNotes: String = ""
    @State  var userNotesPlaceholderText = "Type here...\n\nAdd any health related notes for you giving a brief information about you like height, weight, age etc."
    var body: some View {
       
            //ScrollView(showsIndicators: false){
              //  NavigationView {
                VStack{
            ZStack{
                if userNotes.isEmpty {
                    TextEditor(text:$userNotesPlaceholderText)
                        .font(.headline)
                    // .fontWeight(.bold)
                    //.background(Color.secondary.opacity(0.1))
                        .foregroundStyle(Color.secondary)
                        .scrollContentBackground(.hidden)
                        .disabled(true)
                }
                
                TextEditor(text: $userNotes)
                    .scrollContentBackground(.hidden)
                    .font(.headline)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                           // Spacer()
                            Button("Close keyboard") {
                                //console.log
                                UIApplication.shared.endEditing()
                            }
                        }
                    }
                
            }
            .frame(height: system.fullHeight/4)
            // TextField("reason for supplement...", text: $userNotes)
            //.padding()
//.background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
           // .padding(.horizontal)
            
                   // descriptionView(text: "Here, you can add any health or medical information relevant to you. This helps organize your health data and history in one place, allowing you to better understand your report.")
        }.onChange(of: userNotes) { newValue in
            BMSupplementStackGL.userGeneralHealthNotes = userNotes
        }
        .onAppear{
            self.userNotes = BMSupplementStackGL.userGeneralHealthNotes
        }
    //}
//            .navigationTitle("User Health Context")
           // .navigationBarTitleDisplayMode(.inline)
       // }
    }

    // Function to save the user's health context and notes
    private func saveUserHealthContext() {
        // Implement your save logic here
        print("Health Context: \(healthContext)")
        print("Notes: \(notes)")
    }
}


