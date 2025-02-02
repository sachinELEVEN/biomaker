//
//  SupplementDetailedView.swift
//  biomarker
//
//  Created by sachin jeph on 02/02/25.
//

import Foundation
import SwiftUI


struct SupplementDetailView: View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    @Binding var showSelf : Bool
    var supplement: BMSupplement
    @State var analysisInProgress = false
    @State private var isAnimating = false
    @State var showSupplementEditView = false

    var body: some View {
        GeometryReader{ geo in
            ZStack {
               
                    LinearGradient(gradient: Gradient(colors: [Color.brightPurple.opacity(isAnimating ? 0.2 : 0), Color.brightpurple.opacity(isAnimating ? 0 : 0.2)]), startPoint: .topLeading, endPoint: .topTrailing)
                        .edgesIgnoringSafeArea(.all)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                       .opacity(analysisInProgress ? 1 : 0)//for some reason if i put this gradient in if condition on basis analysisInProgress, then animation gets stuck, not giving it too much attention for now
               
                VStack{
                    ScrollView(showsIndicators: false){
                        SupplementRow(supplement: supplement, showRating: false, showDateOfCreation: true)
                        
                        
                        if supplement.aiAnalysisStage == .completed || supplement.aiAnalysisStage == .outdated{
                            if supplement.isSupplementValid(){
                                biomarerIntelligenceLabel()
                                    .padding()
                            }else{
                                biomarerIntelligenceLabel(text: "Biomarker couldn't find any specific information on \(supplement.name).")
                                    .padding()
                            }
                        }
                        
                        if supplement.aiAnalysisStage == .never{
                            Button(action:{analyseSupplementWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse") with Biomarker Intelligence", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                        }
                        
                        if supplement.aiAnalysisStage == .outdated{
                            Button(action:{analyseSupplementWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse") with Biomarker Intelligence", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                            Text("You have made changes to \(supplement.name)'s record since the last analysis. Tap to perform the analysis again.")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .padding(.top,3)
                                .padding(.bottom)
                                .padding(.horizontal)
                        }
                        
                        if supplement.aiAnalysisStage == .failed{
                            Button(action:{analyseSupplementWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse") with Biomarker Intelligence", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                            Text("\(supplement.name)'s analysis failed last time, tap to try again")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .padding(.top,3)
                                .padding(.bottom)
                                .padding(.horizontal)
                        }
                        
                        //Reminder and dosage information- in edit options
                        
                        //AI data being displayed
                        if supplement.aiAnalysisStage == .completed || supplement.aiAnalysisStage == .outdated{
                            descriptionView("Please consult your doctor or a qualified healthcare professional for any advice regarding your supplements, food choices, and dosage recommendations.")
                        }
                        
                        
                        aiInfoView(header: "Rating", description: supplement.aiRating)//should be in format x/10
                        
                        if supplement.aiRating != nil && Float(supplement.aiRating!) != nil{
                            ZStack(alignment: .leading) {
                                // Background rectangle
                                Rectangle()
                                    .fill(Color.secondary) // Default color for the background
                                    .frame(height: 30) // Height of the progress bar
                                    .cornerRadius(20) // Optional: Rounded corners
                                
                                // Filled rectangle based on the number
                                Rectangle()
                                    .fill(SupplementDetailView.colorForNumber(Float(supplement.aiRating!)!)) // Set the fill color based on the number
                                    .frame(width: min(CGFloat(Float(supplement.aiRating!)!) / 10 * geo.size.width, geo.size.width/1.2), height: 30) // Calculate width based on the number
                                    .cornerRadius(20) // Optional: Rounded corners
                            }.padding(.horizontal)
                        }
                        
                        aiInfoView(header: "Report", description: supplement.aiReport)
                        aiInfoView(header: "Recommendation", description: supplement.aiAdviceBasedUserHealthContext)
                        aiInfoView(header: "Common reason for usage", description: supplement.aiUsageCommonReasonForUseAndAdvantage)
                        aiInfoView(header: "Side effects", description: supplement.aiSideEffect)
                        aiInfoView(header: "Common Dosage", description: supplement.aiCommonStrengthNumberAndUnits)
                        
                        aiInfoView(header: "Calories", description: supplement.aiCalories)
                        aiInfoView(header: "Common Name", description: supplement.aiCommonName)
                        aiInfoView(header: "Category", description: supplement.aiCategory)
                            .padding(.bottom)
                        
                        
                        Divider().padding(.horizontal)
                        aiInfoView(header: "Your notes", description: supplement.userNotes)
                            .padding(.bottom)
                        
                            .sheet(isPresented: $showSupplementEditView){
                                AddSupplementView(supplementToEditL: supplement)
                            }
                        
                        
                    }.animation(.default, value: 1)
                }.navigationTitle("\(supplement.supplementType == .food ? "Food" : "Supplement") Report")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                // Your action here
                                self.showSupplementEditView.toggle()
                            }) {
                                Image(systemName: "slider.horizontal.3")  // SF Symbol for search icon
                            }
                        }
                        
                    }
                    
            }
        }
       // .background(Color(UIColor.systemBackground))
        //.cornerRadius(8)
        //.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func aiInfoView(header: String, description: String?)->some View{
        return VStack{
            if description != nil && description?.isJustWhitespace() == false{
                headerView(header)
               descriptionView(description!)
            }else{
                //for testing
//                headerView(header)
//                descriptionView("Thyroxine (levothyroxine) is used to replace missing thyroid hormone in individuals with hypothyroidism.  Advantages include improved metabolism, weight management, energy levels, and mood.")
            }
        }
    }
    
    func headerView(_ text: String)->some View{
        return  HStack{
            Text(text)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
        }//.padding(.bottom,1)
        .padding([.top,.horizontal])
    }
    
    func descriptionView(_ text: String)->some View{
        return  HStack{
            Text(text)
                .font(.headline)
                //.fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Spacer()
            
        }//.padding(.bottom,1)
        .padding([.horizontal])
    }
    
    // Function to determine the color based on the number
       static func colorForNumber(_ number: Float) -> Color {
           switch number {
           case 0..<4:
               return .red // Highlight red for 0 to 2
           case 4..<7:
               return .yellow // Highlight yellow for 3 to 6
           case 7...10:
               return .green // Highlight green for 7 to 10
           default:
               return .secondary // Default color
           }
       }
    
    func analyseSupplementWithLLM(){
        
        if analysisInProgress{
            print("Cannot request a supplement analysis as the last one is in progress")
            return
        }
        analysisInProgress = true
        isAnimating = true
        
        
        UserHealthContext.analyzeSupplementWithLLM(supplement) { success, response in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                //putting thing in here because we do not want abrupt stops in animation in case completion handler gets called very quicky
                //side effect is that we will show anlaying with biomarker for a few moments longer, but its fine
                isAnimating = false
                analysisInProgress = false
            })
            
            
            if success{
            
                
            }else{
                print("Failed to analyse the reponse")
                //WE WILL PROBABLY NOT SHOW THIS MESSAGE BECAUSE WE IMEEDIATELY MOVE TO THE SCREEN 7- WHICH IS SUPPLEMENT DETAILED VIEW
                //message = "The \(supplementIsFoodItem ? "food item" : "supplement") has been added to your stack. However Biomarker was unable to analyze the \(supplementIsFoodItem ? "food item" : "supplement"), and you can request an analysis later from the supplement details page."
                
                //currentStep = 7
            }
        }
    }

}
