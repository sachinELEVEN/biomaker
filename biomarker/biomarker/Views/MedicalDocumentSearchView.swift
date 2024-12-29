//
//  MedicalDocumentSearchView.swift
//  biomarker
//
//  Created by sachin jeph on 29/12/24.
//

import Foundation
import SwiftUI

struct MedicalDocumentSearchView: View{
    @Binding var showSelf : Bool
    @State var testRecordPicker = 0
    var doc : MedicalDocument
    @State private var searchText = ""
    @State private var allTestRecords: [BasicMedicalTestRecordv1] = [] // Your full list of test records
    @State private var filteredTestRecords: [BasicMedicalTestRecordv1] = [] // Filtered list for display
    @State private var isSearching: Bool = false // Show a loading indicator during search- not using it for now, since its local seaarch and should be fast
    var body: some View{
        VStack(alignment: .leading){
           
            Text("Search")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding()
            
            TextField("Search tests in this medical document", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            ScrollView(showsIndicators: false){
                
                QuickSearchOptionsView(docs: [doc],searchText: $searchText)
                .padding(.horizontal)
                    .padding(.vertical)
                
                
                VStack(alignment:.leading){
                    Text("You can search for tests by their name, organs or body parts they are related to")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding([.bottom,.horizontal])
                    //Filtered tests
                    Picker("", selection: $testRecordPicker) {
                                    Text("All Tests").tag(0)
                                    Text("Out of Range Tests").tag(1)
                                    Text("Plain List").tag(2)
                                   
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                    

                  /*
                    ForEach(doc.sections){ section in
                       
                        if MedicalDocumentViewerDetailed.getSectionTestRecords(section: section,val: testRecordPicker).count != 0{
                            Text(section.name.isEmpty ? "Report Section \(doc.findIndexOfSection(section: section)+1)" : section.name)
                                .fontWeight(.bold)
                                .font(.title)
                                .padding(.horizontal)
                                .padding([.top,.top])
                                .padding(.bottom,4)
                        }
                        */
                    
                    if filteredTestRecords.count == 0 {
                        HStack{
                            Spacer()
                            Text("Nothing to show")
                                .font(.title2)
                                .foregroundStyle(Color.secondary)
                                .padding()
                            Spacer()
                        }
                    }
                        
                        ForEach(filteredTestRecords){ testRecord in
                            VStack{
                                if testRecordPicker == 2{
                                    TestRecordPlainView(testRecord: testRecord)
                                        .padding([.horizontal,.top])
                                    Divider().padding(.horizontal).padding(.vertical,3)
                                }else{
                                    TestRecordView(record: testRecord)
                                        .padding()
                                        //.background(Color.secondary.opacity(0.2))
                                            .background(CustomBlur(style: .prominent))
                                            .cornerRadius(20)
                                            .padding([.horizontal,.top])
                                }
                                
                                 // Text("")
                            }
                        }
                  //  }

                }
            }
        }.onAppear{
            loadAllTests()
        }
        .onChange(of: searchText){newValue in
            if newValue.isEmpty {
                filteredTestRecords = allTestRecords // No filtering needed
                } else {
                    performSearch(searchText: newValue)
                }
        }
    }
    
    private func loadAllTests() {
        print("/MedicalDocumentSearchView /loadAllTests - Loading all tests")
            // Simulate loading test records (replace with your actual logic)
        filteredTestRecords.removeAll()
        allTestRecords.removeAll()
        for section in doc.sections{
            for test in section.testRecords{
                allTestRecords.append(test)
                filteredTestRecords.append(test)
            }
        }
    }
    
    private func performSearch(searchText: String) {
            // Show loading indicator and perform the search on a background thread
            isSearching = true
            DispatchQueue.global(qos: .userInitiated).async {
                let searchResults = allTestRecords.filter { $0.satisfiesSearch(searchStr: searchText.lowercased()) }
                DispatchQueue.main.async {
                    // Update the UI with the filtered results on the main thread
                    filteredTestRecords = searchResults
                    isSearching = false
                }
            }
        }
}


struct QuickSearchOptionsView: View{
    var docs : [MedicalDocument]
    @Binding var searchText: String
    var body: some View{
        HStack{
            //quick search functionality
            
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                ForEach(getQuickSearchOptions(),id:\.self){ organ in
                    HStack{
                        if organ.count<15{//sometimes organs has full blown sentences like 'reflects body inflammation' so we do not want that to appear in the search bar quick options
                            Button(action:{
                                quickSearchOptionTapped(option: organ)
                            }){
                                Text(organ)
                                    .foregroundStyle(isOptionPartOfSearchStr(option: organ) ? Color.primaryInvert : .primary)
                                //.fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                                    .padding(.vertical,2)
                                    .background(isOptionPartOfSearchStr(option: organ) ? Color.primary : Color.primaryInvert)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.primary, lineWidth: 4)
                                    )
                                
                                    .cornerRadius(10)
                            }
                            
                        }
                    }
                    }
                }
            }
        }
    }
    
    func getQuickSearchOptions()->[String]{
        //in future you can add more options here
        var allDocOrgansSet : Set<String> = Set()
        for doc in docs{
            for organ in doc.getDocOrgans(){
                allDocOrgansSet.insert(organ)
            }
        }
        
        return allDocOrgansSet.sorted()
    }
    
    func quickSearchOptionTapped(option: String){
        if isOptionPartOfSearchStr(option: option){
            //remove from searchText
            //removing is a little complex
            //lets say option is brain, then we do not want to remove in 'brainabc hello' but we want to remove brain in 'brain hello'
            //Regex is a good thing for this
            // Create a regular expression pattern to match the option with the given conditions
           //this regex is select the option in a string, if the option is not followed by any other character OR if its followed by space and is at the beginning of the str, OR if option is at the end of the string and is preceeded by space OR option is in the middle is succeeded and preceded by a space
            let pattern = "(?<=\\s)\(option)(?=\\s)|^\(option)(?=\\s)|(?<=\\s)\(option)$|^\(option)$"
                
            // Replace occurrences of the option matching the pattern with an empty string
            let modifiedText = searchText.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
                
            // Trim any leading/trailing whitespace from the result
            searchText =  modifiedText.trimmingCharacters(in: .whitespacesAndNewlines)

            //
        }else{
            //add to search text
            searchText += searchText.isEmpty ? option : " \(option)"
        }
        
    }
    
    func isOptionPartOfSearchStr(option: String)->Bool{
        
        let searchStrList = searchText
            .lowercased()
            .split { $0.isWhitespace || $0 == "," }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let optionStrList = option
            .lowercased()
            .split { $0.isWhitespace || $0 == "," }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if searchStrList.contains(option.lowercased()){
            return true
        }
        
        for optionStr in optionStrList {
                if !searchStrList.contains(optionStr) {
                    return false
                }
            }
        return true
        
    }
}
